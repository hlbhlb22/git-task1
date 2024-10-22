CREATE OR REPLACE TRIGGER trg_article_before_insert_update_delete
BEFORE INSERT OR UPDATE OR DELETE ON article
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO AUDIT_ACTION (TS, TABLE_NAME, ROW_ID, USER_NAME, ACTION_TYPE, ACTION_SUMMARY)
        VALUES (:NEW.ctr_dt, 'article', :NEW.id, user, 'I', 'Insertion');
    ELSIF UPDATING THEN
        INSERT INTO AUDIT_ACTION (TS, TABLE_NAME, ROW_ID, USER_NAME, ACTION_TYPE, ACTION_SUMMARY)
        VALUES (:NEW.ctr_dt, 'article', :NEW.id, user, 'U', 'Update');
    ELSIF DELETING THEN
        INSERT INTO AUDIT_ACTION (TS, TABLE_NAME, ROW_ID, USER_NAME, ACTION_TYPE, ACTION_SUMMARY)
        VALUES (SYSTIMESTAMP, 'article', :OLD.id, user, 'D', 'Deletion');
    END IF;
END trg_article_before_insert_update_delete;

CREATE OR REPLACE TRIGGER trg_article_comment_before_insert_update_delete
BEFORE INSERT OR UPDATE OR DELETE ON article_comment
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO AUDIT_ACTION (TS, TABLE_NAME, ROW_ID, USER_NAME, ACTION_TYPE, ACTION_SUMMARY)
        VALUES (SYSTIMESTAMP, 'article_comment', :NEW.id, user, 'I', 'Insertion');
    ELSIF UPDATING THEN
        INSERT INTO AUDIT_ACTION (TS, TABLE_NAME, ROW_ID, USER_NAME, ACTION_TYPE, ACTION_SUMMARY)
        VALUES (SYSTIMESTAMP, 'article_comment', :NEW.id, user, 'U', 'Update');
    ELSIF DELETING THEN
        INSERT INTO AUDIT_ACTION (TS, TABLE_NAME, ROW_ID, USER_NAME, ACTION_TYPE, ACTION_SUMMARY)
        VALUES (SYSTIMESTAMP, 'article_comment', :OLD.id, user, 'D', 'Deletion');
    END IF;
END trg_article_comment_before_insert_update_delete;

CREATE OR REPLACE PACKAGE tapi_audit IS
    PROCEDURE tapi_audit_specify_secret_key(i_key IN VARCHAR2);
    PROCEDURE tapi_audit_enable(i_table_name IN VARCHAR2);
    PROCEDURE tapi_audit_disable(i_table_name IN VARCHAR2);
END tapi_audit;

CREATE OR REPLACE PACKAGE BODY tapi_audit IS
    SECRET_KEY CONSTANT VARCHAR2(50) := 'most_secret_key';

    PROCEDURE tapi_audit_specify_secret_key(i_key IN VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        DBMS_SESSION.set_context('blog_context', 'SECRET_KEY', i_key);
    END tapi_audit_specify_secret_key;

    PROCEDURE tapi_audit_activate_trigger(
        i_table_name IN VARCHAR2,
        i_enable IN BOOLEAN DEFAULT TRUE
    ) IS
        l_secret_key VARCHAR2(50);
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        SELECT SYS_CONTEXT('blog_context', 'SECRET_KEY') INTO l_secret_key FROM DUAL;
        IF l_secret_key = SECRET_KEY THEN
            IF i_enable THEN
                EXECUTE IMMEDIATE 'ALTER TRIGGER trg_' || i_table_name || '_before_insert_update_delete ENABLE';
            ELSE
                EXECUTE IMMEDIATE 'ALTER TRIGGER trg_' || i_table_name || '_before_insert_update_delete DISABLE';
            END IF;
        ELSE
            RAISE_APPLICATION_ERROR(-20204, 'No access');
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

CREATE CONTEXT blog_context USING C##FIRST_USER.tapi_audit;
