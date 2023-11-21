{% snapshot stg_orders_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='order_id',
      strategy='check', 
      check_cols=['status','tracking_id','delivered_at_utc','estimated_delivery_at_utc','shipping_service'],
      
    )
}}
-- Strategy 1: strategy='timestamp' ; updated_at='_fivetran_synced'
-- Strategy 2: strategy='check' ; check_cols=['quantity','product_id'],

select * from {{ ref('stg_orders') }}

{% endsnapshot %}