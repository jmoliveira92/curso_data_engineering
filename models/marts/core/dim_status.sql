with stg_orders as (
    select distinct status from {{ ref('stg_orders') }}
),
dim_status as(
    select
        {{dbt_utils.generate_surrogate_key(['status'])}} as status_sk,
        case when status = '' then 'no_status_defined'
            when status is null then 'no_status_defined'
            else status end as status
    from stg_orders    

)

select * from dim_status