with dim_shipping_service as(
    select distinct shipping_service from {{ ref('stg_orders') }} order by 1 asc
)
,
shipping_agreements as(
    select * from {{ ref('shipping_agreements') }}
)

select 
    {{dbt_utils.generate_surrogate_key(['a.shipping_service'])}} as shipping_service_sk,
    a.shipping_service,
    decode(b.shipping_agreement,null,0,b.shipping_agreement) as shipping_agreement
from dim_shipping_service a
left join shipping_agreements b on b.shipping_service = a.shipping_service
