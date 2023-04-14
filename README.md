# :seedling: About this Branch
This branch has two files to look at:
- `macros/delete_from_table.sql`
- `models/stg_tpch__orders.sql`

The `stg_tpch__orders` model uses the `delete_from_table` macro to remove deleted
records on the post-hook. 

Important things to know about the macro:
1. It assumes the deletion is happening on an incremental coming off the source, 
   so it refers to the `model` variable's first item in its `sources` list to get
   the source vs. needing to have a source reference passed in.
2. It assumes the name for the preserved deleted records table is fine being standard.
   It creates a table named `deleted_<model>` for each model that uses it.
3. That your ids for the model and source of deleted records are the same. However,
   you can pass in the source's key name if needed. If you don't pass this in, the
   macro will try to select the provided `unique_key` configuration when looking
   for deleted records from the source.
4. The predicate for finding deleted records is hard-coded. You will need to
   customize this for how you'd like to use the macro.
