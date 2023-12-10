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

--- veeeer se faz sentido   !!!!

    {% if is_incremental() %}
	  where date_load > (select max(date_load) from {{ this }}) 
{% endif %}

),
dim_users as (
    select * from {{ ref('dim_users') }}
),
dim_products as(
    select * from {{ ref('dim_products') }}
),
int_orders as(
    select * from {{ ref('int_orders') }}
),
dim_date as(
    select * from {{ ref('dim_date') }}
),

fact_events as(
    select
        a.event_id,
        a.session_id,
        b.user_sk,
        a.event_type,
        d.product_sk,
        a.order_id,
        f.date_key,
        a.created_at_utc,
        a.created_at_utc::time as time
        --a.page_url

    from stg_events a 
    left join dim_users b on b.user_id = a.user_id
    left join dim_products d on d.product_id = a.product_id
    --left join int_orders e on e.order_id = a.order_id
    left join dim_date f on f.date_day = a.created_at_utc_date
    
    order by 2,9
)
select * from fact_events


