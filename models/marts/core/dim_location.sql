select
    {{dbt_utils.generate_surrogate_key(['stg_location.state'])}} as state_sk,
    state
from {{ ref('stg_location') }}

