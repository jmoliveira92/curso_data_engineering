with promos as (

    select *
    from {{ source('sql_server_dbo', 'promos') }}
),

stg_promos as (
select
    {{ dbt_utils.generate_surrogate_key(['promo_id','discount']) }}::varchar(50) as promo_id,
    promo_id::varchar(50) as promo_name,
    discount::float as promo_discount,
    status::varchar(50) as promo_status,
    coalesce(_fivetran_deleted, false)::boolean as row_deleted,
    _fivetran_synced as date_load
from promos
)

select * from stg_promos
