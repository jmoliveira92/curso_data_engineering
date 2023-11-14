WITH stg_users AS (
    SELECT * 
    FROM {{ ref('stg_users') }}
    ),

renamed_casted AS (
    SELECT
        user_id
        , first_name
        , last_name
        , email
        , phone_number
        , created_at as created_at_utc
        , updated_at as updated_at_utc
        , address_id
        , _fivetran_synced as date_load
    FROM stg_users
    )

SELECT * FROM renamed_casted