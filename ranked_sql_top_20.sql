-- general ranked top 20

WITH key_dates AS (
    SELECT
         date'2024-01-01' AS start_date
       , date'2025-01-01' AS end_date    
),

base_data AS (
    SELECT 
        DATE(datetime) AS event_date 
        , attribute_1,
        , attribute_2,
        , company_id
        , company_name
        , CASE 
            WHEN COALESCE(type_group,'Others') IN ('Type A', 'Type B') THEN 'Group 1'
            WHEN COALESCE(type_group,'Others') IN ('Type C') THEN 'Group 2'
            ELSE 'Other Groups'
         END AS entity_group,

        , SUM(metric_1) AS metric_1_sum
        , SUM(metric_2) AS metric_2_sum
        , SUM(CASE WHEN condition_flag = 1 THEN metric_1 END) AS filtered_metric_1_sum
        , SUM(CASE WHEN condition_flag = 1 THEN metric_2 END) AS filtered_metric_2_sum
        , SUM(count_metric) AS total_count
        , SUM(CASE WHEN condition_flag = 1 THEN count_metric END) AS filtered_count
    FROM data_source
    WHERE (
        DATE(datetime) between (SELECT start_date FROM key_dates) and (SELECT end_date FROM key_dates) 
        )
    GROUP BY 1,2,3,4,5,6
),

aggregated_data AS (
    SELECT 
        attribute_1,
        attribute_2,
        company_id,
        company_name,
        entity_group,
        
        SUM(metric_1_sum) AS total_metric_1,
        SUM(metric_2_sum) AS total_metric_2,
        SUM(filtered_metric_1_sum) AS total_filtered_metric_1,
        SUM(filtered_metric_2_sum) AS total_filtered_metric_2,
        SUM(total_count) AS total_count,
        SUM(filtered_count) AS total_filtered_count
    
    FROM filtered_data
    GROUP BY 1,2,3,4,5
),

ranked_entities AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY entity_group ORDER BY total_metric_1 DESC) AS ranking
    FROM aggregated_data
)

SELECT *
FROM ranked_entities
WHERE ranking <= 20
ORDER BY entity_group, ranking;
