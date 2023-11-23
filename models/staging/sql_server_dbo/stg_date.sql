with stg_date as (
{{ dbt_date.get_date_dimension("2018-12-31", "2025-12-31") }}

)
select * from stg_date

