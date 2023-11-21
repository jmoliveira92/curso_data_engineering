
{{ config(
    materialized='incremental',
    unique_key = 'user_id',
    on_schema_change='fail'
    ) 
    }}

with users as (

    select *
    from {{ source('src_sql_server_dbo', 'users') }}

{% if is_incremental() %}

	  where _fivetran_synced > (select max(f_carga) from {{ this }}) 

      --{{this}} represents the model that is materialize "at this moment", not the one at the time of the incremental.

{% endif %}

),

stg_users as (

    select
        user_id::varchar(50) as user_id,
        first_name::varchar(50) as first_name,
        last_name::varchar(50) as last_name,
        address_id::varchar(50) as address_id,
        replace(phone_number,'-','')::number(38,0) as phone_number,
        _fivetran_synced::timestamp as f_carga
    from users
        
)

select * from stg_users
