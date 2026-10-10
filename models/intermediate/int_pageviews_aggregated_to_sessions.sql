WITH pageviews AS (
    SELECT
        pageview_id,
        pageview_timestamp,
        pageview_url,
        session_id
    FROM {{ ref('stg_website_pageviews') }}
),

sessions AS (
    SELECT
        user_id,
        session_id
    FROM {{ ref('stg_website_sessions') }}
),

tot_pageviews AS (
    SELECT
        session_id,
        count(pageview_id) AS tot_pageviews
    FROM {{ ref('stg_website_pageviews') }}
    GROUP BY session_id
),

first_touch AS (
    SELECT
        session_id,
        pageview_url AS first_url
    FROM
        pageviews
    QUALIFY row_number() OVER (
        PARTITION BY session_id
        ORDER BY pageview_timestamp, pageview_id
    ) = 1
)

SELECT
    s.session_id,
    s.user_id,
    ft.first_url,
    coalesce(tp.tot_pageviews, 0) AS tot_pageviews
FROM
    sessions AS s
LEFT JOIN first_touch AS ft
    ON s.session_id = ft.session_id
LEFT JOIN tot_pageviews AS tp
    ON s.session_id = tp.session_id
