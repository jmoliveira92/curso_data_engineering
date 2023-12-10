{% snapshot src_promos_snap %}

{{
    config(
      target_schema='snapshots',
      unique_key='md5(promo_id)',
      strategy='check',
      check_cols=['status','discount','status'],
      invalidate_hard_deletes=True,
    )
}}
-- Strategy 1: strategy='timestamp' ; updated_at='_fivetran_synced'
-- Strategy 2: strategy='check' ; check_cols=['quantity','product_id'],

select 
    md5(promo_id) as id,
    *
from {{ source('src_sql_server_dbo', 'promos') }}

{% endsnapshot %}