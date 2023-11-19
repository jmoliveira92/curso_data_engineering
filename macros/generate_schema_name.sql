-- check: https://docs.getdbt.com/docs/build/custom-schemas
-- check video (9:15): https://www.youtube.com/watch?v=cK617PcokS0&list=PLaz3Ms051BAkrmgiaFcIknpHTK6PVy1dJ&index=2&t=686s


{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

       {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}