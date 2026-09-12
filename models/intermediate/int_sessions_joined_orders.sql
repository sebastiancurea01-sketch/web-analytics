WITH sessions AS (
    SELECT * FROM {{ ref('stg_website_session') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
)

SELECT
    s.session_id,
    s.session_date,
    s.user_id,
    s.utm_source,
    s.utm_campaign,
    o.order_id,
    o.price_usd,
    o.items_purchased,

    CASE
        WHEN o.order_id IS NOT NULL THEN 1
        ELSE 0
    END AS is_conversion,

    min(o.ordered_date) OVER (PARTITION BY o.user_id) AS first_order_date,

    -- new customer flag
    CASE
        -- session did not convert, no customer
        WHEN o.order_id IS NULL THEN NULL
        WHEN o.ordered_date = min(o.ordered_date) OVER (PARTITION BY o.user_id)
            THEN TRUE
        ELSE FALSE
    END AS is_new_customer
FROM sessions AS s
LEFT JOIN orders AS o
    ON s.session_id = o.session_id
