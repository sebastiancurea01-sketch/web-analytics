WITH joined_data AS (
    SELECT * FROM {{ ref('int_sessions_joined_orders') }}
)

SELECT
    CAST(session_date AS DATE) AS date_day,
    utm_source,
    utm_campaign,
    SUM(price_usd) AS total_revenue,
    SUM(is_conversion) AS total_conversions,
    COUNT(session_id) AS total_sessions,

    COUNT(DISTINCT CASE
        WHEN is_new_customer = true
            THEN user_id
    END) AS new_customers,

    COUNT(DISTINCT CASE
        WHEN is_new_customer = false
            THEN user_id
    END) AS returning_customers

FROM joined_data
GROUP BY
    1, 2, 3
