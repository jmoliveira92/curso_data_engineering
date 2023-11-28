with stg_order_items as(
    select * from {{ ref('stg_order_items') }}
),

stg_orders as(
select * from {{ ref('stg_orders') }}
),

-- a 'intermediate model' to full outer join stg_orders and stg_order_items
int_sales_orders as(
    select
        a.order_id,
        b.user_id,
        b.address_id,
        a.product_id,
        a.quantity_sold,
        b.promo_id,
        b.created_at_utc::date as created_at_date,
        b.created_at_utc,
        b.estimated_delivery_at_utc,
        b.delivered_at_utc

    from stg_order_items a
    full outer join stg_orders b on b.order_id = a.order_id
),

dim_date as (
    select* from {{ ref('dim_date') }}
),

dim_customers as (
    select* from {{ ref('dim_customers') }}
),

dim_addresses as (
    select* from {{ ref('dim_addresses') }}
),

dim_sales_orders as(
    select * from {{ ref('dim_sales_orders') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
),

dim_promos as (
    select * from {{ ref('dim_promos') }}
),

/* this cte querys 2 tables aiming to allow to 'transport' the discount_unit from 'dim_promo's' to the 'stg_order_items'
join_orders_promos_discount as (
select
    a.order_id, -- stg_order_items
    b.discount_unit
from dim_sales_orders a
left join dim_promos b on b.promo_sk=a.promo_sk
),
*/

-- in order to calculate the weight shipping_cost per type of product, this cte counts the total number of products on each order_id
count_order_items as( 

    select
        order_id,
        sum(quantity_sold) as total_quantity_sold
    from int_sales_orders
    group by 1
    order by 1
),

fact_sales_orders_details as(

    select
    --keys
        b.date_key,
        c.user_sk,
        d.address_sk,
        e.order_sk,
        f.product_sk,
    
    -- measures (money related)
        a.quantity_sold,
        f.unit_price_usd,
        -- total_sales_usd is the quantity_sold * unit_price_usd
        (a.quantity_sold*f.unit_price_usd) as gross_sales_usd,

        g.discount_unit as discount_decimal,
        -- extended discount amount  = (discount_usd/100) * (quantity_sold*unit_price_usd)
        (g.discount_unit * (a.quantity_sold*f.unit_price_usd))::decimal(24,2) as discount_amount_usd,
        -- weighted shipping_cost
        (k.shipping_cost_usd*(a.quantity_sold/h.total_quantity_sold))::decimal(24,2) as shipping_cost_usd,

        --net sales usd (gross_sales_usd - discount_amount_usd + shipping_cost_usd)
        ((a.quantity_sold*f.unit_price_usd) - (g.discount_unit * (a.quantity_sold*f.unit_price_usd)) + (k.shipping_cost_usd*(a.quantity_sold/h.total_quantity_sold)))::decimal(24,2) as net_sales_amout,

    -- measures (delivery/shipping related)
        {{ dbt.datediff("a.created_at_utc", "a.delivered_at_utc", "day") }} as days_to_deliver,
        {{ dbt.datediff("a.created_at_utc", "a.delivered_at_utc", "day") }} as deliver_precision_days,
        
    -- just in case we need at the future
        a.created_at_utc
        --a.estimated_delivery_at_utc,
        --a.delivered_at_utc

    from int_sales_orders a

    left join dim_date b on b.date_day = a.created_at_date
    left join dim_customers c on c.user_id = a.user_id
    left join dim_addresses d on d.address_id = a.address_id
    left join dim_sales_orders e on e.order_id = a.order_id
    left join dim_products f on f.product_id = a.product_id
    left join dim_promos g on g.promo_id = a.promo_id
    left join count_order_items h on h.order_id = a.order_id
    left join stg_orders k on k.order_id = a.order_id

)

select * from fact_sales_orders_details