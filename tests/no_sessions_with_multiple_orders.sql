{{ config(severity='error') }}

SELECT
    session_id,
    COUNT(DISTINCT order_id) AS order_count
FROM {{ ref('stg_orders') }}
GROUP BY session_id
HAVING COUNT(DISTINCT order_id) > 1
