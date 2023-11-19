with products as(

    select * 
    from {{ source('src_sql_server_dbo', 'products') }}
),

stg_products as(
select
    product_id::varchar(50) as product_id,
    name::varchar(50) as product_name,
    price::decimal(24,2) as product_price_usd,
    inventory::int as inventory,
    _FIVETRAN_SYNCED as date_load
from products
)

select *  from stg_products


