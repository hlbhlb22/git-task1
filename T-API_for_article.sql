CREATE OR REPLACE TRIGGER article_trg_increment_track_count_b_ins_upd_r
before insert or update on article
FOR EACH ROW
    BEGIN
    -- Check for author not being empty
    IF :NEW.col_author IS NULL OR :NEW.col_author = '' THEN
        RAISE_APPLICATION_ERROR(-20101, 'Person is not specified');
    END IF;

    -- Check for title not being empty and not in uppercase
    IF :NEW.col_title IS NULL OR :NEW.col_title = '' THEN
        RAISE_APPLICATION_ERROR(-20104, 'Title must be specified');
    ELSIF :NEW.col_title != UPPER(:NEW.col_title) THEN
        RAISE_APPLICATION_ERROR(-20103, 'Title can''t be in UPPER CASE');
    END IF;

    -- Check for content not being empty
    IF :NEW.col_content IS NULL OR :NEW.col_content = '' THEN
        RAISE_APPLICATION_ERROR(-20102, 'Content can’t be empty');
    END IF;
END;
