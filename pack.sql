CREATE OR REPLACE PACKAGE etl_blog AS
    PROCEDURE etl_load_articles(p_nid in SCD.dim_article.col_nid);
    PROCEDURE etl_load_comments(p_commenter IN article_comment.col_commenter%TYPE,
                                  p_reply_to_id IN article_comment.col_reply_to_id%TYPE,
                                  p_content IN article_comment.col_content%TYPE);
END etl_blog;

    CREATE OR REPLACE PACKAGE BODY etl_blog AS
    PROCEDURE etl_load_articles IS
    BEGIN
          MERGE INTO SCD.dim_article f
    USING source_comments c
    ON (f.COL_ARTICLE_SID = c.article_id AND f.COL_DATE_ID = c.date_id)
    WHEN MATCHED THEN
        UPDATE SET
    END etl_load_articles;

    PROCEDURE etl_load_comments IS
    BEGIN

    END etl_load_comments;
END etl_blog;