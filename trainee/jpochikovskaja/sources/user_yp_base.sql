create user yp_base IDENTIFIED BY innodba20230130
default tablespace users quota unlimited on users
temporary tablespace temp;

grant create session to yp_base;
grant create table to yp_base;
grant create sequence to yp_base;
grant create view to yp_base;
grant create procedure to yp_base;
grant create trigger to yp_base;
grant create any context to yp_base;
