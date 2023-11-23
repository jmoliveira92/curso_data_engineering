with products as(

    select * 
    from {{ source('src_sql_server_dbo', 'products') }}
),

stg_products as(
select
    product_id::varchar(50) as product_id,
    name::varchar(50) as product_name,
    price::decimal(24,2) as unit_price_usd,
    inventory::int as inventory,
    _FIVETRAN_SYNCED as date_load
from products
),
no_product_table as(

    SELECT  *
    FROM (VALUES (product_id, 'no_product'), (name, 'no_product'), (price, 0),(inventory, 0),(_FIVETRAN_SYNCED,current_timestamp()))

)

select *  from stg_products
union all
select * from no_product_table


