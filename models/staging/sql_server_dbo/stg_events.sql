-- esta tabla puede ser una fact? creo que si...

with events as(

    select * 
    from {{ source('src_sql_server_dbo', 'events') }}
),

renamed_casted as(
select
    event_id,
    created_at,
    event_type,
    user_id,
    product_id,
    session_id,
    order_id,
    page_url,
    _FIVETRAN_SYNCED as date_load
from events
)

select *  from renamed_casted