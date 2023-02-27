{% snapshot snapshot_players_update %}
    {{ config(
            target_schema=target.schema,
            unique_key='id',
            strategy='check',
            check_cols=['phone', 'city', 'item'],
            post_hook="{{ update_valid_snapshot_records(
                from_relation=ref('hypothetical_source'), 
                unique_key='id', 
                update_cols=['name']
            ) }}"
    ) }}
    
    with

    source_data as (
        select 
            id,
            name,
            phone, 
            city, 
            item 
        from {{ ref('hypothetical_source') }}
    )

    select * from source_data
    
{% endsnapshot %}