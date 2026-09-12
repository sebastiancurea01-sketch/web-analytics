{{
  config(
    materialized='table',
  )
}}

WITH performance AS (
    SELECT * FROM {{ ref('int_daily_performance_summarized') }}
),

ad_spend AS (
    SELECT * FROM {{ ref('stg_ad_spend') }}
),

joined AS (
    SELECT
        p.date_day,
        p.utm_source,
        p.utm_campaign,
        p.total_revenue,
        p.total_sessions,
        p.total_conversions,
        p.new_customers,
        p.returning_customers,
        s.total_spend,
        s.total_clicks
    FROM performance AS p
    LEFT JOIN ad_spend AS s
        ON
            p.date_day = s.date_day
            AND p.utm_source = s.utm_source
            AND p.utm_campaign = s.utm_campaign
),

monthly AS (
    SELECT
        utm_source,
        utm_campaign,
        date_trunc('month', date_day) AS month,
        sum(total_revenue) AS total_revenue,
        sum(total_sessions) AS total_sessions,
        sum(total_conversions) AS total_conversions,
        sum(new_customers) AS new_customers,
        sum(returning_customers) AS returning_customers,
        sum(total_spend) AS total_spend,
        sum(total_clicks) AS total_clicks
    FROM joined
    GROUP BY 1, 2, 3
),

final AS (
    SELECT
        month,
        utm_source,
        utm_campaign,
        total_revenue,
        total_sessions,
        total_conversions,
        new_customers,
        returning_customers,
        total_spend,
        total_clicks,

        -- KPI
        round(
            total_revenue
            / nullif(total_spend, 0), 2
        ) AS roas,
        round(
            total_spend
            / nullif(total_conversions, 0), 2
        ) AS cpa,
        round(
            total_conversions
            / nullif(total_sessions, 0), 4
        ) AS conversion_rate,
        round(
            total_spend
            / nullif(new_customers, 0), 2
        ) AS cac_usd,
        round(
            total_revenue
            / nullif(total_conversions, 0), 2
        ) AS avg_ltv_usd,

        round(
            1 - (
                returning_customers
                / nullif(
                    lag(total_conversions, 1) OVER (
                        PARTITION BY utm_source, utm_campaign
                        ORDER BY month
                    ), 0
                )
            ), 4
        ) AS churn_rate,

        -- yoy growth: revenue vs same month prior year
        round(
            (total_revenue - lag(total_revenue, 12) OVER (
                PARTITION BY utm_source, utm_campaign
                ORDER BY month
            ))
            / nullif(lag(total_revenue, 12) OVER (
                PARTITION BY utm_source, utm_campaign
                ORDER BY month
            ), 0), 4
        ) AS yoy_revenue_growth

    FROM monthly
)

SELECT * FROM final
