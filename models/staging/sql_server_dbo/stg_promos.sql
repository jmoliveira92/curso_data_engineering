with promos as(

    select * 
    from {{ source('sql_server_dbo', 'promos') }}
),

renamed_casted as(
select
    promo_id,
    discount,
    status,
    _FIVETRAN_SYNCED as date_load
from promos
)

select *  from renamed_casted