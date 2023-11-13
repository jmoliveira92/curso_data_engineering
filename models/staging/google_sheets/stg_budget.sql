with budget as(

    select *
    from {{ source('google_sheets', 'budget') }}
)

select * from budget


