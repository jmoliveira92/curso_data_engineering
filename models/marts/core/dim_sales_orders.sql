with stg_orders as (
    select * from {{ ref('stg_orders') }}
),

dim_sales_orders as (
    select
    -- keys
        {{dbt_utils.default__generate_surrogate_key(['order_id'])}} as order_sk,
        order_id,
        dim_customers.user_sk,
        dim_addresses.address_sk,
        case when dim_promos.promo_sk is null then 'no_promo'
             else dim_promos.promo_sk end as promo_sk,
    -- deliver related
        dim_status.status_sk,
        case when tracking_id = '' then 'not_defined_yet'
             when tracking_id is null then 'not_defined_yet'
             else tracking_id end as tracking_id,
        shipping_service,
    -- dates
        stg_orders.created_at_utc,
        stg_orders.estimated_delivery_at_utc,
        stg_orders.delivered_at_utc,
        DATEDIFF(day, stg_orders.created_at_utc, stg_orders.delivered_at_utc) AS days_to_deliver,
        DATEDIFF(day, stg_orders.estimated_delivery_at_utc, stg_orders.delivered_at_utc) AS delay_deliver_days,
    -- measures
        shipping_cost_usd,
        stg_orders.date_load
    from stg_orders
    left join {{ ref('dim_customers') }} on dim_customers.user_id = stg_orders.user_id
    left join {{ ref('dim_addresses') }} on dim_addresses.address_id = stg_orders.address_id
    left join {{ ref('dim_promos') }} on dim_promos.promo_id = stg_orders.promo_id
    left join {{ ref('dim_status') }} on dim_status.status = stg_orders.status

)

select * from dim_sales_orders