# :star2: Welcome! :star2:
You're viewing Christine's dbt Labs Snowflake Demo Project. This dbt project is 
intended to showcase key Snowflake + dbt functionalities regarding workflow, 
modeling, and operationalizing. 

Code for specific use cases can be found within the branches of this repository,
and each scenario branch will contain more information about the use case in the 
`About this Branch` section below.

# :seedling: About this Branch
This is the main branch and features the file structure and objects you'd 
typically see in a beginner dbt project:
- Models, organized within the `/models` folder into staging, intermediate, and marts models.
- A packages.yml which contains some functionality used in the project.
- A pull request template, which shows up in the repository hosting service's web
  interface when opening a pull request.

# :video_game: Running this Project
This section contains details on what's needed to actually run this demo
project on your own:

### Data Platform
This project uses Snowflake as it's underlying data platform. You are welcome to use
[any data platform that is supported by dbt](https://docs.getdbt.com/docs/supported-data-platforms), 
but be aware that there may be differences in implementation or more set up required
to ensure you have everything you need.

### Data Sets
This project uses the Snowflake Sample [TPC-H dataset that is standard with every account](https://docs.snowflake.com/en/user-guide/sample-data-tpch.html),
but there are articles online which tell you how to access this public data set
for your own needs if you are not using Snowflake as your data platform.

### Repository
This project uses Github, but you can use any git provider as long as you ensure
that you take the code from this repository and put it into your own. 

If using Github, you can fork this repository for your own demo project.
### dbt Core or dbt Cloud
This project uses dbt to transform data in the warehouse. You must have [dbt core installed locally](https://docs.getdbt.com/docs/get-started/installation)
or a [dbt Cloud account](https://docs.getdbt.com/docs/get-started/getting-started/set-up-dbt-cloud).

These must be fully set up with the connections to the repository and warehouse 
platforms you choose. Refer to dbt docs if you need help.

### Ensuring setup
To ensure that you've configured your project correctly, you'll want to try and
run each of these commands:
```bash
$ dbt deps
$ dbt build
```

### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices