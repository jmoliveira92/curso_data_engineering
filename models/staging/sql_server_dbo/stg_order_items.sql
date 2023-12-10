
{{ config(
    materialized='incremental',
    unique_key = 'id',
    on_schema_change='fail',
    tags = ["incremental_orders"],
)
    }}


with order_items as(

    select * 
    from {{ ref('src_order_items_snap') }}
    
    {% if is_incremental() %}
        where _fivetran_synced > (select max(date_load) from {{ this }}) 
    {% endif %}
),

renamed_casted as(
select
    id::varchar(100) as id,
    order_id::varchar(50) as order_id,
    product_id::varchar(50) as product_id,
    quantity::int as quantity_sold,                -- potencial field for a measure
    _fivetran_synced as date_load
from order_items
where dbt_valid_to is null
)

select *  from renamed_casted