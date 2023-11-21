with stg_location as(
    select distinct state 
    from {{ source('src_sql_server_dbo', 'addresses') }}
    order by 1 asc
)

select * from stg_location