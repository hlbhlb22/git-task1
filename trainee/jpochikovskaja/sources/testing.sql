SET SERVEROUTPUT ON

--yp_admin
--Enable AUDIT
exec c##yp_base.tapi_audit.specify_secret_key('secret4576');
exec c##yp_base.tapi_audit.enable_audit('article');
exec c##yp_base.tapi_audit.disable_audit('article');
exec c##yp_base.tapi_audit.enable_audit('article_comment');
exec c##yp_base.tapi_audit.disable_audit('article_comment');
commit;

--yp_app 
--INSERT INTO ARTICLE
insert into c##yp_base.article(author, title, content) values ('Test author-1', 'Test title-1', 'Test content-1');
insert into c##yp_base.article(author, title, content) values ('Test author-2', 'Test title-2', 'Test content-2');
insert into c##yp_base.article(title, content) values ('Test title-3', 'Test content-3');
insert into c##yp_base.article(author, content) values ('Test author-3', 'Test content-4');
insert into c##yp_base.article(author, title) values ('Test author-4', 'Test title-4');
insert into c##yp_base.article(author, title, content) values ('Test author-5', 'TEST TITLE-5', 'Test content-5');
insert into c##yp_base.article(author, title, content) values ('Test author-22', 'Test title-22', 'Test content-22');
insert into c##yp_base.article(author, title, content) values ('Test author-7', 'Test title-8', 'Test content-7');

--
select * from c##yp_base.article;

--UPDATE ARTICLE
update c##yp_base.article set c##yp_base.article.title = 'TEST TITLE-6' where id = 1; 
update c##yp_base.article set c##yp_base.article.title = 'Test title-7' where id=9;
update c##yp_base.article set c##yp_base.article.author = 'Test author-6' where id=1;
update c##yp_base.article set c##yp_base.article.content = 'Test content-6' where id=2;
update c##yp_base.article set c##yp_base.article.title = null where id=2;
update c##yp_base.article set c##yp_base.article.author = null where id=1;
update c##yp_base.article set c##yp_base.article.content = null where id=2;

--DELETE ARTICLE
delete from c##yp_base.article where id = 10;

--
select * from c##yp_base.article_comment_v;

--PROCEDURE CREATE COMMENT
exec c##yp_base.tapi_comment.create_comment(1, null, 'commenter-1', 'content-1');
exec c##yp_base.tapi_comment.create_comment(1, 1, 'commenter-2', 'content-2');
exec c##yp_base.tapi_comment.create_comment(2, null, 'commenter-3', 'content-3');
exec c##yp_base.tapi_comment.create_comment(2, 3, 'commenter-4', 'content-4');

--PROCEDURE CHANGE COMMENT
exec c##yp_base.tapi_comment.change_comment(4, 2, 3, 'commenter-4', 'content-5');

--PROCEDURE ADD LIKE
exec c##yp_base.tapi_comment.add_like(2);

--PROCEDURE ADD DISLIKE
exec c##yp_base.tapi_comment.add_dislike(2);

commit;

--yp_base
select * from audit_action;
select * from article;
select * from article_comment;
select * from article_comment_v;
------
delete from article;
delete from article_comment;
delete from audit_action;
