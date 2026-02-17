-- ============================================================
-- models/silver/silver_orders.sql
-- ============================================================
-- ⚪ SILVER LAYER: Cleaned & validated data
--
-- This model takes Bronze data and:
--   ✅ Removes duplicates
--   ✅ Fixes data types
--   ✅ Filters out bad/invalid records
--   ✅ Standardizes text fields
--   ✅ Calculates derived fields
-- ============================================================

with bronze as (

    select * from {{ ref('bronze_orders') }}

),

cleaned as (

    select
        -- Cast to correct types
        cast(order_id as integer)           as order_id,
        cast(customer_id as integer)        as customer_id,

        -- Standardize text: trim spaces, uppercase
        trim(upper(product_name))           as product_name,

        -- Validate numbers (reject negatives)
        case
            when cast(quantity as integer) > 0
            then cast(quantity as integer)
            else null
        end                                 as quantity,

        -- Round price to 2 decimal places
        round(cast(unit_price as decimal), 2) as unit_price,

        -- Parse date properly
        cast(order_date as date)            as order_date,

        -- Standardize status values
        case upper(trim(status))
            when 'COMPLETED'  then 'completed'
            when 'COMPLETE'   then 'completed'
            when 'PENDING'    then 'pending'
            when 'CANCELLED'  then 'cancelled'
            when 'CANCELED'   then 'cancelled'
            else 'unknown'
        end                                 as status,

        -- Derived field: total line value
        cast(quantity as integer)
            * round(cast(unit_price as decimal), 2) as line_total,

        -- Carry forward audit columns
        _ingested_at,
        _source_system,
        current_timestamp                   as _transformed_at

    from bronze

),

-- Remove exact duplicates (keep first occurrence)
deduplicated as (

    select *
    from cleaned
    qualify row_number() over (
        partition by order_id
        order by _ingested_at
    ) = 1

)

-- Final filter: only keep records with valid core fields
select *
from deduplicated
where
    order_id    is not null
    and customer_id is not null
    and quantity    is not null
    and unit_price  > 0
