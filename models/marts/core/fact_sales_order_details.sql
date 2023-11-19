with stg_order_items as(
    select * from {{ ref('stg_order_items') }}
),

stg_orders as(
    select * from {{ ref('stg_orders') }}
),

stg_promos as (
    select * from {{ ref('dim_promos') }}
),

stg_products as (
    select * from {{ ref('dim_products') }}
),

dim_sales_orders as(
    select * from {{ ref('dim_sales_orders') }}
),

int_discount as(
    select * from {{ ref('int_discount') }}
),

fact_sales_order_details as(

    select
        dim_sales_orders.order_sk as order_sk,
        stg_order_items.order_id as order_id,
        dim_products.product_sk as product_sk,
        stg_order_items.quantity_sold,
        dim_products.unit_price_usd,
        -- total_sales_usd is the quantity x price
        cast(stg_order_items.quantity_sold*dim_products.unit_price_usd as decimal(24,2)) as gross_sales_usd,

        -- extended discount amount  = (discount/100) * (quantity*unit price)
        int_discount.discount * cast(stg_order_items.quantity_sold*dim_products.unit_price_usd as decimal(24,2)) as discount_usd

        --net sales usd
        ( cast(stg_order_items.quantity_sold*dim_products.unit_price_usd as decimal(24,2))) -(int_discount.discount * cast(stg_order_items.quantity_sold*dim_products.unit_price_usd as decimal(24,2))) as net_sales_amout


    from stg_order_items
    left join {{ ref('dim_sales_orders') }} on dim_sales_orders.order_id = stg_order_items.order_id
    left join {{ ref('dim_products') }} on dim_products.product_id = stg_order_items.product_id
    left join {{ ref('dim_promos') }} on dim_sales_orders.promo_sk = dim_promos.promo_sk
    left join {{ ref('int_discount') }} on stg_order_items.order_id = int_discount.order_id
)

select * from fact_sales_order_details