create or replace trigger chaeckAuthor
before insert or update on article
for each row
begin
    if :new.author is null
        then RAISE EXCEPTION_PACKAGE.PERSON_NOT_SPECIFIED;
    end if;
EXCEPTION
    WHEN EXCEPTION_PACKAGE.PERSON_NOT_SPECIFIED THEN        
        RAISE_APPLICATION_ERROR(EXCEPTION_PACKAGE.ID_PERSON_NOT_SPECIFIED,'Person is not specified');
end;

create or replace trigger chaeck�ontent
before insert or update on article
for each row
begin
    if :new.content is null
        then RAISE EXCEPTION_PACKAGE.CONTENT_EMPTY;
    end if;
  
EXCEPTION
    WHEN EXCEPTION_PACKAGE.CONTENT_EMPTY THEN        
        RAISE_APPLICATION_ERROR(EXCEPTION_PACKAGE.ID_CONTENT_EMPTY,'Content can�t be empty');
end;

create or replace trigger checkTitle
before insert or update on article
for each row
begin
    if :new.title is null
        then RAISE EXCEPTION_PACKAGE.TITLE_SPECIFIED;
    end if;
    
    if UPPER(:new.title) = :new.title
        then RAISE EXCEPTION_PACKAGE.TITLE_UPPER_CASE;
    end if;
   
EXCEPTION
    WHEN EXCEPTION_PACKAGE.TITLE_SPECIFIED THEN        
        RAISE_APPLICATION_ERROR(EXCEPTION_PACKAGE.ID_TITLE_SPECIFIED,'Title must be specified');
    WHEN EXCEPTION_PACKAGE.TITLE_UPPER_CASE THEN        
        RAISE_APPLICATION_ERROR(EXCEPTION_PACKAGE.ID_TITLE_UPPER_CASE,'Title can`t be in UPPER CASE');
end;
