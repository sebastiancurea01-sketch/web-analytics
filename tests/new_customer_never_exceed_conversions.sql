SELECT
    date_day,
    utm_source,
    utm_campaign,
    new_customers,
    total_conversions
FROM {{ ref('int_daily_performance_summarized') }}
WHERE new_customers > total_conversions