
WITH stg_orders AS (
    SELECT * 
    FROM {{ ref('stg_orders') }}
),

renamed_casted AS (
    SELECT
        order_id 
        , user_id 
        , promo_id
        , address_id
        , created_at as created_at_utc
        , order_cost as item_order_cost_usd
        , shipping_cost as shipping_cost_usd
        , order_total as total_order_cost_usd
        , tracking_id
        , shipping_service
        , estimated_delivery_at as estimated_delivery_at_utc
        , delivered_at as delivered_at_utc
	    , DATEDIFF(day, created_at, delivered_at) AS days_to_deliver
        , status as status_order
        , _fivetran_synced as date_load
    FROM stg_orders
    )

SELECT * FROM renamed_casted