with orders as(

    select *
    from {{ source('sql_server_dbo', 'orders') }}
),

stg_orders as(

    select
        order_id::varchar(50) as order_id,
        user_id::varchar(50) as user_id,
        address_id::varchar(50) as address_id_id,
        case when promo_id = '' then null
        case when promo_id is null then 'not applied'
        else {{dbt_utils.surrogate_key(promo_id)}},
    from orders

)


select *  from orders
