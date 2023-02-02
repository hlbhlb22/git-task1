create or replace trigger chaeck_author
before insert or update on article
for each row
begin
    if :new.author is null
        then raise EXCEPTION_PACKAGE.PERSON_NOT_SPECIFIED;
    end if;
exception
    when EXCEPTION_PACKAGE.PERSON_NOT_SPECIFIED then        
        RAISE_APPLICATION_ERROR(EXCEPTION_PACKAGE.ID_PERSON_NOT_SPECIFIED,'Person is not specified');
end;
/

create or replace trigger chaeck_content
before insert or update on article
for each row
begin
    if :new.content is null
        then raise EXCEPTION_PACKAGE.CONTENT_EMPTY;
    end if;
  
exception
    when EXCEPTION_PACKAGE.CONTENT_EMPTY then        
        RAISE_APPLICATION_ERROR(EXCEPTION_PACKAGE.ID_CONTENT_EMPTY,'Content cant be empty');
end;
/

create or replace trigger check_title
before insert or update on article
for each row
begin
    if :new.title is null
        then raise EXCEPTION_PACKAGE.TITLE_SPECIFIED;
    end if;
    
    if upper(:new.title) = :new.title
        then RAISE EXCEPTION_PACKAGE.TITLE_UPPER_CASE;
    end if;
   
exception
    when EXCEPTION_PACKAGE.TITLE_SPECIFIED then        
        RAISE_APPLICATION_ERROR(EXCEPTION_PACKAGE.ID_TITLE_SPECIFIED,'Title must be specified');
    when EXCEPTION_PACKAGE.TITLE_UPPER_CASE then        
        RAISE_APPLICATION_ERROR(EXCEPTION_PACKAGE.ID_TITLE_UPPER_CASE,'Title cant be in UPPER CASE');
end;
/
