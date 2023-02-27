{# For this example, we need to create a dummy snapshot to reflect historical changes. 
 # This "source" reflects the "current" data, and the "snapshot" is created in a post-hook
 # if the snapshot table doesn't already exist.
 # You can run the snapshot afterwards to see that old records get deleted from the snapshot.
 #}

{{ config(
    post_hook="{{ create_dummy_inital_snapshot() }}"
) }}

with

source as (
    select 2 as id, 'Thomas Shelby' as name, 8797899999 as phone, 'chicago' as city, 'barstool' as item union all
    select 3 as id, 'Arthur Shelby' as name, 7657575657 as phone, 'san antonio' as city, 'stapler' as item union all
    select 4 as id, 'John Shelby' as name, 77868768768 as phone, 'chicago' as city, 'table' as item union all
    select 5 as id, 'Pollie Gray' as name, 47582339430 as phone, 'chicago' as city, 'chair' as item union all
    select 6 as id, 'Michael Gray' as name, 8098080808 as phone, 'austin' as city, 'laptop' as item union all
    select 7 as id, 'Alfie Solomon' as name, 8080809800 as phone, 'austin' as city, 'pencil' as item
select * from source