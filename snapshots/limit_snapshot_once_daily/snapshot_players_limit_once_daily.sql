{#- This snapshot can help cover scenarios where you want to ensure the snapshot
 # captures changes only once daily. A better alternative for this is to ensure that
 # you have good testing in place, schedule correctly and with the right syntax, 
 # and to resolve duplicate situations post-snapshot if you can't help this.
 # 
 # Adding models to resolve these scenarios is more visible and can be easier to understand
 # than a macro which resolves this, and the macro method doesn't highlight internal processes 
 # that should be fixed to be more reliable. This macro example was created to help those who
 # can not go with better methods.
 -#}
{% snapshot snapshot_players_limit_once_daily %}
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
    {#- This equates to True or False.
     # on `where true`, the returned data will be compared for adding changed data to the existing snapshot.
     # on `where false`, no data will be selected and so it will look like there are no changes captured to add.
    -#} 
    where {{ should_update_snapshot() }}
    
{% endsnapshot %}