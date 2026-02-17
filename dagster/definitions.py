# ============================================================
# dagster/definitions.py — Main Dagster orchestration config
# ============================================================
# This is the entry point for Dagster.
# It declares all assets, jobs, and schedules.
#
# Start Dagster UI with: dagster dev -f definitions.py
# ============================================================

from dagster import Definitions, load_assets_from_modules
from dagster_dbt import DbtCliResource

from . import assets
from .jobs import medallion_pipeline_job
from .schedules import daily_schedule

# ── Load all assets (the building blocks of your pipeline) ──
all_assets = load_assets_from_modules([assets])

# ── Wire everything together ─────────────────────────────────
defs = Definitions(
    assets=all_assets,
    jobs=[medallion_pipeline_job],
    schedules=[daily_schedule],
    resources={
        # dbt resource: tells Dagster where your dbt project lives
        "dbt": DbtCliResource(
            project_dir="../dbt",
            profiles_dir="../dbt",
        ),
    },
)
