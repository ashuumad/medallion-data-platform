-- Bronze layer: raw orders loaded from seed
-- Materializes as-is with no transformations
{{ config(
    materialized='external',
    location='az://medallion/bronze/orders/',
    format='parquet'
) }}

select
    order_id,
    order_date,
    product_name,
    quantity,
    unit_price,
    status,
    current_timestamp as ingested_at
from {{ ref('raw_orders') }}
