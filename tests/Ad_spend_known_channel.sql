SELECT
    month,
    utm_source,
    utm_campaign,
    total_revenue
FROM {{ ref('mart_monthly_metrics') }}
WHERE total_revenue < 0