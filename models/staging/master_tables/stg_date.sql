with date_spine as(
    
    {{ dbt_utils.date_spine(
                            datepart="day",
                            start_date="cast('2021-01-01' as date)",
                            end_date="cast('2023-01-01' as date)"
                            )
}}
),

master_date as(

    select 
        date_day as 
    from date_spine


)

select * from master_date

