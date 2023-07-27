create user yp_app identified by innodba202301301
default tablespace users quota unlimited on users
temporary tablespace temp;

grant create session to yp_app;
grant execute on yp_base.tapi_comment to yp_app;
grant insert on  yp_base.article to yp_app;
grant select on  yp_base.article to yp_app;
grant delete on  yp_base.article to yp_app;
grant update on  yp_base.article to yp_app;
grant select on  yp_base.article_comment_v to yp_app;
