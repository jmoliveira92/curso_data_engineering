
with stg_events as(

    select * 
    from {{ source('src_sql_server_dbo', 'events') }}
),

renamed_casted as(
select
    event_id::varchar(50) as event_id,
    session_id::varchar(50) as session_id,
    user_id::varchar(50) as user_id,
    event_type::varchar(50) as event_type,
    decode(product_id,'','no_product',null,'no_product',product_id)::varchar(50) as product_id,
    decode(order_id,'','no_order',null,'no_order',order_id)::varchar(50) as order_id,
    created_at::timestamp as created_at_utc,     
    page_url::varchar(256) as page_url,
    _FIVETRAN_SYNCED as date_load

from stg_events
order by 2 asc
)

select *  from renamed_casted