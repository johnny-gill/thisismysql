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
-- data_length는 데이터 페이지 또는 cluster index의 크기 (Byte)
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


# 인덱스 성능 테스트
create database if not exists indexdb;
use indexdb;

create table emp_org
select *
from employees.employees
order by rand();
create table emp_cluster
select *
from employees.employees
order by rand();
create table emp_secondary
select *
from employees.employees
order by rand();

select *
from emp_org;
select *
from emp_cluster;
select *
from emp_secondary;

show table status;
-- data_length가 17317888B/16384B(1페이지) = 1057페이지.
-- 데이터만 복사되었기때문에 cluster index에 대한 용량은 없음


alter table emp_cluster
    add primary key (emp_no);
alter table emp_secondary
    add index idx_emp_no (emp_no);

select *
from emp_cluster;
select *
from emp_secondary;

analyze table emp_org, emp_cluster, emp_secondary;
show table status; -- emp_secondary는 secondary index page가 생성되었다. (5783552B/16384B = 353페이지)
show index from emp_org;
show index from emp_cluster;
show index from emp_secondary;


-- net stop MySQL80
-- net start MySQL80
show global status like 'Innodb_pages_read'; -- 2159
select *
from emp_org
where emp_no = 100000;
show global status like 'Innodb_pages_read';
-- 2210
-- index 없는경우 : 2210-2159 = 51 페이지 읽음


-- net stop MySQL80
-- net start MySQL80
show global status like 'Innodb_pages_read'; -- 1044
select *
from emp_cluster
where emp_no = 100000;
show global status like 'Innodb_pages_read';
-- 1047
-- cluster index의 경우 : 1047-1044 = 3 페이지 읽음


-- net stop MySQL80
-- net start MySQL80
show global status like 'Innodb_pages_read'; -- 1047
select *
from emp_secondary
where emp_no = 100000;
show global status like 'Innodb_pages_read';
-- 1052
-- secondary index의 경우 : 1052-1047 = 5 페이지 읽음


# 인덱스 범위 조회 성능 비교
show global status like 'Innodb_pages_read'; -- 1048
select *
from emp_org
where emp_no <= 11000;
show global status like 'Innodb_pages_read'; -- 1594

show global status like 'Innodb_pages_read'; -- 1049
select *
from emp_cluster
where emp_no <= 11000;
show global status like 'Innodb_pages_read'; -- 1054

show global status like 'Innodb_pages_read'; -- 1044
select * -- index range scan
from emp_secondary
where emp_no <= 11000;
show global status like 'Innodb_pages_read'; -- 1431


show global status like 'Innodb_pages_read'; -- 1048
select *
from emp_cluster
where emp_no < 500000
limit 1000000;
show global status like 'Innodb_pages_read';
-- 1936
-- 읽은 page 1936-1048=888
show table status; -- cluster index(data_length)의 page가 1057페이지니까 거의 모든 페이지를 읽은거나 다름없음. 여기선 index range scan을 함


show global status like 'Innodb_pages_read'; -- 1047
select *
from emp_cluster ignore index (PRIMARY)
where emp_no < 500000
limit 1000000;
show global status like 'Innodb_pages_read';
-- 1935
-- hint릎 통해 index를 제거했는데도 전체 페이지 읽는거랑 비슷. 여기선 full table scan을함


show global status like 'Innodb_pages_read'; -- 1047
select *
from emp_secondary
where emp_no < 11000;
show global status like 'Innodb_pages_read';
-- 1434
-- 387. cluster index보단 페이지를 많이 읽지만 인덱스가 있어 full table scan을 하지 않음

show global status like 'Innodb_pages_read'; -- 1047
select *
from emp_secondary ignore index (idx_emp_no)
where emp_no < 11000;
show global status like 'Innodb_pages_read';
-- 1593
-- full table scan


show global status like 'Innodb_pages_read'; -- 1045
select *
from emp_secondary
where emp_no < 400000
limit 500000;
show global status like 'Innodb_pages_read';
-- 2115
-- secondary index는 cluster index와 다르게 전체 테이블을 검색할 것 같을때에는 index range scan이 아니라 full table scan을 사용함!!!!!!

select *
from emp_secondary
where emp_no < 50000
limit 5000000;
-- 50000정도에서 index range scan을 한다.
-- 30만개 중 5만개.. secondary index에서 전체 데이터 중 약 15% 이상 스캔시 mysql은 full table scan을 한다~~~


# 잘못된 쿼리문의 성능

show global status like 'Innodb_pages_read'; -- 1105
explain
select *
from emp_cluster
where emp_no * 1 = 100000;
show global status like 'Innodb_pages_read';
-- 1993
-- 헉..!

# 데이터의 종류 개수에 따른.. 인덱스 성능
select *
from emp_org
where gender = 'M'
limit 500000;
-- 총 row는 30만개인데 gender 종류는 2개가 전부임
-- 데이터 종류가 적다?? -> cardinality가 낮다! -> 중복도가 높다!


alter table emp_org add index idx_gender (gender);
analyze table emp_org;
show table status ;
show index from emp_org;


select *
from emp_org
where gender = 'M'
limit 500000;

