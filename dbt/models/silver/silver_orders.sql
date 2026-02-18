-- Silver layer: cleaned and validated orders
{{ config(
    materialized='external',
    location="abfss://medallion@" ~ var('adls_account') ~ ".dfs.core.windows.net/silver/orders/",
    format='parquet'
) }}

select
    order_id,
    order_date,
    product_name,
    quantity,
    unit_price,
    lower(trim(status)) as status,
    quantity * unit_price as line_total,
    current_timestamp as transformed_at
from {{ ref('bronze_raw_orders') }}
where
    quantity > 0
    and unit_price > 0
