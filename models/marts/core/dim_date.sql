with stg_date as(
    select * from {{ ref('stg_date') }}
),
dim_date as(

    select
        to_char(date_day, 'YYYYMMDD') AS date_key,
        *
    from stg_date

)
select * from dim_date