SELECT
    m.total_int,
    s.total_stg
FROM
    (
        SELECT count(session_id) AS total_int
        FROM
            {{ ref('int_pageviews_aggregated_to_sessions') }}
    ) AS m
CROSS JOIN
    (
        SELECT count(*) AS total_stg
        FROM
            {{ ref('stg_website_sessions') }}
    ) AS s
WHERE
    m.total_int != s.total_stg
