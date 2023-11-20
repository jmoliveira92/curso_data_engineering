with dim_customers as (
    select * from {{ ref('dim_customers') }}
),

dim_products as(
    select * from {{ ref('dim_products') }}
),

dim_sales_orders as(
    select * from {{ ref('dim_sales_orders') }}
),

stg_events as(
    select * from {{ ref('stg_events') }}
),

dim_events as(
    select
        {{dbt_utils.generate_surrogate_key(['stg_events.event_id'])}} as event_sk,
        {{dbt_utils.generate_surrogate_key(['stg_events.session_id'])}} as session_sk,
        dim_customers.user_sk,
        stg_events.event_type,
        dim_products.product_sk,
        dim_sales_orders.order_sk,
        stg_events.created_at_utc,
        stg_events.page_url,
        stg_events.date_load
        
    from stg_events
    left join {{ ref('dim_sales_orders') }} on dim_sales_orders.order_id = stg_events.order_id
    left join {{ ref('dim_customers') }}    on dim_customers.user_id = stg_events.user_id
    left join {{ ref('dim_products') }}     on dim_products.product_id = stg_events.product_id
    
)

select * from dim_events