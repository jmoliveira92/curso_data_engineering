with accounting as (
    select 
        scope,
        --type,
        category,
        date_trunc('month', invoice_date) as month,
        sum(total_invoice) as total_usd
    from {{ ref('stg_accounting') }}
    group by 1,2,3
),

wages as (
    select
        'structural' as scope,     
        'wages' as category,
        date_trunc('month', wage_month) as month,
        sum(monthly_wage) as total_usd
    from {{ ref('stg_wages') }}
    group by 1,2,3
)

select * from accounting
union all
select * from wages