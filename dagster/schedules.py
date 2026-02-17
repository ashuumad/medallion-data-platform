# ============================================================
# dagster/schedules.py — Pipeline Schedules
# ============================================================
# Schedules tell Dagster WHEN to run your pipeline automatically.
# Uses cron syntax:  minute  hour  day  month  weekday
#   Examples:
#     "0 6 * * *"    = every day at 6:00 AM
#     "0 */4 * * *"  = every 4 hours
#     "0 9 * * 1"    = every Monday at 9 AM
# ============================================================

from dagster import ScheduleDefinition
from .jobs import medallion_pipeline_job

# Run the full pipeline every day at 6 AM UTC
daily_schedule = ScheduleDefinition(
    job=medallion_pipeline_job,
    cron_schedule="0 6 * * *",
    name="daily_medallion_refresh",
    description="Refresh the full medallion pipeline every day at 6 AM UTC",
)

# Uncomment for hourly runs (useful during development/testing):
# hourly_schedule = ScheduleDefinition(
#     job=medallion_pipeline_job,
#     cron_schedule="0 * * * *",
#     name="hourly_medallion_refresh",
# )
