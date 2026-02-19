-- Silver layer: cleaned and validated orders

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
