with stg_orders as (
    select * from {{ ref('stg_orders') }}
),

dim_sales_orders as (
    select
    -- keys
        {{dbt_utils.default__generate_surrogate_key(['order_id'])}} as order_sk,
        order_id,
        dim_date.date_key,
        dim_customers.user_sk,
        dim_addresses.address_sk,
        stg_orders.promo_id, -- eliminar esta coluna porque nao é necessario
        dim_promos.promo_sk, -- lidar com o NULL, foi alterada a tabla "stg_orders" mas apenas de 
        --existir "promo_sk" para NULL, este valor nao aparece...

    -- deliver related
        stg_orders.status,
        dim_status.status_sk,

        stg_orders.tracking_id,
        
        stg_orders.shipping_service,
        dim_shipping_service.shipping_service_sk,
    -- dates
        
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
    left join {{ ref('dim_date') }} on dim_date.date_day = stg_orders.created_at_utc
    left join {{ ref('dim_shipping_service') }} on dim_shipping_service.shipping_service = stg_orders.shipping_service

    order by 9 desc
)

select * from dim_sales_orders