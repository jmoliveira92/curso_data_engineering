{% snapshot stg_users_ex1_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='user_id',
      strategy='check',
      check_cols=['address_id','first_name','last_name','phone_number'],
    )
}}
--check_cols=['quantity','product_id'],

select * from {{ ref('stg_users_ex1') }}
where f_carga = (select max(f_carga)) from {{ ref('stg_users_ex1') }}

{% endsnapshot %}