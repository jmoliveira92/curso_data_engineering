with stg_users as (
    select * 
    from {{ ref('stg_users') }}
    ),

no_user_row as(

select * from (values ('19000101','no_user','no_user','no_address','no_user','no_user','no_user',current_timestamp(),current_timestamp()))

),

dim_customers as (
    select
        dim_date.date_key,
        {{dbt_utils.generate_surrogate_key(['stg_users.user_id'])}} as user_sk,
        stg_users.user_id,
        dim_addresses.address_sk,
        stg_users.first_name || ' ' || stg_users.last_name as full_name,
        stg_users.email,
        stg_users.phone_number,
        stg_users.created_at_utc,
        stg_users.updated_at_utc
        
    from stg_users
    left join {{ ref('dim_addresses') }} on stg_users.address_id = dim_addresses.address_id
    left join {{ ref('dim_date') }} on stg_users.created_at_utc=dim_date.date_day 
    )

select * from dim_customers
union all
select * from no_user_row