CREATE USER yp_app IDENTIFIED BY innodba202301301
DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS
TEMPORARY TABLESPACE TEMP;

grant CREATE SESSION to yp_app;
grant EXECUTE on  yp_base.tapi_comment to yp_app;
grant insert on yp_base.article to yp_app;
grant select on yp_base.article to yp_app;
grant delete on yp_base.article to yp_app;
grant update on yp_base.article to yp_app;
grant select on  yp_base.article_comment_v to yp_app;