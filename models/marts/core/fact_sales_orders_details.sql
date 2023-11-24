with stg_order_items as(
    select * from {{ ref('stg_order_items') }}
),

stg_orders as(
select * from {{ ref('stg_orders') }}
),

dim_promos as (
    select * from {{ ref('dim_promos') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
),

dim_sales_orders as(
    select * from {{ ref('dim_sales_orders') }}
),

-- this cte querys 2 tables aiming to allow to 'transport' the discount_unit from 'dim_promo's' to the 'stg_order_items'
join_orders_promos_discount as (
select
    a.order_id, -- stg_order_items
    b.discount_unit
from dim_sales_orders a
left join dim_promos b on b.promo_sk=a.promo_sk
),

-- in order to calculate the weight shipping_cost per type of product, this cte counts the total number of products on each order_id
count_order_items as( 

    select
        order_id,
        sum(quantity_sold) as total_quantity_sold
    from stg_order_items
    group by 1
    order by 1
),

fact_sales_order_details as(

    select
    --keys
        b.order_sk,
        d.product_sk,
    
    -- measures (money related)
        a.quantity_sold,
        d.unit_price_usd,
        c.discount_unit as discount_usd,
        -- total_sales_usd is the quantity_sold * unit_price_usd
        (a.quantity_sold*d.unit_price_usd) as gross_sales_usd,
        -- extended discount amount  = (discount_usd/100) * (quantity_sold*unit_price_usd)
        (c.discount_unit * (a.quantity_sold*d.unit_price_usd))::decimal(24,2) as discount_amount_usd,
        -- weighted shipping_cost
        (f.shipping_cost_usd*(a.quantity_sold/e.total_quantity_sold))::decimal(24,2) as shipping_cost_usd,

        --net sales usd (gross_sales_usd - discount_amount_usd + shipping_cost_usd)
        ((a.quantity_sold*d.unit_price_usd) - (c.discount_unit * (a.quantity_sold*d.unit_price_usd)) + (f.shipping_cost_usd*(a.quantity_sold/e.total_quantity_sold)))::decimal(24,2) as net_sales_amout,

    -- measures (delivery/shipping related)
        {{ dbt.datediff("b.created_at_utc", "b.delivered_at_utc", "day") }} as days_to_deliver,
        {{ dbt.datediff("b.created_at_utc", "b.delivered_at_utc", "day") }} as deliver_precision_days

    from stg_order_items a

    left join dim_sales_orders b on b.order_id = a.order_id
    left join join_orders_promos_discount c on c.order_id = a.order_id
    left join dim_products d on d.product_id = a.product_id
    left join count_order_items e on e.order_id = a.order_id
    left join stg_orders f on f.order_id = a.order_id
)

select * from fact_sales_order_details
