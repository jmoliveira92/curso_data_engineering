with addresses as(

    select * 
    from {{ source('sql_server_dbo', 'addresses') }}
),

stg_addresses as(
select
    address_id::varchar(50) as address_id,
    country::varchar(50) as country,
    state::varchar(50) as state,
    zipcode::varchar(50) as zip_code,
    address::varchar(50) as address,
    _FIVETRAN_SYNCED as date_load
from addresses
)

select *  from stg_addresses