-- tests/assert_mart_users_match_staging.sql
select 
    m.total_mart, 
    s.total_stg
from 
    (select
         count(*) as total_mart 
    from 
        {{ ref('marts_user_retention') }}) m
cross join
     (select 
        count(distinct user_id) as total_stg 
    from 
        {{ ref('stg_website_sessions') }}) s
where 
    m.total_mart != s.total_stg