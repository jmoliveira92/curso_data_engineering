with stg_orders as (
    select distinct status from {{ ref('stg_orders') }}
),
no_status_row as(
    select * from (values ('no_status','no status'))
),
dim_status as(
    select
        {{dbt_utils.generate_surrogate_key(['status'])}} as status_sk,
        decode(status,'','status_not_defined',null,'status_not_defined',status) as status

    from stg_orders    

)

select * from dim_status
union all
select * from no_status_row