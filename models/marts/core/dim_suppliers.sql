with 

suppliers as (

    select * from {{ ref('stg_tpch__suppliers') }}

),

nations as (

    select * from {{ ref('stg_tpch__nations') }}
),

regions as (

    select * from {{ ref('stg_tpch__regions') }}

),

final as (

    select

        suppliers.supplier_key,
        suppliers.supplier_name,
        suppliers.supplier_address,
        nations.name as nation,
        regions.name as region,
        suppliers.phone_number,
        suppliers.account_balance

    from suppliers
    inner join nations
        on suppliers.nation_key = nations.nation_key
    inner join regions
        on nations.region_key = regions.region_key
)

select * from final
