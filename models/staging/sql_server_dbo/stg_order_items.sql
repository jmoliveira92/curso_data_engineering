
{{ config(
    materialized='incremental',
    unique_key = 'order_id',
    on_schema_change='fail'
    ) 
    }}


with order_items as(

    select * 
    from {{ source('src_sql_server_dbo', 'order_items') }}

{% if is_incremental() %}

	  where _fivetran_synced > (select max(date_load) from {{ this }}) 

      --{{this}} represents the model that was materialized before run the incremental query/feature.

{% endif %}
),

renamed_casted as(
select
    order_id::varchar(50) as order_id,
    product_id::varchar(50) as product_id,
    quantity::int as quantity_sold,                -- potencial field for a measure
    _FIVETRAN_SYNCED as date_load
from order_items
)

select *  from renamed_casted