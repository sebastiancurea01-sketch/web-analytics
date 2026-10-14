SELECT
    m.total_mart,
    s.total_stg
FROM
    (
        SELECT sum(tot_sessions) AS total_mart
        FROM
            {{ ref('marts_user_retention') }}
    ) AS m
CROSS JOIN
    (
        SELECT count(*) AS total_stg
        FROM
            {{ ref('stg_website_sessions') }}
    ) AS s
WHERE
    m.total_mart != s.total_stg
