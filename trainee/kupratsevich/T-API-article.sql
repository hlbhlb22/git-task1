CREATE OR REPLACE TRIGGER trg_article_before_insert_update
BEFORE INSERT OR UPDATE ON article
FOR EACH ROW
BEGIN
    IF TRIM(:NEW.author) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20101, 'Person is not specified');
    END IF;

    IF TRIM(:NEW.title) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20104, 'Title must be specified');
    ELSIF :NEW.title = UPPER(:NEW.title) THEN
        RAISE_APPLICATION_ERROR(-20103, 'Title can''t be in UPPER CASE');
    END IF;

    IF TRIM(:NEW.content) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20102, 'Content can’t be empty');
    END IF;
END;