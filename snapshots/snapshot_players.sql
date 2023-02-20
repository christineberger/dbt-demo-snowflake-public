{% snapshot snapshot_players %}
    {{ config(
            target_schema=target.schema,
            unique_key='id',
            strategy='check',
            check_cols=['phone', 'city', 'item']
    ) }}
    with

    source_data as (
        select 
            id, 
            phone, 
            city, 
            item 
        from {{ ref('hypothetical_source') }}
    )

    select * from source_data
 {% endsnapshot %}