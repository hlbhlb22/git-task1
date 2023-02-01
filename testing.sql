SET SERVEROUTPUT ON

--yp_app 
insert into yp_base.article(author, title, content) values ('Test author-1', 'Test title-1', 'Test content-1');
insert into yp_base.article(author, title, content) values ('Test author-2', 'Test title-2', 'Test content-2');
insert into yp_base.article(title, content) values ('Test title-3', 'Test content-3');
insert into yp_base.article(author, content) values ('Test author-3', 'Test content-4');
insert into yp_base.article(author, title) values ('Test author-4', 'Test title-4');
insert into yp_base.article(author, title, content) values ('Test author-5', 'TEST TITLE-5', 'Test content-5');

select * from yp_base.article;

update yp_base.article set yp_base.article.title = 'TEST TITLE-6' where id = 18; 
update yp_base.article set yp_base.article.title = 'Test title-7' where id=19;
update yp_base.article set yp_base.article.author = 'Test author-6' where id=18;
update yp_base.article set yp_base.article.content = 'Test content-6' where id=19;
update yp_base.article set yp_base.article.title = null where id=19;
update yp_base.article set yp_base.article.author = null where id=18;
update yp_base.article set yp_base.article.content = null where id=19;

insert into yp_base.article(author, title, content) values ('Test author-7', 'Test title-8', 'Test content-7');

delete from yp_base.article where id = 24;

select * from yp_base.article_comment_v;

exec yp_base.tapi_comment.create_comment(18, null, 'commenter-1', 'content-1');
exec yp_base.tapi_comment.create_comment(18, 45, 'commenter-2', 'content-2');
exec yp_base.tapi_comment.create_comment(19, null, 'commenter-3', 'content-3');
exec yp_base.tapi_comment.create_comment(19, 47, 'commenter-4', 'content-4');
exec yp_base.tapi_comment.change_comment(48, 19, 47, 'commenter-4', 'content-5');

exec yp_base.tapi_comment.add_like(46);
exec yp_base.tapi_comment.add_dislike(47);

commit;

--yp_admin
exec yp_base.tapi_audit.specify_secret_key('secret4576');
exec yp_base.tapi_audit.enable_audit('article');
exec yp_base.tapi_audit.disable_audit('article');
exec yp_base.tapi_audit.enable_audit('article_comment');
exec yp_base.tapi_audit.disable_audit('article_comment');


