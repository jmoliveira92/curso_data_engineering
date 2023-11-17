

with dates as (

{{ dbt_date.get_date_dimension("2021-01-01", "2022-01-02") }}

)

select * from dates