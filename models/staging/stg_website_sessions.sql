WITH source AS (
    SELECT * FROM {{ source('web_analytics', 'website_sessions') }}
    {{ limit_data_in_dev('created_at') }}

),

renamed_and_cast AS (
    SELECT
        CAST(website_session_id AS STRING) AS session_id,
        CAST(created_at AS TIMESTAMP) AS session_timestamp,
        CAST(created_at AS DATE) AS session_date,
        CAST(user_id AS STRING) AS user_id,
        device_type,
        COALESCE(NULLIF(NULLIF(TRIM(utm_source), ''), 'NULL'), 'direct') AS utm_source,
        NULLIF(NULLIF(TRIM(utm_content), ''), 'NULL') AS utm_content,
        NULLIF(NULLIF(TRIM(utm_campaign), ''), 'NULL') AS utm_campaign,
        COALESCE(NULLIF(NULLIF(TRIM(http_referer), ''), 'NULL'), 'direct') AS http_referer
    FROM source
)

SELECT * FROM renamed_and_cast
