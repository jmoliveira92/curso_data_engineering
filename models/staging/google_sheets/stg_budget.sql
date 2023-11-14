with src_budget_products as(

    select *
    from {{ source('google_sheets', 'budget') }}
),

budget AS (
    SELECT
          _row
        , product_id
        , quantity
        , month
        , _fivetran_synced AS date_load
    FROM src_budget_products
    )

select * from budget


