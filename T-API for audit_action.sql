CREATE OR REPLACE TRIGGER article_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON article
FOR EACH ROW
BEGIN
    if inserting then
        INSERT INTO AUDIT_ACTION (COL_TS, COL_TABLE_NAME, COL_USER_NAME, COL_ACTION_TYPE, COL_ACTION_SUMMARY, COL_TABLE_ID)
    VALUES (:NEW.COL_CRT_DT, 'article', user, 'I', 'Article operation: Insert', :NEW.ID);
    elsif updating then
        INSERT INTO AUDIT_ACTION (COL_TS, COL_TABLE_NAME, COL_USER_NAME, COL_ACTION_TYPE, COL_ACTION_SUMMARY, COL_TABLE_ID)
    VALUES (:NEW.COL_CRT_DT, 'article',user, 'U', 'Article operation: Update', :NEW.ID);
        elsif deleting then
        INSERT INTO AUDIT_ACTION (COL_TS, COL_TABLE_NAME, COL_USER_NAME, COL_ACTION_TYPE, COL_ACTION_SUMMARY, COL_TABLE_ID)
    VALUES (SYSTIMESTAMP, 'article', user, 'D', 'Article operation: Delete', :OLD.ID);
    end if;
END;



CREATE OR REPLACE TRIGGER article_comment_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON ARTICLE_COMMENT
FOR EACH ROW
BEGIN
    if inserting then
        INSERT INTO AUDIT_ACTION (COL_TS, COL_TABLE_NAME, COL_USER_NAME, COL_ACTION_TYPE, COL_ACTION_SUMMARY, COL_TABLE_ID)
    VALUES (SYSTIMESTAMP, 'article_comment', user, 'I', 'Article operation: Insert', :NEW.ID);
    elsif updating then
        INSERT INTO AUDIT_ACTION (COL_TS, COL_TABLE_NAME, COL_USER_NAME, COL_ACTION_TYPE, COL_ACTION_SUMMARY, COL_TABLE_ID)
    VALUES (SYSTIMESTAMP, 'article_comment',user, 'U', 'Article operation: Update', :NEW.ID);
        elsif deleting then
        INSERT INTO AUDIT_ACTION (COL_TS, COL_TABLE_NAME, COL_USER_NAME, COL_ACTION_TYPE, COL_ACTION_SUMMARY, COL_TABLE_ID)
    VALUES (SYSTIMESTAMP, 'article_comment', user, 'D', 'Article operation: Delete', :OLD.ID);
    end if;
END;

 CREATE CONTEXT blog_ctx USING BLOG_BASE.TAPI_AUDIT;

CREATE OR REPLACE PACKAGE tapi_audit IS
    PROCEDURE tapi_audit_specify_secret_key(i_key IN VARCHAR2);
    PROCEDURE tapi_audit_enable(i_table_name IN VARCHAR2);
    PROCEDURE tapi_audit_disable(i_table_name IN VARCHAR2);
END tapi_audit;

CREATE OR REPLACE PACKAGE BODY tapi_audit IS
    SECRET_KEY CONSTANT VARCHAR2(50) := 'your_secret_key_here';

    PROCEDURE tapi_audit_specify_secret_key(i_key IN VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN

        DBMS_SESSION.set_context('BLOG_CTX', 'SECRET_KEY', i_key);
    END tapi_audit_specify_secret_key;

    PROCEDURE tapi_audit_activate_trigger(i_table_name IN VARCHAR2, i_enable IN BOOLEAN DEFAULT TRUE) IS
        l_secret_key VARCHAR2(50);
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        SELECT SYS_CONTEXT('blog_ctx', 'SECRET_KEY') INTO l_secret_key FROM DUAL;
        IF l_secret_key = SECRET_KEY THEN
            IF i_enable THEN
                EXECUTE IMMEDIATE 'ALTER TRIGGER ' || i_table_name || '_audit_trigger ENABLE';
            ELSE
                EXECUTE IMMEDIATE 'ALTER TRIGGER ' || i_table_name || '_audit_trigger DISABLE';
            END IF;
        ELSE
            RAISE_APPLICATION_ERROR(-20204, 'Invalid secret key');
        END IF;
    END tapi_audit_activate_trigger;

    PROCEDURE tapi_audit_enable(i_table_name IN VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        tapi_audit_activate_trigger(i_table_name);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20203, 'Table not found');
    END;

    PROCEDURE tapi_audit_disable(i_table_name IN VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        tapi_audit_activate_trigger(i_table_name, FALSE);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20203, 'Table not found');
    END;
END tapi_audit;



