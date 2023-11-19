with orders as(

    select *
    from {{ source('src_sql_server_dbo', 'orders') }}
),

stg_orders as(

    select
    -- keys
        order_id::varchar(50) as order_id,
        user_id::varchar(50) as user_id,
        address_id::varchar(50) as address_id,
        promo_id::varchar(50) as promo_id,
    -- deliver related
        status::varchar(50) as status,
        tracking_id::varchar(50) as tracking_id,
        shipping_service::varchar(50) as shipping_service,
    -- dates
        cast(created_at as date) as created_at_utc,
        estimated_delivery_at::timestamp as estimated_delivery_at_utc,
        delivered_at::timestamp as delivered_at_utc,
    -- measures
        order_cost::decimal(24,2) as order_cost_usd,
        shipping_cost::decimal(24,2) as shipping_cost_usd,
        order_total::decimal(24,2) as order_total_usd,
        _fivetran_synced::timestamp as date_load
    from orders
)


select *  from stg_orders
