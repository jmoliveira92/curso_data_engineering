with stg_date_1900 as (
{{ dbt_date.get_date_dimension("1900-01-01", "1900-01-02") }}

)
select * from stg_date_1900

