{{ config(
    pre_hook=[
        "{{ required_builds(['stg_tpch__locations']) }}"
    ]
) }}

with 

source as (
    select * from {{ source('tpch', 'region') }}
),

renamed as (
    select
        -- ids
        r_regionkey as region_id,

        -- dimensions
        r_name as name,
        r_comment as comment
    from source
)

select * from renamed
