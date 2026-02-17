# ============================================================
# dagster/jobs.py — Pipeline Jobs
# ============================================================
# A "job" in Dagster is a named, runnable collection of assets.
# You can trigger jobs manually or on a schedule.
# ============================================================

from dagster import define_asset_job, AssetSelection

# Run the complete medallion pipeline end-to-end
medallion_pipeline_job = define_asset_job(
    name="medallion_pipeline",
    description="Full pipeline: Bronze → Silver → Gold",
    selection=AssetSelection.all(),   # runs all assets
)

# Run only Bronze ingestion (useful for testing)
bronze_only_job = define_asset_job(
    name="bronze_ingestion_only",
    description="Only run the raw data ingestion step",
    selection=AssetSelection.groups("bronze"),
)

# Run only dbt transformations (skips ingestion)
dbt_refresh_job = define_asset_job(
    name="dbt_refresh",
    description="Re-run all dbt transformations without re-ingesting data",
    selection=AssetSelection.groups("bronze", "silver", "gold"),
)
