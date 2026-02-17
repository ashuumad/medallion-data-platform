# ============================================================
# dagster/assets.py — Dagster Assets (pipeline steps)
# ============================================================
# In Dagster, an "asset" is a piece of data that your pipeline
# produces — like a database table or a file.
#
# Dagster tracks:
#   ✅ When each asset was last updated
#   ✅ Which assets depend on which
#   ✅ Whether assets are fresh or stale
# ============================================================

from dagster import asset, AssetExecutionContext, Output, MetadataValue
from dagster_dbt import DbtCliResource, dbt_assets, DbtProject
from pathlib import Path
import pandas as pd

# ── Point to your dbt project ────────────────────────────────
DBT_PROJECT_DIR = Path(__file__).parent.parent / "dbt"

dbt_project = DbtProject(
    project_dir=DBT_PROJECT_DIR,
    packaged_project_dir=DBT_PROJECT_DIR,
)

# ── Asset Group 1: Raw data ingestion ────────────────────────
@asset(
    group_name="bronze",
    description="Load raw orders CSV into the Bronze layer",
)
def raw_orders_ingestion(context: AssetExecutionContext):
    """
    Reads raw CSV data and prepares it for dbt ingestion.
    In a real pipeline, this might call an API or read from a database.
    """
    csv_path = DBT_PROJECT_DIR / "seeds" / "raw_orders.csv"
    df = pd.read_csv(csv_path)

    context.log.info(f"Loaded {len(df)} rows from raw CSV")

    return Output(
        value=df,
        metadata={
            "num_rows": MetadataValue.int(len(df)),
            "num_columns": MetadataValue.int(len(df.columns)),
            "preview": MetadataValue.md(df.head(5).to_markdown()),
        }
    )


# ── Asset Group 2: dbt transformations ───────────────────────
# This tells Dagster to run ALL your dbt models as assets.
# Dagster will automatically create the dependency graph.
@dbt_assets(
    manifest=DBT_PROJECT_DIR / "target" / "manifest.json",
    project=dbt_project,
)
def medallion_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    """
    Runs all dbt models: Bronze → Silver → Gold
    Dagster automatically detects the model dependency order.
    """
    yield from dbt.cli(["build"], context=context).stream()


# ── Asset Group 3: Data quality check ────────────────────────
@asset(
    group_name="gold",
    deps=[medallion_dbt_assets],
    description="Verify Gold layer row counts after pipeline runs",
)
def gold_quality_check(context: AssetExecutionContext):
    """
    Simple check to verify the Gold layer has data after the pipeline.
    In production, you'd add more sophisticated checks here.
    """
    import duckdb

    db_path = str(DBT_PROJECT_DIR.parent / "data" / "medallion.duckdb")
    conn = duckdb.connect(db_path)

    try:
        result = conn.execute("SELECT COUNT(*) as cnt FROM gold.gold_sales_summary").fetchone()
        row_count = result[0] if result else 0
        context.log.info(f"Gold layer has {row_count} rows ✅")

        assert row_count > 0, "Gold layer is empty! Something went wrong."

        return Output(
            value={"gold_rows": row_count},
            metadata={"gold_row_count": MetadataValue.int(row_count)}
        )
    finally:
        conn.close()
