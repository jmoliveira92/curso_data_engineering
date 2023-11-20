with stg_events as(
    select distinct event_type
    from {{ ref('stg_events') }}
    order by 1 asc
),
dim_event_types as(
    select
        {{dbt_utils.generate_surrogate_key(['event_type'])}} as event_types_sk,
        event_type
    from stg_events
)

select * from dim_event_types