with products as(

    select * 
    from {{ source('sql_server_dbo', 'products') }}
),

renamed_casted as(
select
    product_id,
    price,
    name,
    inventory,
    _FIVETRAN_SYNCED as date_load
from products
)

select *  from renamed_casted


