
with stg_addresses as(

    select * from {{ ref('stg_addresses') }}
),
no_address_row as(
    select * from (values ('no_address','no_address','no_address','no_address','no_address','no_address'))
),

dim_addresses as(
  
    select
        {{dbt_utils.generate_surrogate_key(['stg_addresses.address_id'])}} as address_sk,
        address_id,
        country,
        state,
        zipcode,
        address
    from stg_addresses
)

select * from dim_addresses
union all
select * from no_address_row