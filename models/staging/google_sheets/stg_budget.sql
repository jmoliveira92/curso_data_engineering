with src_budget_products as(

    select *
    from {{ source('src_google_sheets', 'budget') }}
),

budget as (
    select
        {{dbt_utils.generate_surrogate_key( ['_row'])}} as budget_sk,
        product_id,
        quantity as target_quantity,
        month as date_day,
        _fivetran_synced AS date_load
    from src_budget_products
    order by month asc
    )

select * from budget


