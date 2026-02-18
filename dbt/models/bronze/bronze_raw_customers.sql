-- Bronze layer: raw customers loaded from seed
-- No transformations — exact copy with ingestion timestamp
{{ config(materialized='table') }}

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
