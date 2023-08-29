CREATE OR REPLACE PACKAGE TAPI_COMMENT IS
    procedure tapi_comment_create(p_commenter IN article_comment.col_commenter%TYPE,
                                  p_content IN article_comment.col_content%TYPE,
                                  p_article      IN article_comment.col_article_id%TYPE
                                 );
    procedure tapi_comment_change(
                                  p_reply_to_id IN article_comment.col_reply_to_id%TYPE,
                                  p_content IN article_comment.col_content%TYPE
                                );
    PROCEDURE tapi_comment_add_like(
        p_comment_id IN article_comment.id%TYPE
    );
    PROCEDURE tapi_comment_add_dislike(
        p_comment_id IN article_comment.id%TYPE
    );
end;



CREATE OR REPLACE PACKAGE BODY TAPI_COMMENT IS
    PROCEDURE tapi_comment_save(
        p_reply_to_id  IN article_comment.col_reply_to_id%TYPE DEFAULT NULL,
        p_commenter    IN article_comment.col_commenter%TYPE DEFAULT NULL,
        p_content      IN article_comment.col_content%TYPE,
        p_article      IN article_comment.col_article_id%TYPE DEFAULT NULL
    ) IS
    BEGIN
        MERGE INTO article_comment ac
        USING DUAL
        ON (ac.id = p_reply_to_id)
        WHEN MATCHED THEN
            UPDATE
            SET
                col_content     = p_content
        WHEN NOT MATCHED THEN
            INSERT (col_commenter,
                    col_content,
                    COL_ARTICLE_ID,
                    COL_VOTES,
                    COL_RATING)
            VALUES (p_commenter,
                    p_content,
                    p_article,
                    0,
                    0);
    END tapi_comment_save;
    procedure tapi_comment_create(p_commenter IN article_comment.col_commenter%TYPE,
                                  p_content IN article_comment.col_content%TYPE,
                                  p_article      IN article_comment.col_article_id%TYPE
                    ) is
        begin
          tapi_comment_save(p_content => p_content, p_commenter => p_commenter, p_article=> p_article);
        end;
    procedure tapi_comment_change(
                                  p_reply_to_id  IN article_comment.col_reply_to_id%TYPE,
                                  p_content IN article_comment.col_content%TYPE
                                  ) is
        begin
            tapi_comment_save(p_reply_to_id => p_reply_to_id, p_content => p_content);
        end;
         PROCEDURE tapi_change_votes(
        p_comment_id   IN article_comment.id%TYPE,
        p_votes_change IN NUMBER
    ) IS
    BEGIN
        UPDATE article_comment
        SET col_votes = col_votes + p_votes_change
        WHERE id = p_comment_id;
    END tapi_change_votes;

    PROCEDURE tapi_change_rating(
        p_comment_id   IN article_comment.id%TYPE,
        p_rating_change IN NUMBER
    ) IS
    BEGIN
        UPDATE article_comment
        SET col_rating = col_rating + p_rating_change
        WHERE id = p_comment_id;
    END tapi_change_rating;
        PROCEDURE tapi_comment_add_like(
        p_comment_id   IN article_comment.id%TYPE
    ) IS
    BEGIN
        tapi_change_votes(p_comment_id, 1);
        tapi_change_rating(p_comment_id, 1);
    END tapi_comment_add_like;

    PROCEDURE tapi_comment_add_dislike(
        p_comment_id   IN article_comment.id%TYPE
    ) IS
    BEGIN
        tapi_change_votes(p_comment_id, -1);
        tapi_change_rating(p_comment_id, -1);
    END tapi_comment_add_dislike;
END TAPI_COMMENT;

CREATE VIEW article_comment_v
            (id, article_id, article_author, article_title, ts, rating, commenter, content, in_reply_to)
AS
SELECT ac.id,
       ac.col_article_id,
       a.col_author,
       a.col_title,
       ac.col_ts,
       ac.col_rating,
       ac.col_commenter,
       ac.col_content,
       SUBSTR(ac_reply.col_content, 1, 50) AS in_reply_to
FROM article_comment ac
         JOIN
     article a ON ac.col_article_id = a.id
         LEFT JOIN
     article_comment ac_reply ON ac.col_reply_to_id = ac_reply.id;

BEGIN
    TAPI_COMMENT.tapi_comment_create('NXBVCXN', 'KDJ', 30);
end;