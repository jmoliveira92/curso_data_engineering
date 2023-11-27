with stg_events as(
    select 
        event_id,
        session_id,
        user_id,
        event_type,
        product_id,
        order_id,
        created_at_utc as created_at_utc,
        created_at_utc::date as created_at_utc_date,
        page_url
    from {{ ref('stg_events') }}
),
dim_customers as (
    select * from {{ ref('dim_customers') }}
),
dim_event_types as(
    select * from {{ ref('dim_event_types') }}
),
dim_products as(
    select * from {{ ref('dim_products') }}
),
dim_sales_orders as(
    select * from {{ ref('dim_sales_orders') }}
),
dim_date as(
    select * from {{ ref('dim_date') }}
),

fact_events as(
    select
        a.event_id,
        a.session_id,
        b.user_sk,
        c.event_types_sk,
        a.event_type, --optional, just here for readability
        d.product_sk,
        e.order_sk,
        f.date_key,
        a.created_at_utc,
        a.page_url

    from stg_events a 
    left join dim_customers b on b.user_id = a.user_id
    left join dim_event_types c on c.event_type= a.event_type
    left join dim_products d on d.product_id = a.product_id
    left join dim_sales_orders e on e.order_id = a.order_id
    left join dim_date f on f.date_day = a.created_at_utc_date
    
    order by 2,9
)
select * from fact_events
