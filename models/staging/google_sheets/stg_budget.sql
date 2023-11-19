with src_budget_products as(

    select *
    from {{ source('src_google_sheets', 'budget') }}
),

budget AS (
    SELECT
          _row
        , product_id
        , quantity
        , month
        , _fivetran_synced AS date_load
    FROM src_budget_products
    order by month asc
    )

select * from budget


