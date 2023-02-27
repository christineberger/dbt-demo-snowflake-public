{% snapshot snapshot_players_delete %}
    {{ config(
            target_schema=target.schema,
            unique_key='id',
            strategy='check',
            check_cols=['phone', 'city', 'item'],
            post_hook="{{ snapshot_delete_old_records() }}"
    ) }}
    
    with

    source_data as (
        select 
            id,
            name,
            phone, 
            city, 
            item 
        from {{ ref('hypothetical_source_for_snapshot_delete') }}
    )

    select * from source_data
    
{% endsnapshot %}