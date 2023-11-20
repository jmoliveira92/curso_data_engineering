
{{ config(
    materialized='incremental',
    unique_key = 'order_id',
    on_schema_change='fail'
    ) 
    }}

with orders as(

    select *
    from {{ source('src_sql_server_dbo', 'orders') }}

{% if is_incremental() %}

	  where _fivetran_synced > (select max(_fivetran_synced) from {{ this }}) 

      --{{this}} representa o modelo que está actualmente materializado (o modelo que está actualmente no DW)

{% endif %}

),

stg_orders as(

    select
    -- keys
        order_id::varchar(50) as order_id,
        user_id::varchar(50) as user_id,
        address_id::varchar(50) as address_id,
        
        (case when promo_id = '' then 'no_promo'
             when promo_id is null then 'no_promo'
             else promo_id end)::varchar(50) as promo_id,

    -- deliver related
        status::varchar(50) as status,

        (case when tracking_id = '' then 'not_assigned'
             when tracking_id is null then 'not_assigned'
             else tracking_id end)::varchar(50) as tracking_id,

        (case when shipping_service = '' then 'not_assigned'
             when shipping_service is null then 'not_assigned'
             else shipping_service end)::varchar(50) as shipping_service,
    -- dates
        cast(created_at as date) as created_at_utc,
        to_char(created_at, 'YYYY-MM-DD HH24:MM') as created_at_utc_2,
        
        estimated_delivery_at::timestamp as estimated_delivery_at_utc,
        to_char(estimated_delivery_at, 'YYYY-MM-DD HH24:MM') as estimated_delivery_at_utc_2,

        delivered_at::timestamp as delivered_at_utc,
        to_char(delivered_at, 'YYYY-MM-DD HH24:MM') as delivered_at_utc_2,

    -- measures
        order_cost::decimal(24,2) as order_cost_usd,
        shipping_cost::decimal(24,2) as shipping_cost_usd,
        order_total::decimal(24,2) as order_total_usd,
        _fivetran_synced::timestamp as date_load
    from orders
)


select *  from stg_orders
