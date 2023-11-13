with orders as(

    select * 
    from {{ source('sql_server_dbo', 'orders') }}
)

select * from orders


