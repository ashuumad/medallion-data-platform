-- ============================================================
-- models/gold/gold_sales_summary.sql
-- ============================================================
-- 🟡 GOLD LAYER: Business-ready aggregations
--
-- This model answers real business questions:
--   📊 Revenue by product
--   📅 Sales trends over time
--   🏆 Top performing products
--
-- This is what dashboards and reports read from.
-- ============================================================

with silver as (

    select * from {{ ref('silver_orders') }}
    where status = 'completed'      -- only count completed orders

),

-- ── Daily sales aggregation ──────────────────────────────────
daily_sales as (

    select
        order_date,
        product_name,
        count(distinct order_id)        as num_orders,
        sum(quantity)                   as total_units_sold,
        sum(line_total)                 as total_revenue,
        avg(unit_price)                 as avg_unit_price,
        min(unit_price)                 as min_price,
        max(unit_price)                 as max_price

    from silver
    group by order_date, product_name

),

-- ── Add running totals (cumulative revenue) ──────────────────
with_running_total as (

    select
        *,
        sum(total_revenue) over (
            partition by product_name
            order by order_date
            rows between unbounded preceding and current row
        ) as cumulative_revenue

    from daily_sales

)

select
    order_date,
    product_name,
    num_orders,
    total_units_sold,
    round(total_revenue, 2)         as total_revenue,
    round(avg_unit_price, 2)        as avg_unit_price,
    round(cumulative_revenue, 2)    as cumulative_revenue,
    current_timestamp               as _refreshed_at

from with_running_total
order by order_date desc, total_revenue desc
