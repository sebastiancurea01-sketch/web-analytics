WITH source AS (
    SELECT * FROM {{ source('web_analytics', 'website_pageviews') }}
    {{ limit_data_in_dev('created_at') }}
),

renamed_and_cast AS (
    SELECT
        CAST(WEBSITE_PAGEVIEW_ID AS STRING) AS pageview_id,
        CAST(CREATED_AT AS TIMESTAMP) AS pageview_timestamp,
        CAST(WEBSITE_SESSION_ID AS STRING) AS session_id,
        CAST(PAGEVIEW_URL AS STRING) AS pageview_url
    FROM source
)

SELECT * FROM renamed_and_cast        
