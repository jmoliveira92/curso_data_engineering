with stg_date as(
    select * from {{ ref('stg_date') }}
),

stg_date_1900 as (
    select * from {{ ref('stg_date_1900') }}
),

dim_date_1900 as(

    select
        to_char(date_day, 'YYYYMMDD') AS date_key,
        *
    from stg_date_1900

),

dim_date as(

    select
        to_char(date_day, 'YYYYMMDD') AS date_key,
        *
    from stg_date

)
select * from dim_date_1900

union all

select * from dim_date