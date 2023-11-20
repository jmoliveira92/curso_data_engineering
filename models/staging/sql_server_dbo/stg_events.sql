-- esta tabla puede ser una fact? creo que si...

with events as(

    select * 
    from {{ source('src_sql_server_dbo', 'events') }}
),

renamed_casted as(
select
    event_id::varchar(50) as event_id,
    session_id::varchar(50) as session_id,
    user_id::varchar(50) as user_id,
    event_type::varchar(50) as event_type,
    product_id::varchar(50) as product_id,
    order_id::varchar(50) as order_id,
    cast(created_at as date) as created_at_utc,     
    page_url::varchar(256) as page_url,
    _FIVETRAN_SYNCED as date_load
from events
order by 7 asc
)

select *  from renamed_casted