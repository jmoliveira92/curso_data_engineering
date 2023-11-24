with dim_shipping_service as(
    select distinct shipping_service from {{ ref('stg_orders') }} order by 1 asc
)
select 
    {{dbt_utils.generate_surrogate_key(['shipping_service'])}} as shipping_service_sk,
    shipping_service
from dim_shipping_service
