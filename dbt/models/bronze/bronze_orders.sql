-- ============================================================
-- models/bronze/bronze_orders.sql
-- ============================================================
-- 🟤 BRONZE LAYER: Raw data ingestion
--
-- This model reads raw CSV data and stores it as-is.
-- No transformations yet — we preserve the original data.
-- Think of this as your "source of truth" archive.
-- ============================================================

with source_data as (

    select
        -- Load every column from the raw seed file
        order_id,
        customer_id,
        product_name,
        quantity,
        unit_price,
        order_date,
        status,

        -- Add metadata columns (audit trail)
        current_timestamp   as _ingested_at,
        'csv_seed'          as _source_system

    from {{ ref('raw_orders') }}    -- references our seed file

)

select * from source_data
