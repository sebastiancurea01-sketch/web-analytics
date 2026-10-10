WITH source AS (
    SELECT * FROM {{ source('backend_db', 'orders') }}
    {{ limit_data_in_dev('created_at') }}
),

renamed_and_cast AS (
    SELECT
        CAST(order_id AS STRING) AS order_id,
        CAST(created_at AS TIMESTAMP) AS ordered_at,
        CAST(created_at AS DATE) AS ordered_date,
        CAST(website_session_id AS STRING) AS session_id,
        CAST(user_id AS STRING) AS user_id,
        CAST(items_purchased AS INT) AS items_purchased,
        CAST(price_usd AS DECIMAL(10, 2)) AS price_usd
    FROM source
)

SELECT * FROM renamed_and_cast
