CREATE USER C##blog_base IDENTIFIED BY "blog_base";
CREATE USER C##blog_app IDENTIFIED BY "blog_app";
CREATE USER C##blog_admin IDENTIFIED BY "blog_admin";

ALTER USER C##blog_base QUOTA UNLIMITED ON USERS;
GRANT CREATE SESSION TO C##blog_base;
GRANT CREATE TABLE TO C##blog_base;
GRANT CREATE VIEW TO C##blog_base;
GRANT CREATE PROCEDURE TO C##blog_base;
GRANT CREATE TRIGGER TO C##blog_base;
GRANT CREATE SEQUENCE TO C##blog_base;

GRANT SELECT, INSERT, UPDATE, DELETE ON article TO C##blog_app;
GRANT SELECT ON article_comment_v TO C##blog_app;
GRANT EXECUTE ON tapi_comment TO C##blog_app;

GRANT CREATE SESSION TO C##blog_admin;
GRANT EXECUTE ON tapi_audit TO C##blog_admin;
