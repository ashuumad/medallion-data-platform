# ============================================================
# dagster_pipeline/jobs.py — Pipeline Jobs
# ============================================================

from dagster import define_asset_job, AssetSelection

medallion_pipeline_job = define_asset_job(
    name="medallion_pipeline",
    description="Full pipeline: Bronze -> Silver -> Gold",
    selection=AssetSelection.all(),
)

bronze_only_job = define_asset_job(
    name="bronze_ingestion_only",
    description="Only run the raw data ingestion step",
    selection=AssetSelection.groups("bronze"),
)
