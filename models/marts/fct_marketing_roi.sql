{{
    config(
        materialized='incremental',
    )
}}
WITH spend AS (
    SELECT * FROM {{ ref('stg_ad_spend') }}

    {% if is_incremental() %}
        WHERE date_day > (SELECT max(t.date_day) FROM {{ this }} AS t)
    {% endif %}
),

performance AS (
    SELECT * FROM {{ ref('int_daily_performance_summarized') }}
)

SELECT
    s.date_day,
    s.utm_source,
    s.utm_campaign,
    s.total_spend,
    s.total_clicks,
    coalesce(p.total_revenue, 0) AS total_revenue,
    coalesce(p.total_conversions, 0) AS total_conversions,
    coalesce(p.total_sessions, 0) AS total_sessions,

    -- ROAS
    CASE
        WHEN s.total_spend > 0 THEN round(p.total_revenue / s.total_spend, 2)
    END AS roas,

    CASE
        WHEN
            p.total_conversions > 0
            THEN round(s.total_spend / p.total_conversions, 2)
    END AS cpa,

    CASE
        WHEN s.utm_campaign = 'brand'
            THEN coalesce(p.total_revenue, 0)
        ELSE 0
    END AS brand_revenue_usd

FROM spend AS s
LEFT JOIN performance AS p
    ON
        s.date_day = p.date_day
        AND s.utm_source = p.utm_source
        AND s.utm_campaign = p.utm_campaign

ORDER BY s.date_day DESC
