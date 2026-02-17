# ============================================================
# dagster_pipeline/assets.py — Simplified for local learning
# ============================================================

from dagster import asset, AssetExecutionContext, Output, MetadataValue
import pandas as pd
from pathlib import Path

DATA_DIR = Path(__file__).parent.parent / "data"
DBT_DIR = Path(__file__).parent.parent / "dbt"

# ── Bronze: Raw data ingestion ────────────────────────────────
@asset(
    group_name="bronze",
    description="Load raw orders CSV into the Bronze layer",
)
def raw_orders_ingestion(context: AssetExecutionContext):
    csv_path = DBT_DIR / "seeds" / "raw_orders.csv"
    df = pd.read_csv(csv_path)
    context.log.info(f"Loaded {len(df)} rows from raw CSV")
    return Output(
        value=df,
        metadata={
            "num_rows": MetadataValue.int(len(df)),
            "num_columns": MetadataValue.int(len(df.columns)),
        }
    )

# ── Silver: Cleaned data ──────────────────────────────────────
@asset(
    group_name="silver",
    description="Clean and validate orders data",
    deps=[raw_orders_ingestion],
)
def silver_orders(context: AssetExecutionContext):
    csv_path = DBT_DIR / "seeds" / "raw_orders.csv"
    df = pd.read_csv(csv_path)

    # Clean: remove duplicates
    df = df.drop_duplicates(subset=["order_id"])

    # Clean: remove invalid rows
    df = df[df["quantity"] > 0]
    df = df[df["unit_price"] > 0]

    # Standardize status
    df["status"] = df["status"].str.lower().str.strip()
    df["status"] = df["status"].replace({"complete": "completed", "canceled": "cancelled"})

    # Derived column
    df["line_total"] = df["quantity"] * df["unit_price"]

    context.log.info(f"Silver layer: {len(df)} clean rows")
    return Output(
        value=df,
        metadata={"num_rows": MetadataValue.int(len(df))}
    )

# ── Gold: Business aggregation ────────────────────────────────
@asset(
    group_name="gold",
    description="Daily sales summary by product",
    deps=[silver_orders],
)
def gold_sales_summary(context: AssetExecutionContext):
    csv_path = DBT_DIR / "seeds" / "raw_orders.csv"
    df = pd.read_csv(csv_path)
    df = df[df["status"].str.lower().str.strip().isin(["completed", "complete"])]
    df["line_total"] = df["quantity"] * df["unit_price"]

    summary = df.groupby(["order_date", "product_name"]).agg(
        num_orders=("order_id", "count"),
        total_units=("quantity", "sum"),
        total_revenue=("line_total", "sum"),
    ).reset_index()

    context.log.info(f"Gold layer: {len(summary)} rows")
    return Output(
        value=summary,
        metadata={
            "num_rows": MetadataValue.int(len(summary)),
            "total_revenue": MetadataValue.float(float(summary["total_revenue"].sum())),
        }
    )
