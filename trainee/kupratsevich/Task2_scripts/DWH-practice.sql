CREATE OR REPLACE PACKAGE etl_blog AS
    PROCEDURE etl_load_articles;
    PROCEDURE etl_load_comments;
END etl_blog;

create PACKAGE BODY etl_blog AS
    PROCEDURE etl_load_articles IS
        CURSOR c_articles IS SELECT DISTINCT id, mod_dt, author, title, content FROM C##FIRST_USER.article;
        dim_article_rows_amount INT;
    BEGIN
        FOR article_record IN c_articles LOOP
            SELECT COUNT(*) INTO dim_article_rows_amount
            FROM dim_articles
                JOIN C##FIRST_USER.article a
                    ON a.id = dim_articles.nid
            WHERE dim_articles.nid = article_record.id
                AND (a.ctr_dt = dim_articles.crt_dt OR a.mod_dt = dim_articles.crt_dt);
            IF dim_article_rows_amount = 0 THEN
                UPDATE dim_articles
                SET is_act_ind = NULL, end_dt = CURRENT_TIMESTAMP
                WHERE nid = article_record.id AND is_act_ind = 1;

                INSERT INTO dim_articles(nid, crt_dt, mod_dt, author, title, content)
                    SELECT id, ctr_dt, mod_dt, author, title, content
                    FROM C##FIRST_USER.article a
                    WHERE a.id = article_record.id;

            ELSIF dim_article_rows_amount >= 1 THEN
                UPDATE dim_articles
                SET mod_dt = article_record.mod_dt,
                    author = article_record.author,
                    title = article_record.title,
                    content = article_record.content
                WHERE nid = article_record.id AND is_act_ind = 1;
            END IF;
        END LOOP;
    END etl_load_articles;

    PROCEDURE etl_load_comments IS
    BEGIN
        MERGE INTO f_article_comment fac
        USING(
            SELECT
                da.sid article_sid,
                dd.id date_id,
                ac.id comment_id,
                NUMTODSINTERVAL(EXTRACT(DAY FROM ac.ts), 'DAY')
                + NUMTODSINTERVAL(EXTRACT(HOUR FROM ac.ts), 'HOUR')
                + NUMTODSINTERVAL(EXTRACT(MINUTE FROM ac.ts), 'MINUTE')
                + NUMTODSINTERVAL(EXTRACT(SECOND FROM ac.ts), 'SECOND')
                AS time_ival,
                ac.rating AS rating,
                ac.votes AS votes,
                ac.content AS content,
                aa.action_type AS action_type
            FROM C##FIRST_USER.article_comment ac
                JOIN C##FIRST_USER.article a ON ac.article_id = a.id
                JOIN dim_dates dd
                    ON TRUNC(ac.ts) = dd.d_date
                JOIN C##FIRST_USER.audit_action aa ON ac.id = aa.row_id
                JOIN dim_articles da ON a.id = da.NID
            WHERE aa.id = (SELECT MAX(id) FROM C##FIRST_USER.audit_action WHERE row_id = ac.id)
            ) data
        ON (fac.comment_id = data.comment_id)
        WHEN MATCHED THEN
            UPDATE SET
                article_sid = data.article_sid,
                time_ival = data.time_ival,
                rating = data.rating,
                votes = data.votes,
                content = data.content,
                action_type = data.action_type
        WHEN NOT MATCHED THEN
            INSERT(article_sid,
                   date_id,
                   comment_id,
                   time_ival,
                   rating,
                   votes,
                   content,
                   action_type)
            VALUES(data.article_sid,
                   data.date_id,
                   data.comment_id,
                   data.time_ival,
                   data.rating,
                   data.votes,
                   data.content,
                   data.action_type);
    END etl_load_comments;
END etl_blog;

CREATE OR REPLACE FUNCTION date_to_int(current_date IN DATE) RETURN INT IS
BEGIN
    RETURN TO_NUMBER(TO_CHAR(current_date, 'DDMMYYYY'));
END;

CREATE OR REPLACE PROCEDURE add_daily_record IS
    start_date DATE := TO_DATE('2024-08-01', 'YYYY-MM-DD');
    end_date DATE := TO_DATE('2024-10-01', 'YYYY-MM-DD');
    current_date DATE := start_date;
BEGIN
    LOOP
        EXIT WHEN current_date >= end_date;
        INSERT INTO DIM_DATES(
                    ID,
                    D_DATE,
                    D_YEAR,
                    HALF_YEAR,
                    D_QUARTER,
                    D_MONTH,
                    NAME_MONTH,
                    D_DAY,
                    D_WEEK,
                    BEGIN_OF_MONTH,
                    END_OF_MONTH)
            VALUES(
                    date_to_int(current_date),
                    TO_DATE(TO_CHAR(current_date, 'YYYY-MM-DD'), 'YYYY-MM-DD'),
                    EXTRACT(YEAR FROM current_date),
                    TO_NUMBER(EXTRACT(MONTH FROM current_date)),
                    TO_NUMBER(CEIL(EXTRACT(MONTH FROM current_date) / 3)),
                    TO_NUMBER(EXTRACT(MONTH FROM current_date)),
                    TO_CHAR(current_date, 'Month'),
                    TO_NUMBER(TO_CHAR( current_date, 'D')),
                    TO_NUMBER(CEIL(EXTRACT(DAY FROM current_date)/7)),
                    1,
                    TO_NUMBER(TO_CHAR(LAST_DAY(current_date), 'DD'))
                );
        current_date := current_date + 1;
    END LOOP;
    COMMIT;
END add_daily_record;

BEGIN
    DBMS_SCHEDULER.CREATE_PROGRAM(
        program_name        => 'job_load_articles',
        program_type        => 'PLSQL_BLOCK',
        program_action      => 'BEGIN etl_blog.etl_load_articles(); END;',
        enabled             => TRUE
    );

    DBMS_SCHEDULER.CREATE_PROGRAM(
        program_name        => 'job_load_comments',
        program_type        => 'PLSQL_BLOCK',
        program_action      => 'BEGIN etl_blog.etl_load_comments(); END;',
        enabled             => FALSE
    );

    DBMS_SCHEDULER.CREATE_CHAIN(
        chain_name => 'SCD_CHAIN'
    );

    DBMS_SCHEDULER.DEFINE_CHAIN_STEP(
        chain_name => 'SCD_CHAIN',
        step_name  => 'SCD_etl_load_articles',
        program_name => 'job_load_articles'
    );

    DBMS_SCHEDULER.DEFINE_CHAIN_STEP(
        chain_name => 'SCD_CHAIN',
        step_name  => 'SCD_etl_load_comments',
        program_name => 'job_load_comments'
    );

    DBMS_SCHEDULER.DEFINE_CHAIN_RULE(
        chain_name => 'SCD_CHAIN',
        condition  => '1=1',
        action     => 'START SCD_etl_load_articles',
        rule_name  => 'RULE_START_CHAIN'
    );

    DBMS_SCHEDULER.DEFINE_CHAIN_RULE(
        chain_name => 'SCD_CHAIN',
        condition  => 'SCD_etl_load_articles SUCCEEDED',
        action     => 'START SCD_etl_load_comments',
        rule_name  => 'RULE_CONTINUE_CHAIN'
    );
END;