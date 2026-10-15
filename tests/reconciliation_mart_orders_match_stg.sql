SELECT
    m.total_mart,
    s.total_stg
FROM
    (
        SELECT SUM(tot_orders) AS total_mart
        FROM
            {{ ref('mrt_user_activity') }}
    ) AS m
CROSS JOIN
    (
        SELECT COUNT(order_id) AS total_stg
        FROM
            {{ ref('stg_orders') }}
    ) AS s
WHERE
    m.total_mart != s.total_stg
