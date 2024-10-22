CREATE OR REPLACE PACKAGE TAPI_COMMENT IS
    PROCEDURE tapi_comment_create(
        p_article_id IN article_comment.article_id%TYPE,
        p_commenter IN article_comment.commenter%TYPE,
        p_content IN article_comment.content%TYPE
    );

    PROCEDURE tapi_comment_change(
        p_reply_to_id IN article_comment.reply_to_id%TYPE,
        p_content IN article_comment.content%TYPE
    );

    PROCEDURE tapi_comment_add_like(
        p_article_comment_id IN article_comment.id%TYPE
    );

    PROCEDURE tapi_comment_add_dislike(
        p_article_comment_id IN article_comment.id%TYPE
    );
END TAPI_COMMENT;

CREATE OR REPLACE PACKAGE BODY TAPI_COMMENT IS
    PROCEDURE tapi_change_votes(
        p_article_comment_id IN article_comment.id%TYPE,
        p_votes_change IN INT DEFAULT 1
    ) IS
    BEGIN
        UPDATE article_comment
        SET votes = votes + p_votes_change
        WHERE id = p_article_comment_id;
    END tapi_change_votes;

    PROCEDURE tapi_change_rating(
        p_article_comment_id IN article_comment.id%TYPE,
        p_rating_change IN INT
    ) IS
    BEGIN
        UPDATE article_comment
        SET rating = rating + p_rating_change
        WHERE id = p_article_comment_id;
    END tapi_change_rating;

    PROCEDURE tapi_comment_add_like(
        p_article_comment_id   IN article_comment.id%TYPE
    ) IS
    BEGIN
        tapi_change_votes(p_article_comment_id, 1);
        tapi_change_rating(p_article_comment_id, 1);
    END tapi_comment_add_like;

    PROCEDURE tapi_comment_add_dislike(
        p_article_comment_id   IN article_comment.id%TYPE
    ) IS
    BEGIN
        tapi_change_votes(p_article_comment_id, -1);
        tapi_change_rating(p_article_comment_id, -1);
    END tapi_comment_add_dislike;

    PROCEDURE tapi_comment_save(
        p_article_id      IN article_comment.article_id%TYPE DEFAULT NULL,
        p_reply_to_id  IN article_comment.reply_to_id%TYPE DEFAULT 1,
        p_commenter    IN article_comment.commenter%TYPE DEFAULT NULL,
        p_content      IN article_comment.content%TYPE
    ) IS
    BEGIN
        MERGE INTO article_comment
        USING DUAL ON (id = p_reply_to_id)
        WHEN MATCHED THEN
            UPDATE
            SET content = p_content
        WHEN NOT MATCHED THEN
            INSERT (article_id,
                    commenter,
                    content,
                    reply_to_id,
                    votes,
                    rating,
                    like_amount,
                    dislike_amount)
            VALUES (p_article_id,
                    p_commenter,
                    p_content,
                    p_reply_to_id,
                    0,
                    0,
                    0,
                    0);
    EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ошибка при сохранении комментария: ' || SQLERRM);
    END tapi_comment_save;

    PROCEDURE tapi_comment_create(
        p_article_id IN article_comment.article_id%TYPE,
        p_commenter IN article_comment.commenter%TYPE,
        p_content IN article_comment.content%TYPE
    ) IS
    BEGIN
        tapi_comment_save(p_article_id=> p_article_id, p_commenter => p_commenter, p_content => p_content);
    END tapi_comment_create;

    PROCEDURE tapi_comment_change(
        p_reply_to_id IN article_comment.reply_to_id%TYPE,
        p_content IN article_comment.content%TYPE
    ) IS
    BEGIN
        tapi_comment_save(p_reply_to_id => p_reply_to_id, p_content => p_content);
    END tapi_comment_change;
END TAPI_COMMENT;

CREATE OR REPLACE VIEW article_comment_v(
    id, article_id, article_author, article_title, ts,
    rating, commenter, content, in_reply_to) AS
SELECT a_comm.id,
       a_comm.article_id,
       a.author,
       a.title,
       a_comm.ts,
       a_comm.rating,
       a_comm.commenter,
       a_comm.content,
       SUBSTR(a_comm_self.content, 1, 50) in_reply_to
FROM article_comment a_comm
    JOIN article a
        ON a_comm.article_id = a.id
    LEFT JOIN
        article_comment a_comm_self ON a_comm.reply_to_id = a_comm_self.id;