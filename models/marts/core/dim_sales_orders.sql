with stg_orders_snapshot as (
    select * 
    from {{ ref('stg_orders_snapshot') }}
    where dbt_valid_to is null
),

stg_orders_snapshot_2 as(

    select
        -- keys
        order_id,
        user_id,
        address_id,
        promo_id,
       
    --  delivery/shipping related
        status,
        tracking_id,
        shipping_service,

    -- dates
        created_at_utc::date as order_date_utc,
        created_at_utc::time as order_time_utc,     
        estimated_delivery_at_utc::date as estimated_delivery_at_date_utc,
        estimated_delivery_at_utc::time as estimated_delivery_at_time_utc,
        delivered_at_utc::date as delivered_at_date_utc,
        delivered_at_utc::time as delivered_at_time_utc,

    -- measures: en principio vamos ignorar "order_cost" porque vamos calcular manualmente en la fact_sales_orders_details,
    -- con excepción de "shipping_cost" que es como un atributo de la dim_orders
        
        --order_cost_usd,
        shipping_cost_usd,
        --order_total_usd,
        _fivetran_synced as date_load
    
    from stg_orders_snapshot

),

--select * from stg_orders_snapshot_2


dim_sales_orders as (
    select
    -- keys
        {{dbt_utils.default__generate_surrogate_key(['order_id'])}} as order_sk,
        order_id,
        dim_date.date_key,
        dim_customers.user_sk,
        dim_addresses.address_sk,
        stg_orders_snapshot_2.promo_id, -- eliminar esta coluna porque nao é necessario
        dim_promos.promo_sk, -- lidar com o NULL, foi alterada a tabla "stg_orders" mas apenas de 
        --existir "promo_sk" para NULL, este valor nao aparece...

    -- deliver related
        stg_orders_snapshot_2.status,
        dim_status.status_sk,

        stg_orders_snapshot_2.tracking_id,
        
        stg_orders_snapshot_2.shipping_service,
        dim_shipping_service.shipping_service_sk,
    -- dates
        
        stg_orders_snapshot_2.order_date_utc,
        stg_orders_snapshot_2.estimated_delivery_at_date_utc,
        stg_orders_snapshot_2.delivered_at_date_utc,

        stg_orders_snapshot_2.order_time_utc,
        stg_orders_snapshot_2.estimated_delivery_at_time_utc, 
        stg_orders_snapshot_2.delivered_at_time_utc,

        case when stg_orders_snapshot_2.delivered_at_date_utc is null then '-9999'
             else DATEDIFF(day, stg_orders_snapshot_2.order_date_utc, stg_orders_snapshot_2.delivered_at_date_utc) end as days_to_deliver,

        case when stg_orders_snapshot_2.estimated_delivery_at_date_utc is null then '-9999'
             when stg_orders_snapshot_2.delivered_at_date_utc is null then '-9999'
             else DATEDIFF(day, stg_orders_snapshot_2.estimated_delivery_at_date_utc, stg_orders_snapshot_2.delivered_at_date_utc) end as delay_deliver_days,
        
    -- measures: en principio vamos ignorar porque vamos calcular manualmente en la fact_sales_orders_details,
    -- con excepción de "shipping_cost" que es como un atributo de la order
        stg_orders_snapshot_2.shipping_cost_usd,
        stg_orders_snapshot_2.date_load
        
    from stg_orders_snapshot_2

    left join {{ ref('dim_customers') }} on dim_customers.user_id = stg_orders_snapshot_2.user_id
    left join {{ ref('dim_addresses') }} on dim_addresses.address_id = stg_orders_snapshot_2.address_id
    left join {{ ref('dim_promos') }} on dim_promos.promo_id = stg_orders_snapshot_2.promo_id
    left join {{ ref('dim_status') }} on dim_status.status = stg_orders_snapshot_2.status
    left join {{ ref('dim_date') }} on dim_date.date_day = stg_orders_snapshot_2.order_date_utc
    left join {{ ref('dim_shipping_service') }} on dim_shipping_service.shipping_service = stg_orders_snapshot_2.shipping_service

    order by 9 desc
)

select * from dim_sales_orders

