create or replace PACKAGE EXCEPTION_PACKAGE IS
    PERSON_NOT_SPECIFIED exception;
    CONTENT_EMPTY exception;
    TITLE_UPPER_CASE exception;
    TITLE_SPECIFIED exception;
    DIRECT_DML_PROHIBITED exception;
    TABLE_NOTFOUNT exception;
    NO_ACCESS exception;
    
    ID_PERSON_NOT_SPECIFIED int := -20101;
    ID_CONTENT_EMPTY int := -20102;
    ID_TITLE_UPPER_CASE int := -20103;
    ID_TITLE_SPECIFIED int := -20104;
    ID_DIRECT_DML_PROHIBITED int := -20202;
    ID_TABLE_NOTFOUNT int := -20203;
    ID_NO_ACCESS int := -20204;
    
    pragma exception_init(PERSON_NOT_SPECIFIED, -20101);
    pragma exception_init(CONTENT_EMPTY, -20102);
   	pragma exception_init(TITLE_UPPER_CASE, -20103);
    pragma exception_init(TITLE_SPECIFIED, -20104);
   	pragma exception_init(DIRECT_DML_PROHIBITED, -20202);
    pragma exception_init(TABLE_NOTFOUNT, -20203); 
    pragma exception_init(NO_ACCESS, -20204); 
end;
