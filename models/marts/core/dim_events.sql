with stg_events as(
    select 
        {{dbt_utils.generate_surrogate_key(['session_id'])}} as session_sk,
        session_id,
        user_id
    from {{ ref('stg_events') }}
    group by 1,2,3
),

dim_customers as(
    select
        user_sk,
        user_id
    from {{ ref('dim_customers') }}
),

dim_events as(

    select
        a.session_sk,
        a.session_id,
        b.user_sk,
        b.user_id
    from stg_events a
    left join dim_customers b on b.user_id = a.user_id
    group by 1,2,3,4
)

select * from dim_events