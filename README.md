# About this branch
This example shows how you can use the package [dbt_snowflake_query_tags](https://hub.getdbt.com/get-select/dbt_snowflake_query_tags/latest/) 
and Snowflake's native [query_history](https://docs.snowflake.com/en/sql-reference/account-usage/query_history) table to assemble 
high-level information about jobs and their query-level error messages.

# Setup
1. Install the [dbt_snowflake_query_tags package](https://hub.getdbt.com/get-select/dbt_snowflake_query_tags/latest/)
   into your project and follow all instructions on the package's README to get it configured.
2. Copy the following `var` intp your `dbt_project.yml`. We'll use this so that the logging models are always
   disabled unless explicitly turned on within a command:
   ```yaml
   vars:
     # This should be left as false and enabled at run time on a job, after a command that builds models
     # Usage: dbt run -s base_snowflake__query_history+ --vars '{"transfer_job_history_to_snowflake": true}'
     transfer_job_history_to_snowflake: false
   ```
3. Copy the [macros](/macros/dbt_cloud_job_logging/) into your project for creating UDFs we can call in our modeling.
   These are copied from the package [dbt_snowflake_monitoring](https://hub.getdbt.com/get-select/dbt_snowflake_monitoring/latest/).
4. (Optional, but highly recommended) Create folders specific to the logging models - this will make it easier to set a
   configuration for schema, which will make the logging models easier to find within the warehouse:
   ```bash
        models/
        ├── dbt_cloud_job_logging/
        │   ├── marts/
        │   └── staging/
   ```
   then, in `dbt_project.yml`, configure the `dbt_cloud_job_logging` folder with a `+schema` config:
   ```yaml
    models:
        dbt_snowflake_demo:
            marts:
                core:
                    +materialized: table
        dbt_cloud_job_logging:
            +schema: _query_logs
   ```
5. Copy the models found in the [models/marts/dbt_cloud_job_logging] into your project's `/models` folder.
     - `_sources.yml` contains the source configuration for the location of the Snowflake query_history table.
     - `base_snowflake__query_history` (view) cleans up and only selects certain fields Snowflake’s `query_history` table, and prepares the dbt metadata query tag to be extracted.
     - `stg_dbt_snowflake__job_query_history` (view) gets the cleaned data and filters it only to dbt job runs and extracts the dbt metadata.
     - `fct_dbt_cloud_job_history` (incremental) gets the dbt job query history and aggregates it to the job level. This needs to be done as error messages exist at the query_history level.
     - In your job, (after a command that runs models), run `dbt build -s base_snowflake__query_history+ --vars '{"transfer_job_history_to_snowflake":true}'`.

     Example preview in Snowflake:
     ![Example of output table in Snowflake](/_images/example_logging.png)

### Notes:
  - This _won't_ tell you if there were errors in any of the job
    steps.
  - It may be better to use the dbt Cloud APIs to get the information you need,
    as we are trying to gather information while we're at a finer context rather
    than at the level of dbt Cloud account. Some information you need may not be
    available at the project level.
  - This is a very simple example and only selects a few data points - there's a lot of
    rich information contained in Snowflake's `query_history` table and within
    dbt metadata. If you need more, you need to figure out what else is available
    and build it out!