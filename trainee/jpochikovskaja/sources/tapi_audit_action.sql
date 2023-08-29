create or replace package tapi_audit IS
    procedure auditProc(i_table_name in varchar, i_user_name in varchar, i_action_type in char, i_action_summary in varchar);
    procedure specify_secret_key(i_key varchar2);
    procedure enable_audit (i_table_name varchar2);
    procedure disable_audit (i_table_name varchar2);
end tapi_audit;
/

create or replace package body tapi_audit IS 

i_password varchar2(25) := 'secret4576';

procedure auditProc(
    i_table_name in varchar,
    i_user_name in varchar,
    i_action_type in char,
    i_action_summary in varchar)
    is
    begin
        insert into audit_action(table_name, user_name, action_type, action_summary) 
            values (i_table_name, i_user_name, i_action_type, i_action_summary);
    end auditProc;

procedure specify_secret_key(i_key varchar2)
    is
    begin 
        dbms_session.set_context('taudit', 'SECRET_KEY', i_key);
    end;    

procedure activate_audit_trigger(i_table_name varchar2, i_enable boolean )
    is 
        v_cnt int;
        v_trg_name varchar2(25);
        v_mode varchar2(25);
    begin
        if sys_context('taudit', 'SECRET_KEY') != i_password
            then RAISE EXCEPTION_PACKAGE.NO_ACCESS;
        end if;
        select count(*) into v_cnt from all_tables t where upper(t.table_name) = upper(i_table_name);
            if v_cnt != 1
                then RAISE EXCEPTION_PACKAGE.TABLE_NOTFOUNT;
            end if;   
        v_trg_name := i_table_name || '_AUDIT';
        v_mode := case when i_enable then 'ENABLE' else 'DISABLE' end;
        execute immediate 'alter trigger ' || v_trg_name || ' ' || v_mode; 
    exception 
        when EXCEPTION_PACKAGE.NO_ACCESS then
            RAISE_APPLICATION_ERROR(EXCEPTION_PACKAGE.ID_NO_ACCESS, 'No access');
        when EXCEPTION_PACKAGE.TABLE_NOTFOUNT then
            RAISE_APPLICATION_ERROR(EXCEPTION_PACKAGE.ID_TABLE_NOTFOUNT, 'Table ' || i_table_name || ' doesn''t exist');
    end;  

procedure enable_audit(i_table_name varchar2)
    is 
    begin
       activate_audit_trigger(i_table_name, true);
    end;

procedure disable_audit(i_table_name varchar2)
    is        
    begin
       activate_audit_trigger(i_table_name, false);
    end;
end tapi_audit;
/

create or replace trigger article_audit
before insert or update or delete on article
for each row
declare
   PRAGMA AUTONOMOUS_TRANSACTION;
   v_table_name varchar(128);
   v_action_type char(1);
   v_action_summary varchar(250);
   v_user_name varchar(128);

begin
    v_table_name := 'article';
    
    select username into  v_user_name  from user_users;
    
    if inserting
        then v_action_type := 'I';
             v_action_summary := 'Insert into table article';
    elsif updating 
        then v_action_type := 'U';
             v_action_summary := 'Update table article';
    elsif deleting 
        then v_action_type := 'D';
             v_action_summary := 'Delete from table article';       
    end if;
    tapi_audit.auditProc(v_table_name, v_user_name, v_action_type, v_action_summary);
    commit;
end;
/

create or replace trigger article_comment_audit
before insert or update or delete on article_comment
for each row
declare
   PRAGMA AUTONOMOUS_TRANSACTION;
   v_table_name varchar(128);
   v_action_type char(1);
   v_action_summary varchar(250);
   v_user_name varchar(128);

begin
    v_table_name := 'article_comment';
    
    select username into  v_user_name  from user_users;

    if inserting
        then v_action_type := 'I';
             v_action_summary := 'Insert into table article_comment';
    elsif updating 
        then v_action_type := 'U';
             v_action_summary := 'Update table article_comment';
    elsif deleting 
        then v_action_type := 'D';
             v_action_summary := 'Delete from table article_comment';
    end if;
    tapi_audit.auditProc(v_table_name, v_user_name, v_action_type, v_action_summary);
    commit;
end;
/

alter trigger article_audit disable
/
alter trigger article_comment_audit disable
/
create or replace context taudit using tapi_audit accessed globally
/
