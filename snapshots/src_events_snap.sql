{% snapshot src_events_snap %}

{{
    config(
      target_schema='snapshots',
      unique_key='event_id',
      strategy='timestamp',
      updated_at='_fivetran_synced',
      invalidate_hard_deletes=True,
    )
}}
-- Strategy 1: strategy='timestamp' ; updated_at='_fivetran_synced'
-- Strategy 2: strategy='check' ; check_cols=['quantity','product_id'],

select * from {{ source('src_sql_server_dbo', 'events') }}

--this line turns the snapshop incremental
--where _fivetran_synced = select(max(_fivetran_synced) from {{ source('src_sql_server_dbo', 'events') }})

{% endsnapshot %}