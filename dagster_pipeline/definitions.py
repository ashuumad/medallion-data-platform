# ============================================================
# dagster_pipeline/definitions.py — Main Dagster config
# ============================================================

from dagster import Definitions
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import assets
from jobs import medallion_pipeline_job
from schedules import daily_schedule

defs = Definitions(
    assets=[
        assets.raw_orders_ingestion,
        assets.silver_orders,
        assets.gold_sales_summary,
    ],
    jobs=[medallion_pipeline_job],
    schedules=[daily_schedule],
)
