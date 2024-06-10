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


# user, buy 초기화
use sqldb;
select *
from user;
select *
from buy;


show index from user;
show index from buy;
show table status;
SHOW VARIABLES like 'innodb_page_size';
-- data_length는 cluster index의 크기 (Byte)
-- index_length는 secondary index의 크기 (Byte)
-- 16384(1024*16)=16KB=1페이지


# 단순 secondary index (중복 허용)
create index idx_user_address on user (address);
show index from user; -- non_unique=1
show table status like 'user'; -- index_length=0, 먼저 analyze 해줘야 index_length값이 변경됨
analyze table user;
show table status like 'user';
-- index_length=16384


# 고유(unique) secondary index (중복 불가)
create unique index idx_user_birth_year on user (birth_year); -- 1979년 중복이라 birth_year에는 인덱스 생성 불가
create unique index idx_user_name on user (name);
show index from user;
analyze table user;
show table status like 'user';
-- index_length=32768
insert into user
values ('GBS', '김범수', 1979, '경남', '011', '2222222', 173, '2012-4-4');
-- unique 설정되어 name 중복 불가


# index에 두개 열
show index from user;
drop index idx_user_name on user;
create index idx_user_name_birth_year on user (name, birth_year);
show index from user;
explain
select *
from user
where name = '윤종신'
  and birth_year = 1969;


# 데이터 종류가 얼마없으면 인덱스 없는게 낫다.
create index idx_user_mobile1 on user (mobile1);
explain
select *
from user
where mobile1 = '010';


# index 삭제 (보조인덱스부터 삭제한다.)
show index from user;
drop index idx_user_address on user;
alter table user
    drop index idx_user_name_birth_year; -- alter로도 가능
drop index idx_user_mobile1 on user;
alter table user
    drop PRIMARY KEY; -- cluster index는 alter로만 삭제 가능. fk걸려있어 fk먼저 삭제
select *
from information_schema.REFERENTIAL_CONSTRAINTS
where CONSTRAINT_SCHEMA = 'sqldb'; -- 외래키 확인
alter table buy
    drop constraint buy_ibfk_1;
alter table buy
    drop foreign key buy_ibfk_1; -- 위랑 동일
alter table user
    drop primary key;
show index from user;

