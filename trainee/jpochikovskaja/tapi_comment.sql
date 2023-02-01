
create or replace PACKAGE tapi_comment IS 
    procedure create_comment(article_id int, reply_to_id int, commenter varchar2, content clob);
   	procedure change_comment(id int, article_id int, reply_to_id int, commenter varchar2, content clob);
   	procedure add_like(id int);
   	procedure add_dislike(id int);
end tapi_comment;

create or replace PACKAGE BODY tapi_comment IS 	

procedure save_comment(ar_comm_id int, articleId int, replyToId int, commenterN varchar2, newContent clob)
    is 
    begin 
        merge into article_comment ac
        using( select id from article_comment ) ca on (ac.id = ar_comm_id)
        when matched then
            update set content = newContent 
        when not matched then 
            insert (article_id, reply_to_id, commenter, content) 
            values (articleId, replyToId, commenterN, newContent);
    end save_comment;

procedure create_comment(article_id int, reply_to_id int, commenter varchar2, content clob)
    is 
    begin save_comment(0, article_id, reply_to_id, commenter, content);
    dbms_output.put_line('Comment created');
    end create_comment;

procedure change_comment(id int, article_id int, reply_to_id int, commenter varchar2, content clob)
    is 
    begin save_comment( id, article_id, reply_to_id, commenter, content);
    dbms_output.put_line('Comment updated');
    end change_comment;   

procedure change_votes(id int, votesN int)
    is 
    begin 
        update article_comment set article_comment.votes= nvl(article_comment.votes, 0)+votesN where id = id;
    		dbms_output.put_line('Add Like(votes)'); 
    end change_votes;

procedure change_rating(id int, ratingN int)
    is 
    begin
        update article_comment set article_comment.rating=nvl(article_comment.rating, 0)+ratingN where id = id;
    		DBMS_OUTPUT.PUT_LINE('Add  Like(rating)');
    end change_rating;

procedure add_like(id int)
    is
	begin
        change_votes (id, 1);
        change_rating (id, 1);
            DBMS_OUTPUT.PUT_LINE('Add Like'); 
	end add_like;	

procedure add_dislike(id int)
    is
	begin   
        change_votes (id, 1);
        change_rating (id, -1);
            DBMS_OUTPUT.PUT_LINE('Add Dislike'); 
	end add_dislike;

END tapi_comment;