with order_items as(

    select * 
    from {{ source('sql_server_dbo', 'order_items') }}
),

renamed_casted as(
select
    order_id,
    product_id,
    quantity,
    _FIVETRAN_SYNCED as date_load
from order_items
)

select *  from renamed_casted