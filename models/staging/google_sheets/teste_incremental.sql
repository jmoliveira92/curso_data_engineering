{{ config(
    materialized='incremental',
    unique_key = '_row'
    ) 
    }}


WITH stg_budget_products AS (
    SELECT * 
    FROM {{ source('src_google_sheets', 'budget') }}
{% if is_incremental() %}

	  where _fivetran_synced > (select max(_fivetran_synced) from {{ this }}) -- {{this}} representa o modelo que está actualmente materializado (o modelo que está actualmente no DW)

{% endif %}
    ),

renamed_casted AS (
    SELECT
          _row
        , month
        , quantity 
        , _fivetran_synced
    FROM stg_budget_products
    )

SELECT * FROM renamed_casted