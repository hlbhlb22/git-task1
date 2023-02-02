create or replace package tapi_comment is 
    procedure create_comment(i_article_id int, i_reply_to_id int, i_commenter varchar2, i_content clob);
   	procedure change_comment(i_ac_id int, i_article_id int, i_reply_to_id int, i_commenter varchar2, i_content clob);
   	procedure add_like(i_ac_id int);
   	procedure add_dislike(i_ac_id int);
end tapi_comment;
/
create or replace package body tapi_comment is 	

procedure save_comment(i_ac_id int, i_article_id int, i_reply_to_id int, i_commenter varchar2, i_content clob)
    is 
        v_cnt int:= 0;
    begin 
        select count(*) into v_cnt from article_comment ac where ac.id = i_ac_id;
        dbms_output.put_line('cnt (cn):' || v_cnt);
        if v_cnt = 0 then
            insert into article_comment(article_id, reply_to_id, commenter, content)
                values(i_article_id, i_reply_to_id, i_commenter, i_content);
                v_cnt:=sql%rowcount;
                dbms_output.put_line( 'cnt (ins):' || v_cnt);
        else 
            update article_comment set content = i_content where id = i_ac_id;
        end if;             
    end save_comment;


procedure create_comment(i_article_id int, i_reply_to_id int, i_commenter varchar2, i_content clob)
    is 
    begin save_comment(0, i_article_id, i_reply_to_id, i_commenter, i_content);
    dbms_output.put_line('Comment created');
    end create_comment;

procedure change_comment(i_ac_id int, i_article_id int, i_reply_to_id int, i_commenter varchar2, i_content clob)
    is 
    begin save_comment( i_ac_id, i_article_id, i_reply_to_id, i_commenter, i_content);
    dbms_output.put_line('Comment updated');
    end change_comment;   

procedure change_votes(i_ac_id int, i_votes int)
    is 
    begin 
        update article_comment set article_comment.votes= nvl(article_comment.votes, 0)+i_votes where id = i_ac_id;
    		dbms_output.put_line('Add Like(votes)'); 
    end change_votes;

procedure change_rating(i_ac_id int, i_rating int)
    is 
    begin
        update article_comment set article_comment.rating=nvl(article_comment.rating, 0)+i_rating where id = i_ac_id;
    		dbms_output.put_line('Add  Like(rating)');
    end change_rating;

procedure add_like(i_ac_id int)
    is
	begin
        change_votes (i_ac_id, 1);
        change_rating (i_ac_id, 1);
            dbms_output.put_line('Add Like'); 
	end add_like;	

procedure add_dislike(i_ac_id int)
    is
	begin   
        change_votes (i_ac_id, 1);
        change_rating (i_ac_id, -1);
            dbms_output.put_line('Add Dislike'); 
	end add_dislike;

end tapi_comment;
/
