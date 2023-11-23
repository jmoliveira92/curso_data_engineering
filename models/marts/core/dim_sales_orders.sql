with stg_orders_snapshot as (
    select * 
    from {{ ref('stg_orders_snapshot') }}
    where dbt_valid_to is null
),

no_orders_row as(
    select * from (values ('no_order','no_order','19000101','no_user','no_address','no_promo','no_status','not_assigned','not_assigned',current_timestamp(),null,null))

),

--this cte serves to select the relevant columns from the snapshot to construct our dimension
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

    -- date and time
        created_at_utc::timestamp as created_at_utc,
        estimated_delivery_at_utc::timestamp as estimated_delivery_at_utc,
        delivered_at_utc::timestamp as delivered_at_utc
    
    from stg_orders_snapshot

),

--select * from stg_orders_snapshot_2


dim_sales_orders as (
    select
    -- keys
        {{dbt_utils.default__generate_surrogate_key(['order_id'])}} as order_sk,
        a.order_id,
        b.date_key,
        c.user_sk,
        d.address_sk,
        e.promo_sk,
    -- deliver related
        f.status_sk,
        a.tracking_id,
        g.shipping_service_sk,
    -- dates
        a.created_at_utc as created_at_utc,
        a.estimated_delivery_at_utc as estimated_delivery_at_utc,
        a.delivered_at_utc as delivered_at_utc      

    from stg_orders_snapshot_2 a

    left join {{ ref('dim_date') }} b on b.date_day = a.created_at_utc::date
    left join {{ ref('dim_customers') }} c on c.user_id = a.user_id
    left join {{ ref('dim_addresses') }} d on d.address_id = a.address_id
    left join {{ ref('dim_promos') }} e on e.promo_id = a.promo_id
    left join {{ ref('dim_status') }} f on f.status = a.status
    left join {{ ref('dim_shipping_service') }} g on g.shipping_service = a.shipping_service

    order by 9 desc
)

select * from dim_sales_orders
union all
select * from no_orders_row
