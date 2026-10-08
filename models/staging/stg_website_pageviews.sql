WITH source AS (
    SELECT * FROM {{ source('web_analytics', 'website_pageviews') }}
    {{ limit_data_in_dev('created_at') }}
),

renamed_and_cast AS (
    SELECT
        CAST(website_pageview_id AS STRING) AS pageview_id,
        CAST(created_at AS TIMESTAMP) AS pageview_timestamp,
        CAST(website_session_id AS STRING) AS session_id,
        CAST(pageview_url AS STRING) AS pageview_url
    FROM source
)

SELECT * FROM renamed_and_cast
