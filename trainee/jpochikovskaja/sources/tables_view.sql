create table article (
    id int generated always as identity not null,
    crt_dt date default sysdate not null, 
    mod_dt date default sysdate not null, 
    author varchar2(128) not null, 
    title varchar2(50) not null, 
    content clob not null,    
    constraint  article_pk primary key(id));
   
create table article_comment  (
    id int generated always as identity not null,
    article_id int not null, 
    ts timestamp(0) default sysdate not null, 
    reply_to_id int, 
    rating int, 
    votes int, 
    commenter varchar2(128) not null,
    content clob not null,      
    constraint  article_comment_pk primary key(id),
    constraint  article_comment_article_id_fk foreign key (article_id) references article on delete cascade,
    constraint  article_comment_reply_to_id_fk foreign key (reply_to_id) references article_comment);

create table audit_action(
    id int generated always as identity not null,
    ts timestamp(0) default sysdate not null,  
    table_name varchar2(128) not null, 
    user_name varchar2(128) not null, 
    action_type char(1) not null, 
    action_summary varchar2(250) not null, 
    constraint audit_action_pk primary key(id),
    constraint check_action_type check (action_type in ('I', 'U', 'D')));
    
create view article_comment_v 
as select 
            a.id, 
            a.article_id, 
            b.author, 
            b.title, 
            a.ts, 
            a.rating, 
            a.commenter, 
            a.content, 
            SUBSTR(c.content,1,50) AS in_reply_to
from article_comment a 
join article b on a.article_id = b.id 
left join article_comment c on a.reply_to_id =c.id;
