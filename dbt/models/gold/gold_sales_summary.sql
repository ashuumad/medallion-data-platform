-- Gold layer: daily sales summary by product
{{ config(
    materialized='external',
    location='az://medallion/gold/sales/',
    format='parquet'
) }}

select
    order_date,
    product_name,
    count(order_id)      as num_orders,
    sum(quantity)        as total_units,
    sum(line_total)      as total_revenue
from {{ ref('silver_orders') }}
where status in ('completed', 'complete')
group by order_date, product_name
order by order_date, product_name
