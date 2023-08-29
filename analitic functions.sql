select distinct TO_NUMBER(TO_CHAR(COL_CRT_DT, 'D')) AS WEEK_DAY, count(*) OVER (
    PARTITION BY TO_NUMBER(TO_CHAR(COL_CRT_DT, 'D'))
    ) as num_of_articals from SCD.DIM_ARTICLE;

SELECT DISTINCT
    hour_period,
    exact_num_of_comments,
    (LAG(exact_num_of_comments, 1, 0) OVER (ORDER BY hour_period) +
     exact_num_of_comments +
     LEAD(exact_num_of_comments,0,23) OVER (ORDER BY hour_period)) / 3 AS rolling_num_of_comments
FROM (
    SELECT
        TO_NUMBER(EXTRACT(HOUR FROM F.COL_TIME_IVAL)) AS hour_period,
        COUNT(*) AS exact_num_of_comments
    FROM F_ARTICLE_COMMENT F
    GROUP BY TO_NUMBER(EXTRACT(HOUR FROM F.COL_TIME_IVAL))
) Subquery
ORDER BY hour_period;




