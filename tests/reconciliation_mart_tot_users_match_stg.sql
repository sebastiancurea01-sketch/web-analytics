SELECT
    m.total_mart,
    s.total_stg
FROM
    (
        SELECT count(*) AS total_mart
        FROM
            {{ ref('mrt_user_activity') }}
    ) AS m
CROSS JOIN
    (
        SELECT count(DISTINCT user_id) AS total_stg
        FROM
            {{ ref('stg_website_sessions') }}
    ) AS s
WHERE
    m.total_mart != s.total_stg
