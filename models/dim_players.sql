with

source as (
    select id, name from {{ ref('hypothetical_source') }}
),

snapshot as (
    select * from {{ ref('snapshot_players') }}
),

joined as (
    select
        snapshot.id,
        source.name,
        snapshot.phone,
        snapshot.city,
        snapshot.item,
        snapshot.dbt_scd_id,
        snapshot.dbt_updated_at as updated_at,
        snapshot.dbt_valid_from as eff_start_at,
        snapshot.dbt_valid_to as eff_end_at
    from snapshot
    left join source
        on snapshot.id = source.id
)

select * from joined
order by id, eff_start_at