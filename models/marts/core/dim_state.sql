select
    {{dbt_utils.generate_surrogate_key(['stg_state.state'])}} as state_sk,
    state
from {{ ref('stg_state') }}

