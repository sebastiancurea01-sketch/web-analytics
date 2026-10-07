WITH source AS (
    SELECT * FROM {{ source('web_analytics', 'website_sessions') }}
    {{ limit_data_in_dev('created_at') }}

),

RENAMED_AND_CAST AS (
    SELECT
        CAST(website_session_id AS STRING) AS session_id,
        CAST(CREATED_AT AS TIMESTAMP) AS session_timestamp,
        CAST(CREATED_AT AS DATE) AS session_date,
        CAST(USER_ID AS STRING) AS user_id,
        COALESCE(nullif(nullif(trim(utm_source), ''), 'NULL'), 'direct') as utm_source,
        nullif(nullif(trim(utm_content), ''), 'NULL') as utm_content,
        nullif(nullif(trim(utm_campaign), ''), 'NULL') as utm_campaign,
        device_type,
        COALESCE(nullif(nullif(trim(http_referer), ''), 'NULL'), 'direct') as http_referer
    FROM source
)

SELECT * FROM RENAMED_AND_CAST
