
{{ config(
    materialized='incremental',
    unique_key = 'user_id',
    on_schema_change='fail'
    ) 
    }}

with users_clone as (

    select *
    from {{ source('src_sql_server_dbo', 'users_clone') }}

{% if is_incremental() %}

	  where _fivetran_synced > (select max(_fivetran_synced) from {{ this }}) 

      --{{this}} represents the model that is materialize "at this moment", not the one at the time of the incremental.

{% endif %}

)

select * from users_clone

