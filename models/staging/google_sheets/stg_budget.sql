with src_budget_products as(

    select *
    from {{ source('src_google_sheets', 'budget') }}
),

budget as (
    select
        _row,
        product_id,
        quantity as target_quantity,
        month,
        _fivetran_synced AS date_load
    from src_budget_products
    order by month asc
    )

select * from budget


