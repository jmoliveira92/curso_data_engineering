select
    {{dbt_utils.generate_surrogate_key(['stg_addresses.address_id'])}} as address_sk,
    address_id,
    country,
    state,
    zipcode,
    address
from {{ ref('stg_addresses') }}

--aqui falta fazer um join para ir buscar as sk's de dim_location ???