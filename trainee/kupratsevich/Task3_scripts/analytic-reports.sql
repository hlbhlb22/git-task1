CREATE OR REPLACE VIEW avg_articles_amount_per_weekday AS
    SELECT week_day,
           AVG(general_num_of_articles) num_of_articles
    FROM(
        SELECT TO_NUMBER(TO_CHAR(crt_dt, 'D')) week_day,
            COUNT(*) general_num_of_articles
        FROM dim_articles
        GROUP BY TO_NUMBER(TO_CHAR(crt_dt, 'D')), TRUNC(crt_dt, 'IW')
        )
    GROUP BY week_day
    ORDER BY 1;

CREATE OR REPLACE VIEW avg_comments_amount_per_day_hour AS
    WITH intermediate AS
        (
        SELECT
            TO_NUMBER(EXTRACT(HOUR FROM time_ival)) hour_period,
            COUNT(*) exact_num_of_comments
        FROM f_article_comment
        GROUP BY TO_NUMBER(EXTRACT(HOUR FROM time_ival))
        )
    SELECT
        hour_period,
        exact_num_of_comments,
        (
        exact_num_of_comments+
        LAG(exact_num_of_comments, 1, 0) OVER (ORDER BY hour_period)+
        LEAD(exact_num_of_comments, 1, 0) OVER (ORDER BY hour_period)
        )/3 rolling_num_of_comments
    FROM intermediate
    ORDER BY 1;