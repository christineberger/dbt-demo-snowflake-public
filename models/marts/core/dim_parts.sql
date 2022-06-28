with 

parts as (
    select * from {{ref('stg_tpch__parts')}}
),

final as (
    select 
        part_key,
        manufacturer,
        name,
        brand,
        type,
        size,
        container,
        retail_price
    from parts
)

select * from final
