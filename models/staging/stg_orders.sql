WITH source AS (
    SELECT * FROM {{ source('backend_db', 'orders') }}
),

RENAMED_AND_CAST AS (
    SELECT
        CAST(ORDER_ID AS STRING) AS order_id,
        CAST(CREATED_AT AS TIMESTAMP) AS ordered_at,
        CAST(CREATED_AT AS DATE) AS ordered_date, 
        CAST(WEBSITE_SESSION_ID AS STRING) AS session_id,
        CAST(USER_ID AS STRING) AS user_id,
        CAST(PRIMARY_PRODUCT_ID AS STRING) AS primary_product_id,
        CAST(ITEMS_PURCHASED AS INT) AS items_purchased,
        CAST(PRICE_USD AS DECIMAL(10, 2)) AS price_usd,
        CAST(COGS_USD AS DECIMAL(10, 2)) AS cogs_usd
    FROM source
)

SELECT * FROM renamed_and_cast



