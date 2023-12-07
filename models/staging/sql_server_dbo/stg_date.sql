with stg_date as (
{{ dbt_date.get_date_dimension("2021-01-01", "2025-01-01") }}

),
stg_date_1900 as (
{{ dbt_date.get_date_dimension("1900-01-01", "1900-01-02") }}

)
select * from stg_date
union all
select * from stg_date_1900

