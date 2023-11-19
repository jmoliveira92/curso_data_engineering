with stg_order_items as(
    select * from {{ ref('stg_order_items') }}
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

fact_sales_order_details as(

    select
        dim_sales_orders.order_sk as order_sk,
        stg_order_items.order_id as order_id,
        dim_products.product_sk as product,
        stg_order_items.quantity,
        dim_products.product_price_usd


    from stg_order_items
    join {{ ref('dim_sales_orders') }} on dim_sales_orders.order_id = stg_order_items.order_id,
    join {{ ref('dim_products') }} on dim_products.product_id = stg_order_items.product_id
)

select * from fact_sales_order_details