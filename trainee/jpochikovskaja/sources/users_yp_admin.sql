create user yp_admin identified by innodba202301302
default tablespace users quota unlimited on users
temporary tablespace temp;

grant create session to yp_admin;
grant execute on yp_base.tapi_audit to yp_admin;
