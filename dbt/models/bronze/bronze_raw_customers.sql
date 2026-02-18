-- Bronze layer: raw customers loaded from seed
-- No transformations — exact copy with ingestion timestamp
{{ config(
    materialized='external',
    location="abfss://medallion@" ~ var('adls_account') ~ ".dfs.core.windows.net/bronze/customers/",
    format='parquet'
) }}

select
    customer_id,
    first_name,
    last_name,
    email,
    country,
    signup_date,
    customer_tier,
    current_timestamp as ingested_at
from {{ ref('raw_customers') }}
