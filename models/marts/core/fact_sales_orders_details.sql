
with int_orders as(    
    select * from {{ ref('int_orders') }}
),

dim_date as (
    select* from {{ ref('dim_date') }}
),

dim_users as (
    select* from {{ ref('dim_users') }}
),

dim_addresses as (
    select* from {{ ref('dim_addresses') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
),

dim_promos as (
    select * from {{ ref('dim_promos') }}
),
dim_shipping_service as(
    select * from {{ ref('dim_shipping_service') }}
),

int_count_orders_quantity as(
    select * from {{ ref('int_count_orders_quantity') }}
),

fact_sales_orders_details as(

    select
    --keys
        b.date_key,
        {{dbt_utils.generate_surrogate_key(['a.user_id', 'a.order_id' ,'a.product_id'])}} as order_sk,
        c.user_sk,  
        d.address_sk,
        a.status,
        i.shipping_service_sk,
        f.product_sk,
        a.quantity_sold,
        f.unit_price_usd, --9
    
    -- measures (money related)

        -- total_sales_usd is the quantity_sold * unit_price_usd
        (a.quantity_sold*f.unit_price_usd) as gross_sales_usd,

        -- discount_amount_usd  = (discount_usd/100) * (quantity_sold*unit_price_usd)
        (g.discount_unit * (a.quantity_sold*f.unit_price_usd))::decimal(24,2) as discount_amount_usd,
        
        -- shipping_revenue_usd = calculate weighted shipping_revenue per line of product
        round((k.shipping_cost_usd*(a.quantity_sold/h.total_quantity_sold)),2)::decimal(24,2) as shipping_revenue_usd,

        -- shipping_cost_usd (agreement)
        round((k.shipping_cost_usd*(a.quantity_sold/h.total_quantity_sold))*(i.shipping_agreement),2)::decimal(24,2) as shipping_cost_usd,

        -- product_cost
        round(a.quantity_sold*f.product_cost_usd,2) as product_cost_usd,

        --diluded operative cost
        a.quantity_sold * a.diluded_operative_cost_per_product as diluded_oper_cost,

        --net sales usd = gross_sales_usd - discount_amount_usd + shipping_revenue_usd - shipping_cost_usd - product_cost -- operative costs
        round((a.quantity_sold*f.unit_price_usd) - (g.discount_unit * (a.quantity_sold*f.unit_price_usd)) + (k.shipping_cost_usd*(a.quantity_sold/h.total_quantity_sold)) - (k.shipping_cost_usd*(a.quantity_sold/h.total_quantity_sold))*(i.shipping_agreement) - (a.quantity_sold*f.product_cost_usd) - (a.quantity_sold * a.diluded_operative_cost_per_product) , 2) as net_sales_amout,

    -- measures (delivery/shipping related)
        {{ dbt.datediff("a.created_at_utc", "a.delivered_at_utc", "day") }} as days_to_deliver,
        {{ dbt.datediff("a.estimated_delivery_at_utc", "a.delivered_at_utc", "day") }} as deliver_precision_days,
        
    -- just in case we need at the future
        a.created_at_utc,
        a.created_at_utc::time as time
        --a.estimated_delivery_at_utc,
        --a.delivered_at_utc

    from int_orders a

    left join dim_date b on b.date_day = a.created_at_date
    left join dim_users c on c.user_id = a.user_id
    left join dim_addresses d on d.address_id = a.address_id
    left join dim_products f on f.product_id = a.product_id
    left join dim_promos g on g.promo_id = a.promo_id
    left join int_count_orders_quantity h on h.order_id = a.order_id
    left join stg_orders k on k.order_id = a.order_id
    left join dim_shipping_service i on i.shipping_service = a.shipping_service

)

select * from fact_sales_orders_details order by 16

--select sum(diluded_oper_cost) from fact_sales_orders_details