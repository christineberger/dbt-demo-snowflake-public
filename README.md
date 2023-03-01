### About this branch

This example shows how you can require models in selection
syntax when specific models are running. 

This is helpful in team scenarios where a person creating or
modifying a job may not be aware of selection syntax that
needs to include or update critical models.

Details:
- Both base models require the `stg_tpch__locations` model. You can see this from 
  the config blocks within the models.
- When the models are selected for a run, they execute a pre_hook
  which checks whether `stg_tpch__locations` is within the 
  selection. 
- The macro being called from the pre_hook can be found in `/macros/required_builds.sql`.
- Further ideas for modifying the macro:
  - Instead of raising a compiler error, you could raise a warning.
  - You could raise a warning just for development and raise
    an error in deployment using either the target context or environment variables.

### How to test
1. Try using `dbt run -s base_tpch__nations`. This should raise a compiler error. 
2. Try using `dbt run -s base_tpch__regions`. This should also raise a compiler error.
3. Try using `dbt run -s base_tpch__nations+`. This shouldn't raise and error and run these models:
    - `base_tpch__nations`
    - `stg_tpch__locations`
4. Try adding the prehook to `stg_tpch__locations`, to require both `base_tpch__nations`
   and `base_tpch__regions` to be built and test it!
   
### Hypothetical Use cases
  - A person in charge of creating deployments accidentally sets a job but forgets
    to include a downstream model that should be updated.
  - You want to ensure commands include upstream models that should be updated
    first before refreshing stakeholder models.
  - You want to ensure that while developing, a developer is running the
    downstream model to validate the proper output, or in cases where CI isn't 
    being implemented, you want to ensure they built the downstream model to 
    avoid breaking changes.