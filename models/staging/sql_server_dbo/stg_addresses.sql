with addresses as(

    select * 
    from {{ source('sql_server_dbo', 'addresses') }}
),

renamed_casted as(
select
    address_id,
    zipcode,
    country,
    address,
    state,
    _FIVETRAN_SYNCED as date_load
from addresses
)

select *  from renamed_casted
