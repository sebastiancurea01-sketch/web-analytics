WITH sessions AS (
    SELECT
        user_id,
        session_id,
        session_timestamp,
        utm_source,
        utm_campaign,
        utm_content,
        http_referer,
        device_type
    FROM {{ ref('stg_website_sessions') }}
),

orders AS (
    SELECT
        user_id,
        order_id,
        ordered_at,
        ordered_date,
        session_id,
        items_purchased,
        price_usd
    FROM {{ ref('stg_orders') }}
),

session_pageviews AS (
    SELECT
        user_id,
        session_id,
        tot_pageviews,
        first_url
    FROM {{ ref('int_pageviews_aggregated_to_sessions') }}
),

------------------------- JOINED ---------------------------------------

session_joined_pageviews AS (
    SELECT
        s.user_id,
        s.session_id,
        s.session_timestamp,
        s.utm_source,
        s.utm_campaign,
        s.utm_content,
        s.http_referer,
        s.device_type,
        sp.tot_pageviews,
        sp.first_url
    FROM sessions AS s
    LEFT JOIN session_pageviews AS sp
        ON s.session_id = sp.session_id
),

ranked_sessions AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY session_timestamp, session_id
        ) AS session_number
    FROM session_joined_pageviews
),

ranked_orders AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY ordered_at, order_id
        ) AS order_number
    FROM orders
),

first_touch AS (
    SELECT
        user_id,
        session_id AS first_session_id,
        session_timestamp AS first_session_at,
        utm_source AS first_utm_source,
        utm_campaign AS first_utm_campaign,
        utm_content AS first_utm_content,
        http_referer AS first_http_referer,
        device_type AS first_device_type,
        first_url
    FROM ranked_sessions
    WHERE session_number = 1
),

orders_first_touch AS (
    SELECT
        user_id,
        order_id AS first_order_id,
        ordered_at AS first_ordered_at,
        session_id AS first_order_session_id
    FROM ranked_orders
    WHERE order_number = 1
),

second_touch AS (
    SELECT
        user_id,
        session_id AS second_session_id,
        session_timestamp AS second_session_at
    FROM ranked_sessions
    WHERE session_number = 2
),

------------------- SESSIONS GRAIN TOTALS --------------------

user_session_totals AS (
    SELECT
        user_id,
        COUNT(session_id) AS tot_sessions,
        SUM(COALESCE(tot_pageviews, 0)) AS tot_pageviews
    FROM session_joined_pageviews
    GROUP BY user_id
),

tot_orders AS (
    SELECT
        user_id,
        COUNT(order_id) AS tot_orders,
        SUM(price_usd) AS tot_revenue,
        SUM(items_purchased) AS tot_items_purchased
    FROM orders
    GROUP BY user_id
)

SELECT
    ft.user_id,
    ft.first_session_id,
    ft.first_session_at,
    ft.first_utm_source,
    ft.first_utm_campaign,
    ft.first_utm_content,
    ft.first_http_referer,
    ft.first_device_type,
    ft.first_url,
    st.second_session_id,
    st.second_session_at,
    ust.tot_sessions,
    ust.tot_pageviews,
    oft.first_order_id,
    oft.first_ordered_at,
    COALESCE(ot.tot_orders, 0) AS tot_orders,
    COALESCE(ot.tot_revenue, 0) AS tot_revenue,
    COALESCE(ot.tot_items_purchased, 0) AS tot_items_purchased,
    DATEDIFF(DAY, ft.first_session_at, st.second_session_at) AS days_to_second_session
FROM first_touch AS ft
LEFT JOIN second_touch AS st
    ON ft.user_id = st.user_id
INNER JOIN user_session_totals AS ust
    ON ft.user_id = ust.user_id
LEFT JOIN orders_first_touch AS oft
    ON ft.user_id = oft.user_id
LEFT JOIN tot_orders AS ot
    ON ft.user_id = ot.user_id
ORDER BY ft.user_id