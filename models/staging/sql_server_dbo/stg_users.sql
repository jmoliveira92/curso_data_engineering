with users as (

    select *
    from {{ source('sql_server_dbo', 'users') }}
),

stg_users as (

    select
        user_id::varchar(50) as user_id,
        address_id::varchar(50) as address_id,
        first_name::varchar(50) as first_name,
        last_name::varchar(50) as last_name,
        email::varchar(50) as email,
        phone_number::varchar(50) as phone_number,
        cast(created_at as date) as created_at,
        cast(created_at as date) as updated_at, 
        coalesce(_fivetran_deleted, false)::boolean as row_deleted,
        _fivetran_synced as date_load
    from users
        
)

select * from stg_users
