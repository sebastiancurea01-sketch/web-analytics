{% docs limit_data_in_dev %}
# macro: limit_data_in_dev 

#### What it does
It limits data in dev environment only

#### Where it's applied
Only to bigger staging models
- stg_website_sessions
- stg_website_pageviews

#### Defualt date
set-up at `dbt_project.yml` level 
Data is limited to last 3 month 

#### How to override
`--vars '{dev_start_date: "2012-03-19"}'`

note: this is dataset start date
{% enddocs %}