with order_items as(

    select * 
    from {{ source('src_sql_server_dbo', 'order_items') }}
),

renamed_casted as(
select
    order_id::varchar(50) as order_id,
    product_id::varchar(50) as product_id,
    quantity::int as quantity_sold,
    _FIVETRAN_SYNCED as date_load
from order_items
)

select *  from renamed_casted