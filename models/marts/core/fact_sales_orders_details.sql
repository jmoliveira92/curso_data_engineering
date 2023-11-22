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

-- this cte querys int_discount, in order to bring the discount_percentage / 100
int_discount as(
    select * from {{ ref('int_discount') }}
),

-- this cte serves to JOIN the relevant columns from stg_order_items and stg_orders
int_fact as(  

    select

    -- keys
        stg_order_items.order_id,
        stg_orders.user_id,
        stg_orders.address_id,
        stg_orders.promo_id,
        stg_order_items.product_id,
        stg_order_items.quantity_sold,

    -- delivery/shipping related
        stg_orders.status,
        stg_orders.tracking_id,
        stg_orders.shipping_service,
        stg_orders.shipping_cost_usd,

    -- dates
        stg_orders.created_at_utc,
        stg_orders.estimated_delivery_at_utc,
        stg_orders.delivered_at_utc

    from stg_order_items
    left join {{ ref('stg_orders') }} as stg_orders on stg_order_items.order_id = stg_orders.order_id

    order by 1

),

-- this cte counts the total number of products on each order_id in order to calculate the weight shipping_cost per order
count_items_order as( 

    select
        stg_order_items.order_id,
        sum(stg_order_items.quantity_sold) as total_quantity_sold
    from stg_order_items
    group by 1
    order by 1

),

--select * from int_fact


fact_sales_order_details as(

    select

    --keys
        {{dbt_utils.generate_surrogate_key(['order_id'])}} as order_sk,
        dim_customers.user_sk,
        dim_addresses.address_sk,
        dim_promos.promo_sk,
    
    --measures
        int_fact.quantity_sold,
        dim_products.unit_price_usd,
        int_discount.discount as discount_usd,
        -- total_sales_usd is the quantity x price
        cast(int_fact.quantity_sold*dim_products.unit_price_usd as decimal(24,2)) as gross_sales_usd,
        -- extended discount amount  = (discount/100) * (quantity*unit price)
        int_discount.discount * cast(int_fact.quantity_sold*dim_products.unit_price_usd as decimal(24,2)) as discount_amount_usd,
        -- weighted shipping_cost
        int_fact.shipping_cost*(quantity_sold/total_quantity_sold) as shipping_cost_usd,

        --net sales usd (gross_sales_ud - discount_amount_usd + shipping_cost_usd)
        (cast(stg_order_items.quantity_sold*dim_products.unit_price_usd as decimal(24,2))) -(int_discount.discount * cast(stg_order_items.quantity_sold*dim_products.unit_price_usd as decimal(24,2))) + (int_fact.shipping_cost*(quantity_sold/total_quantity_sold)) as net_sales_amout,

    -- delivery/shipping related
        int_fact.status,
        int_fact.tracking_id,
        int_fact.shipping_service,
        int_fact.shipping_cost_usd

        
    from int_fact
    left join {{ ref('dim_customers') }} on int_fact.user_id = dim_customers.user_id
    left join {{ ref('dim_addresses') }} on int_fact.address_id = dim_addresses.address_id
    left join {{ ref('dim_promos') }} on int_fact.promo_id = dim_promos.promo_id
    left join {{ ref('dim_products') }} on int_fact.product_id = dim_products.product_id
    left join {{ ref('int_discount') }} on int_fact.order_id = int_discount.order_id

)

select * from fact_sales_order_details
/*
fact_sales_order_details as(

    select
    --keys
        dim_sales_orders.date_key as date_key,
        {{dbt_utils.default__generate_surrogate_key(['order_id'])}} as order_sk,            
        stg_order_items.order_id as order_id,  -- só para comparar, eliminar
        dim_products.product_sk as product_sk,
        stg_order_items.product_id as product_id, -- só para comparar, eliminar
        
        dim_customers.user_sk,
        

    --measures
        stg_order_items.quantity_sold,
        dim_products.unit_price_usd,
        -- total_sales_usd is the quantity x price
        cast(stg_order_items.quantity_sold*dim_products.unit_price_usd as decimal(24,2)) as gross_sales_usd,

        -- extended discount amount  = (discount/100) * (quantity*unit price)
        int_discount.discount * cast(stg_order_items.quantity_sold*dim_products.unit_price_usd as decimal(24,2)) as discount_usd,

        --net sales usd
        ( cast(stg_order_items.quantity_sold*dim_products.unit_price_usd as decimal(24,2))) -(int_discount.discount * cast(stg_order_items.quantity_sold*dim_products.unit_price_usd as decimal(24,2))) as net_sales_amout


    from stg_order_items
    
    left join {{ ref('dim_sales_orders') }} on dim_sales_orders.order_id = stg_order_items.order_id
    left join {{ ref('dim_products') }} on dim_products.product_id = stg_order_items.product_id
    left join {{ ref('dim_promos') }} on dim_sales_orders.promo_sk = dim_promos.promo_sk
    left join {{ ref('int_discount') }} on stg_order_items.order_id = int_discount.order_id
)

select * from fact_sales_order_details

*/