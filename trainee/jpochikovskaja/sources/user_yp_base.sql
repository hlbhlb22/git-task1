CREATE USER yp_base IDENTIFIED BY innodba20230130
DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS
TEMPORARY TABLESPACE TEMP;

grant CREATE SESSION to yp_base;
grant create table to yp_base;
grant CREATE SEQUENCE to yp_base;
grant create VIEW to yp_base;
grant create PROCEDURE to yp_base;
grant create TRIGGER to yp_base;
GRANT CREATE ANY CONTEXT TO yp_base;
