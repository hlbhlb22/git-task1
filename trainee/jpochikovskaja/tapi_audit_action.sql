--drop PROCEDURE auditProc;
--drop trigger article_audit;
--drop trigger article_comment_audit;

-- TODO: move this proc into tapi_audit package
create or replace PROCEDURE auditProc(
    v_table_name in varchar,
    v_user_name in varchar,
    v_action_type in char,
    v_action_summary in varchar)
IS 
BEGIN
  INSERT INTO audit_action(table_name, user_name, action_type, action_summary) 
    VALUES(v_table_name, v_user_name, v_action_type, v_action_summary);
END auditProc;

create or replace trigger article_audit
before insert or update or delete on article
for each row
DECLARE
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
         auditProc(v_table_name, v_user_name, v_action_type, v_action_summary);
    elsif updating 
        then v_action_type := 'U';
             v_action_summary := 'Update table article';
        auditProc(v_table_name, v_user_name, v_action_type, v_action_summary);
    elsif deleting 
        then v_action_type := 'D';
             v_action_summary := 'Delete from table article';
        auditProc(v_table_name, v_user_name, v_action_type, v_action_summary);
    end if;
    
    -- TODO: do a single call of auditProc(...) to avoid copy-paste'ing within if...else 
     COMMIT;
end;

create or replace trigger article_comment_audit
before insert or update or delete on article_comment
for each row
DECLARE
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
         auditProc(v_table_name, v_user_name, v_action_type, v_action_summary);
    elsif updating 
        then v_action_type := 'U';
             v_action_summary := 'Update table article_comment';
        auditProc(v_table_name, v_user_name, v_action_type, v_action_summary);
    elsif deleting 
        then v_action_type := 'D';
             v_action_summary := 'Delete from table article_comment';
        auditProc(v_table_name, v_user_name, v_action_type, v_action_summary);
    end if;
    
    -- TODO: do a single call of auditProc()
    
     COMMIT;
end;

create or replace context taudit using tapi_audit accessed globally;

create or replace PACKAGE tapi_audit IS
    procedure specify_secret_key(i_key varchar2);
    procedure enable_audit (i_table_name varchar2);
    procedure disable_audit (i_table_name varchar2);
end tapi_audit;

create or replace PACKAGE BODY tapi_audit IS 

i_password varchar2(25) := 'secret4576';

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
END tapi_audit;



