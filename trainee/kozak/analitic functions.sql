--rep1 average number of articles per week day
create view rep1 as select distinct TO_NUMBER(TO_CHAR(COL_CRT_DT, 'D')) AS WEEK_DAY, count(*) OVER (
    PARTITION BY TO_NUMBER(TO_CHAR(COL_CRT_DT, 'D'))
    ) as num_of_articals from SCD.DIM_ARTICLE;

--rep2 average number of comments per day hour
create view rep2 as SELECT DISTINCT
    hour_period,
    exact_num_of_comments,
    (LAG(exact_num_of_comments, 1, 0) OVER (ORDER BY hour_period) +
     exact_num_of_comments +
     LEAD(exact_num_of_comments,0,23) OVER (ORDER BY hour_period)) / 3
        AS rolling_num_of_comments
FROM (
    SELECT
        TO_NUMBER(EXTRACT(HOUR FROM F.COL_TIME_IVAL)) AS hour_period,
        COUNT(*) AS exact_num_of_comments
    FROM F_ARTICLE_COMMENT F
    GROUP BY TO_NUMBER(EXTRACT(HOUR FROM F.COL_TIME_IVAL))
) Subquery
ORDER BY hour_period;

-- package with pipelined functions

create or replace package stats as
     TYPE rep1 is record
                (
                    week_day int,
                    num_of_articles int
                );

    type rep2 is record
                 (
                     hour_period             int,
                     exact_num_of_comments   int,
                     rolling_num_of_comments double precision
                 );

    type rep1_table is table of rep1;
    type rep2_table is table of rep2;


    function report_articles( v_begin_date date, v_end_date date) return rep1_table pipelined;
    function report_comments( v_begin_date date, v_end_date date) return rep2_table pipelined;
end stats;

create or replace package body stats as
    function report_articles( v_begin_date date, v_end_date date) return rep1_table  pipelined as
        begin
            for rec in
                (
                select distinct TO_NUMBER(TO_CHAR(COL_CRT_DT, 'D')) AS WEEK_DAY, count(*) OVER (
    PARTITION BY TO_NUMBER(TO_CHAR(COL_CRT_DT, 'D'))
    ) as num_of_articals from SCD.DIM_ARTICLE
                where COL_CRT_DT between v_begin_date and  v_end_date               )
            loop
                pipe row ( rec );
                end loop;
        end;
        function report_comments( v_begin_date date, v_end_date date) return rep2_table  pipelined as
        begin
            for rec in
                (
                select DISTINCT hour_period,
                                exact_num_of_comments,
                                (LAG(exact_num_of_comments, 1, 0) OVER (ORDER BY hour_period) +
                                 exact_num_of_comments +
                                 LEAD(exact_num_of_comments, 0, 23) OVER (ORDER BY hour_period)) / 3
                                    AS rolling_num_of_comments
                FROM (SELECT TO_NUMBER(EXTRACT(HOUR FROM F.COL_TIME_IVAL)) AS hour_period,
                             COUNT(*)                                      AS exact_num_of_comments
                      FROM F_ARTICLE_COMMENT F
                               inner join DIM_DATES DD on DD.ID = F.COL_DATE_ID
                      where dd.COL_D_DATE between v_begin_date and v_end_date
                      GROUP BY TO_NUMBER(EXTRACT(HOUR FROM F.COL_TIME_IVAL))) Subquery
                ORDER BY hour_period
                )
                loop
                    pipe row ( rec );
                end loop;
        end;
end;
    --test
declare
    v_begin_date date := TO_DATE('2023-08-24', 'YYYY-MM-DD');
    v_end_date date := TO_DATE('2023-08-30', 'YYYY-MM-DD');
begin
    for rep_rec in (
        select *
        from table(stats.report_articles(v_begin_date, v_end_date)) rep
    )
    loop
         DBMS_OUTPUT.PUT_LINE(rep_rec.week_day || ': ' || rep_rec.num_of_articles);
    end loop;
    for rep_rec in (
        select *
        from table(stats.report_comments(v_begin_date, v_end_date)) rep
    )
    loop
         DBMS_OUTPUT.PUT_LINE(rep_rec.rolling_num_of_comments || ' ' || rep_rec.exact_num_of_comments|| ' ' ||rep_rec.hour_period);
    end loop;

end;











