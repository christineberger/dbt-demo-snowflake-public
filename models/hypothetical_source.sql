with

source_data as (
    select 2 as id, 'Tom Bergman' as name, 8797899999 as phone,  'chicago' as city, 'barstool' as item union all
    select 3 as id, 'Arthur Shelby' as name, 7657575657 as phone, 'austin' as city, 'desk' as item union all
    select 4 as id, 'John Shelby' as name, 77868768768 as phone, 'chicago' as city, 'table' as item union all
    select 5 as id, 'Pollie Gray' as name, 9878979888 as phone, 'chicago' as city, 'chair' as item union all
    select 6 as id, 'Michael Gray' as name, 8098080808 as phone, 'austin' as city, 'computer' as item union all
    select 7 as id, 'Alfie Solomon' as name, 8080809800 as phone, 'austin' as city, 'stationary' as item union all
    select 8 as id, 'Christine Berger' as name, 0987654332 as phone, 'new york' as city, 'dbt' as item union all
    select 9 as id, 'Logan Cochran' as name, 123456789 as phone, 'seattle' as city, 'pokemon' as item
)

select * from source_data