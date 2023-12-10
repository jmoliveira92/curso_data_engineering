with users as (

    select *
    from {{ ref('src_users_snap') }}
    where dbt_valid_to is null
),
no_user_row as(
    select * from (values ('no_user','no_address','no_user','no_user','no_user','no_user',current_date(),current_date(),'false',current_date()))
),

stg_users as (

    select
        user_id::varchar(50) as user_id,
        address_id::varchar(50) as address_id,
        first_name::varchar(50) as first_name,
        last_name::varchar(50) as last_name,
        email::varchar(50) as email,
        phone_number::varchar(50) as phone_number,
        created_at::date as created_at_utc,
        updated_at::date as updated_at_utc
        --coalesce(_fivetran_deleted, false)::boolean as row_deleted,
        --_fivetran_synced as date_load
    from users
        
)

select * from stg_users
union all
select * from no_user_row