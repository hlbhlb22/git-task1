
CREATE USER yp_base IDENTIFIED BY innodba20230130
DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS
TEMPORARY TABLESPACE TEMP
      
grant CREATE SESSION to yp_base;
grant create table to yp_base;
grant CREATE SEQUENCE to yp_base;
grant create VIEW to yp_base;
grant create PROCEDURE to yp_base;
grant create TRIGGER to yp_base;
GRANT CREATE ANY CONTEXT TO yp_base;

CREATE USER yp_app IDENTIFIED BY innodba202301301
DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS
TEMPORARY TABLESPACE TEMP

grant CREATE SESSION to yp_app;
grant EXECUTE on  yp_base.tapi_comment to yp_app;
grant insert on yp_base.article to yp_app;
grant select on yp_base.article to yp_app;
grant delete on yp_base.article to yp_app;
grant update on yp_base.article to yp_app;
grant select on  yp_base.article_comment_v to yp_app;

CREATE USER yp_admin IDENTIFIED BY innodba202301302
DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS
TEMPORARY TABLESPACE TEMP

grant CREATE SESSION to yp_admin;
grant EXECUTE on  yp_base.tapi_audit to yp_admin;





