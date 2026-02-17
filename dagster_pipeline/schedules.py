# ============================================================
# dagster_pipeline/schedules.py — Pipeline Schedules
# ============================================================

from dagster import ScheduleDefinition
from jobs import medallion_pipeline_job

daily_schedule = ScheduleDefinition(
    job=medallion_pipeline_job,
    cron_schedule="0 6 * * *",
    name="daily_medallion_refresh",
    description="Refresh the full medallion pipeline every day at 6 AM UTC",
)
