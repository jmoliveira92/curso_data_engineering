version: 2

sources:
  - name: src_sql_server_dbo # name of the source
    description: source database from snowflake datawarehouse.

    schema: sql_server_dbo # this is the schema our raw data lives in
    database: "{{ env_var('DBT_ENVIRONMENTS') }}_BRONZE_DB" # this is the name of our database

    quoting:
      database: false
      schema: false
      identifier: false

    freshness:
      warn_after: { count: 24, period: day }
      error_after: { count: 48, period: day }

    tables:
      - name: addresses
        loaded_at_field: _fivetran_synced
        description: a table who shows addresses from the users/customers who did orders or interact with the website.
        columns:
          - name: address_id
            description: a primary key from the source database.
          - name: zipcode
            description: the zipcode where an address is located.
          - name: country
            description: the country where an address is located.
          - name: address
            description: the address (street, number, apartment_no,...) of an user/customer.
          - name: state
            description: the state where an address is located.
          - name: _fivetran_deleted
            description: XXXXXXXXXX
          - name: _fivetran_synced
            description: shows the timestamp in which a record was loaded to the source table.

      - name: events
        loaded_at_field: _fivetran_synced
        description: XXXXXXXXXX

        columns:
          - name: event_id
            description: XXXXXXXXXX
          - name: page_url
            description: XXXXXXXX
          - name: event_type
            description: XXXXXXXXXX
          - name: user_id
            description: XXXXXXXXXX
          - name: product_id
            description: XXXXXXXX
          - name: session_id
            description: XXXXXXXXXX
          - name: created_at
          - name: order_id
            description: XXXXXXXXXX
          - name: _fivetran_deleted
            description: XXXXXXXXXX
          - name: _fivetran_synced


      - name: orders
        loaded_at_field: _fivetran_synced
        description: XXXXXXXXXX

        columns:
          - name: order_id
            description: XXXXXXXX

          - name: shipping_service
            description: XXXXXXXXXX
          - name: shipping_cost
            description: XXXXXXXXXX
          - name: address_id
            description: XXXXXXXXXX
          - name: created_at
            description: XXXXXXXXXX
          - name: promo_id
            description: XXXXXXXXXX
          - name: estimated_delivery_at
            description: XXXXXXXXXX
          - name: order_cost
            description: XXXXXXXXXX
          - name: user_id
            description: XXXXXXXXXX
          - name: order_total
            description: XXXXXXXXXX
          - name: delivered_at
            description: XXXXXXXXXX
          - name: tracking_id
            description: XXXXXXXXXX
          - name: status
            description: XXXXXXXXXX
          - name: _fivetran_deleted
            description: XXXXXXXXXX
          - name: _fivetran_synced
            description: shows the timestamp in which a record was loaded to the source table.

      - name: order_items
        loaded_at_field: _fivetran_synced
        description: order_items is a sale order details of an order. Therefore the granularity of this table is the most refined one, meaning that decompose a order (sale) at the individual product level (each order_id can have several products).
        columns:
          - name: order_id
            description: the primary key for each order (it is the source primary key).
          - name: product_id
            description: the primary key for each product (it is the source primary key).
          - name: quantity
            description: XXXXXXXXXX
          - name: _fivetran_deleted
            description: XXXXXXXXXX
          - name: _fivetran_synced
            description: shows the timestamp in which a record was loaded to the source table.

      - name: products
        loaded_at_field: _fivetran_synced
        description: XXXXXXXXXX

        columns:
          - name: product_id
            description: the primary key for each product (it is the source primary key).
          - name: price
            description: XXXXXXXXXX
          - name: name
            description: XXXXXXXXXX
          - name: inventory
            description: XXXXXXXXXX
          - name: _fivetran_deleted
            description: XXXXXXXXXX
          - name: _fivetran_synced
            description: shows the timestamp in which a record was loaded to the source table.

      - name: promos
        loaded_at_field: _fivetran_synced
        description: represents a table with the promos information. A promotion is in enable when the "status" in labled "active"

        columns:
          - name: promo_id
            description: the primary key for each product (it is the source primary key).
          - name: discount
            description: XXXXXXXXXX
          - name: status
            description: XXXXXXXXXX
          - name: _fivetran_deleted
            description: XXXXXXXXXX
          - name: _fivetran_synced
            description: shows the timestamp in which a record was loaded to the source table.


      - name: users
        loaded_at_field: _fivetran_synced
        description: represents a table with the users/customers information.

        columns:
          - name: user_id
            description: the primary key for each user/customer (it is the source primary key).
          - name: updated_at
            description: the timestamp this record was updated.
          - name: address_id
            description: the address where this user/customer lives.
          - name: last_name
            description: the last name of a user/customer.
          - name: created_at
            description: the timestamp this record was created.
          - name: phone_number
            description: the phone number of a user/customer.
          - name: total_orders
            description: the total amount of orders/sales a costumer has purchase to the company. 
          - name: first_name
            description: the first name of a user/customer.
          - name: email
            description: the email of a user/customer.
          - name: _fivetran_deleted
            description: XXXXXXXXXX
          - name: _fivetran_synced
            description: shows the timestamp in which a record was loaded to the source table.

      - name: users_clone
        description: a duplicate table for the exercice 2