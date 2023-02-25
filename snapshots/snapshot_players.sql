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
            name,
            phone, 
            city, 
            item 
        from {{ ref('hypothetical_source') }}
    )

    select * from source_data
    -- This equates to True or False.
    -- on `where true`, the returned data will be compared for adding changed data to the existing snapshot.
    -- on `where false`, no data will be selected and so it will look like there are no changes captured to add.
    where {{ should_update_snapshot() }}
    
{% endsnapshot %}