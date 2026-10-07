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

ranked_sessions AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY session_timestamp, session_id
        ) AS session_number
    FROM sessions
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
        device_type AS first_device_type
    FROM ranked_sessions
    WHERE session_number = 1
),

second_touch AS (
    SELECT
        user_id,
        session_id AS second_session_id,
        session_timestamp AS second_session_at
    FROM ranked_sessions
    WHERE session_number = 2
),

tot_sessions AS (
    SELECT
        user_id,
        COUNT(session_id) AS tot_sessions
    FROM sessions
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
    st.second_session_id,
    st.second_session_at,
    ts.tot_sessions,
    DATEDIFF(DAY, ft.first_session_at, st.second_session_at) AS days_to_second_session
FROM first_touch AS ft
LEFT JOIN second_touch AS st
    ON ft.user_id = st.user_id
INNER JOIN tot_sessions AS ts
    ON ft.user_id = ts.user_id
