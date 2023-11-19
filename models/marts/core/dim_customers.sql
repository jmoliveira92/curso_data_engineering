with stg_users as (
    select * 
    from {{ ref('stg_users') }}
    ),

dim_customers as (
    select
        {{dbt_utils.generate_surrogate_key(['stg_users.user_id'])}} as user_sk,
        stg_users.user_id,
        dim_addresses.address_sk,
        stg_users.first_name || ' ' || stg_users.last_name as full_name,
        stg_users.email,
        stg_users.phone_number,
        stg_users.created_at_utc,
        stg_users.updated_at_utc,
        stg_users.date_load
    from stg_users
    left join {{ ref('dim_addresses') }} on stg_users.address_id = dim_addresses.address_id
    )

select * from dim_customers