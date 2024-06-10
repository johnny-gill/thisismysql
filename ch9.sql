create database ch9;
use ch9;

create table user
(
    user_id    char(8)     not null primary key,
    name       varchar(10) not null,
    birth_year int         not null,
    address    char(2)     not null,
    mobile1    char(3),
    mobile2    char(8),
    height     smallint,
    join_date  date
);
show index from user;

create table table2
(
    a int primary key, -- clustered
    b int unique,      -- secondary
    c int unique,      -- secondary
    d int
);
show index from table2;


create table table3
(
    a int unique, -- secondary
    b int unique, -- secondary
    c int unique, -- secondary
    d int
);
show index from table3;


create table table4
(
    a int unique not null, -- clustered
    b int unique,          -- secondary
    c int unique,          -- secondary
    d int
);
show index from table4;


create table table5
(
    a int unique not null, -- secondary
    b int unique,          -- secondary
    c int unique,          -- secondary
    d int primary key      -- clustered
);
show index from table5;

drop table if exists user;
create table user
(
    user_id    char(8)     not null primary key,
    name       varchar(10) not null,
    birth_year int         not null,
    address    char(2)     not null
);

-- user_id로 정렬됨
truncate table user;
INSERT INTO user
VALUES ('LSG', '이승기', 1987, '서울')
     , ('KBS', '김범수', 1979, '경남')
     , ('KKH', '김경호', 1971, '전남')
     , ('JYP', '조용필', 1950, '경기')
     , ('SSK', '성시경', 1979, '서울');

select *
from user;

alter table user
    drop primary key;

alter table user
    add constraint primary key (name);


create table cluster
(
    user_id char(8),
    name    varchar(10)
);


INSERT INTO cluster
VALUES ('LSG', '이승기')
     , ('KBS', '김범수')
     , ('KKH', '김경호')
     , ('JYP', '조용필')
     , ('SSK', '성시경')
     , ('LJB', '임재범')
     , ('YJS', '윤종신')
     , ('EJW', '은지원')
     , ('JKW', '조관우')
     , ('BBK', '바비킴');

-- page size
show variables like 'innodb_page_size';

select *
from cluster;

alter table cluster
    add constraint primary key (user_id);



create table secondary
(
    user_id char(8),
    name    varchar(10)
);


INSERT INTO secondary
VALUES ('LSG', '이승기')
     , ('KBS', '김범수')
     , ('KKH', '김경호')
     , ('JYP', '조용필')
     , ('SSK', '성시경')
     , ('LJB', '임재범')
     , ('YJS', '윤종신')
     , ('EJW', '은지원')
     , ('JKW', '조관우')
     , ('BBK', '바비킴');

alter table secondary
    add constraint uk_user_id unique (user_id);
select *
from secondary;

show index from secondary;



insert into cluster
values ('FNT', '푸니타');
insert into cluster
values ('KAI', '카아이');
select *
from cluster;


insert into secondary
values ('FNT', '푸니타')
     , ('KAI', '카아이');
select *
from secondary;


drop table if exists mixed;
CREATE TABLE mixed
(
    user_id CHAR(8)     NOT NULL,
    name    VARCHAR(10) NOT NULL,
    addr    char(2)
);


INSERT INTO mixed
values ('LSG', '이승기', '서울')
     , ('KBS', '김범수', '경남')
     , ('KKH', '김경호', '전남')
     , ('JYP', '조용필', '경기')
     , ('SSK', '성시경', '서울')
     , ('LJB', '임재범', '서울')
     , ('YJS', '윤종신', '경남')
     , ('EJW', '은지원', '경북')
     , ('JKW', '조관우', '경기')
     , ('BBK', '바비킴', '서울');

select *
from mixed;

alter table mixed
    add constraint primary key (user_id);
alter table mixed
    add constraint uk_name unique (name);

show index from mixed;

