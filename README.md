# E-commerce Growth Analytics

The business is growing rapidly, with **174% year-over-year growth** but maintaining a **2% churn rate**. That performance relies on paid acquisition.

## Business Question

What brings customers back, and what encourages them to make repeat purchases? This project helps a marketing or data team explore the behaviors and acquisition factors associated with customer retention and value.

## Current Output

The primary model, `marts_user_activity`, has **one row per user**. It includes:

- **Acquisition context:** first-session source, campaign, content, referrer, device, and landing URL.
- **Retention and customer value:** second-session timing, total sessions and pageviews, and order, revenue, and item totals.

The mart connects each user's first-session acquisition details to return timing, engagement, and purchase outcomes.
Comparing these metrics across acquisition groups shows which are associated with stronger retention and value.

## Data Modelling

| Layer | Model | Grain and role |
|---|---|---|
| Staging | `stg_website_sessions` | 1 row = session; `user_id` (FK) |
| Staging | `stg_website_pageviews` | 1 row = pageview. |
| Staging | `stg_orders` | 1 row = order; `user_id` (FK) |
| Intermediate | `int_pageviews_aggregated_to_sessions` | 1 row = session |
| Mart | `marts_user_activity` | 1 row = user_id |

**Cardinality**


```text
user_id 1:N website_sessions
website_sessions 1:N website_pageviews (int model solving fanning-out)
website_sessions 1:1 orders (no_sessions_with_multiple_orders test)
```

## How I build the mart table

1. **[PR #4: Sessions]** - Established the one-row-per-user mart from session data, adding first- and second-session details, first-touch acquisition fields, and total sessions.
2. **[PR #5: Pageviews]** - Added pageview staging and an intermediate model that aggregates pageviews to one row per session, preventing join fan-out; added first URL and total pageviews to the mart.
3. **[PR #7: Orders]** - Extended the mart with first-order details, order totals, revenue, and items purchased, with reconciliation tests for order metrics.

## DAG


## Testing Strategy

```text
Raw source tables
			 |
			 v
Staging models
	- Key uniqueness and not_null
	- Order/session/pageview relationships
	- `no_sessions_with_multiple_orders`: at most one order per session
			 |
			 v
Intermediate models
	- Session grain uniqueness
	- Reconcile session counts to staging
			 |
			 v
User retention mart
	- Enforced output schema contract
	- One-row-per-user uniqueness
	- Reconcile user and order totals
			 |
			 v
dbt build runs applicable model and data tests
```

## Environment Separation: Development, CI, and Production

The project separates fast iteration, isolated pull-request builds, and production runs:

| Environment | Target | Database | Role | Warehouse | Materialization and data scope |
|---|---|---|---|---|---|
| Development | `dev` | `ANALYTICS_DEV` | `DEV` | `DEV_WH` | Views; staging data limited to `created_at >= 2014-12-19` |
| CI | `ci` | `ANALYTICS_CI` | `CI_ROLE` | `CI_WH` | 1:1 with prod; isolated PR schema |
| Production | `prod` | `ANALYTICS_PROD` | `TRANSFORMER` | `PROD_WH` | Staging/intermediate views; marts are tables; full data scope |

The development date limit is applied to the staging orders, pageviews, and sessions models through `limit_data_in_dev`. Its cutoff is controlled by `dev_start_date` in `dbt_project.yml`. In dev, data tests are warnings and failures are not stored; CI and production treat test failures as errors and store failures. The checked-in `profiles.yml` defines CI and production connections only; add a dev output with the documented role and warehouse to run against Snowflake with `--target dev`.

## CI/CD

```text
CI: pull_request targeting main
	-> SQLFluff lint
	-> dbt Slim CI build for modified models and their downstream dependencies
		 in an isolated PR schema

CD: push to main
	-> dbt build --target prod
	-> Save the production manifest as a workflow artifact
		 for subsequent Slim CI runs
```

Both workflows use the project’s containerized dbt environment and GitHub Actions secrets for Snowflake credentials. CI uses the previous production manifest to defer unchanged upstream models when available; the production build generates the manifest used on later pull requests.


