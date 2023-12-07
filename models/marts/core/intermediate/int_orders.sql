{{
  config(
    materialized='view'
  )
}}

with stg_order_items as (
    select * from {{ ref('stg_order_items') }}
),

stg_orders as (
    select * from {{ ref('stg_orders') }}
),

-- an 'intermediate model' to full outer join stg_orders and stg_order_items

sub_int_orders as (
    select

        a.order_id,
        b.user_id,
        b.address_id,
        a.product_id,
        a.quantity_sold,                                   --5
        b.promo_id,
        b.status,
        b.shipping_service,
        b.created_at_utc::date as created_at_date,
        b.created_at_utc,                                  --10
        b.estimated_delivery_at_utc,
        b.delivered_at_utc

    from stg_order_items as a
    full outer join stg_orders as b on b.order_id = a.order_id
),

-- the next 3 queries allows ut to have a monthly table with "quantity_sold" and "operative_costs" per month, 
-- the Goal? Later join the operative costs to the intermediate model and have a value per line of order_product.

int_summary_orders as(
    select
        date_trunc('month', created_at_utc) as month,
        sum(quantity_sold) as monthly_quantity_sold
    from sub_int_orders
    group by 1
),

oper_accounting as(
    select 
        date_trunc('month', invoice_date) as month,
        sum(total) as total_operative_usd
    from {{ ref('accounting') }} 
    where scope = 'operative'
    group by 1
),

int_operative_costs as(
    select
        a.month,
        a.total_operative_usd,
        b.monthly_quantity_sold
    from oper_accounting a
    left join int_summary_orders b on b.month=a.month
),

int_orders as(
    select
        a.*,
        (b.total_operative_usd / b.monthly_quantity_sold)::decimal(24,4) as diluded_operative_cost_per_product
    from sub_int_orders a
    left join int_operative_costs b on b.month = date_trunc('month', a.created_at_utc)
)

select * from int_orders
union all
select *
from (
        values (
            'no_order',
            'no_user',
            'no_address',
            'no_product',
            '0',
            'no_promo',
            'no_status',
            'not_assigned',
            '1900-01-01',
            '1900-01-01',
            null,
            null,
            0
        )
)
