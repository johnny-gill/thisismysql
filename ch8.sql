drop database if exists tabledb;
create database tabledb;
use tabledb;

drop table if exists buy, user;

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
# alter table user add constraint primary key (user_id);
desc user;
show keys from user;

create table buy
(
    buy_id       int auto_increment not null primary key,
    user_id      char(8)            not null,
    product_name char(6)            not null, -- 물품명
    group_name   char(4),                     -- 분류
    price        int                not null, -- 단가
    amount       smallint           not null, -- 수량
    constraint fk_buy_user foreign key (user_id) references user (user_id)
);
# alter table buy add constraint fk_buy_user foreign key (user_id) references user (user_id);
desc buy;
show keys from buy;

# 멀티 pk
drop table if exists product;
create table product
(
    product_code char(3)  not null,
    product_id   char(4)  not null,
    created_date date     not null,
    state        char(10) null,
    primary key (product_code, product_id)
);

desc product;
show keys from product;


# on update cascade, on delete cascade
alter table buy
    drop foreign key fk_buy_user;
alter table buy
    add constraint fk_buy_user foreign key (user_id) references user (user_id)
        on update cascade;


# unique
drop table if exists buy, user;
create table user
(
    user_id    char(8)     not null primary key,
    name       varchar(10) not null,
    birth_year int         not null,
    email      char(30)    null,
    constraint ak_email unique (email)
);

show keys from user;

# check
drop table if exists user;
create table user
(
    user_id    char(8) primary key,
    name       varchar(10),
    birth_year int check (birth_year >= 1900 and birth_year <= 2023) default 2000,
    mobile1    char(3),
    constraint ck_name check ( name is not null )
);
alter table user
    add constraint ck_mobile1 check (mobile1 = '010');

insert into user
values ('AAA', '랄랄라', default, '010');
select *
from user;

-- 압축
drop table if exists normal, compress;
create table normal
(
    emp_no     int,
    first_name varchar(14)
);
create table compress
(
    emp_no     int,
    first_name varchar(14)
) row_format = compressed;

insert into normal -- 1.899s
select emp_no, first_name
from employees.employees;

insert into compress -- 3.304s
select emp_no, first_name
from employees.employees;

select *
from compress;
show table status;


# 임시테이블
create temporary table if not exists temp
(
    id int
);
desc temp
;


# alter
use tabledb;

drop table if exists user;
create table user
(
#     user_id    char(8)     not null primary key,
    name       varchar(10) not null,
    birth_year int         not null,
    address    char(2)     not null,
    mobile1    char(3),
    mobile2    char(8),
    height     smallint,
    join_date  date
);
alter table user
    add user_id char(8) not null first;
alter table user
    add constraint primary key (user_id);


drop table if exists buy;
create table buy
(
#     buy_id       int auto_increment not null primary key,
    user_id      char(8)  not null,
    product_name char(6)  not null,
    group_name   char(4),
#     price        int                not null,
    amount       smallint not null
);


alter table buy
    add buy_id int auto_increment not null primary key first;
alter table buy
    add price int not null after group_name;
alter table buy
    add constraint fk_user_buy foreign key (user_id) references user (user_id);

alter table buy
    add temp int;
alter table buy
    change temp t_temp varchar(10) not null;
alter table buy
    modify t_temp date;
alter table buy
    drop t_temp;


## fk를 먼저 삭제해야 drop 가능
alter table user
    drop primary key;
alter table buy
    drop foreign key fk_user_buy;


# 실습
use tabledb;
drop table if exists buy, user;

create table user
(
    user_id    char(8),
    name       varchar(10),
    birth_year int,
    addr       char(2),
    mobile1    char(3),
    mobile2    char(8),
    height     smallint,
    reg_date   date
);

create table buy
(
    buy_id       int auto_increment primary key,
    user_id      char(8),
    product_name char(6),
    group_name   char(4),
    price        int,
    amount       smallint
);


INSERT INTO user
VALUES ('LSG', '이승기', 1987, '서울', '011', '1111111', 182, '2008-8-8')
     , ('KBS', '김범수', null, '경남', '011', '2222222', 173, '2012-4-4')
     , ('KKH', '김경호', 1871, '전남', '019', '3333333', 177, '2007-7-7')
     , ('JYP', '조용필', 1950, '경기', '011', '4444444', 166, '2009-4-4');

INSERT INTO buy
VALUES (null, 'KBS', '운동화', NULL, 30, 2)
     , (null, 'KBS', '노트북', '전자', 1000, 1)
     , (null, 'JYP', '모니터', '전자', 200, 1)
     , (null, 'BBK', '모니터', '전자', 200, 5);

select *
from user;
select *
from buy;

alter table user
    add constraint primary key (user_id);

delete
from buy
where user_id = 'BBK';
alter table buy
    add constraint fk_user_buy foreign key (user_id) references user (user_id);

-- fk 체크 해제
set foreign_key_checks = 0;
INSERT INTO buy
VALUES (NULL, 'BBK', '모니터', '전자', 200, 5)
     , (NULL, 'KBS', '청바지', '의류', 50, 3)
     , (NULL, 'BBK', '메모리', '전자', 80, 10)
     , (NULL, 'SSK', '책', '서적', 15, 5)
     , (NULL, 'EJW', '책', '서적', 15, 2)
     , (NULL, 'EJW', '청바지', '의류', 50, 1)
     , (NULL, 'BBK', '운동화', NULL, 30, 2)
     , (NULL, 'EJW', '책', '서적', 15, 1)
     , (NULL, 'BBK', '운동화', NULL, 30, 2);
set foreign_key_checks = 1;


-- 1900~2023년만 not null
select *
from user
order by birth_year;

update user
set birth_year=1979
where user_id = 'KBS';
update user
set birth_year=1971
where user_id = 'KKH';

alter table user
    add constraint ck_birth_year check ( (birth_year between 1900 and 2023) and birth_year is not null);

INSERT INTO user
VALUES ('TKV', '태권뷔', 2023, '서울', '011', '1111111', 182, '2008-8-8');

INSERT INTO user
VALUES ('SSK', '성시경', 1979, '서울', NULL, NULL, 186, '2013-12-12')
     , ('LJB', '임재범', 1963, '서울', '016', '6666666', 182, '2009-9-9')
     , ('YJS', '윤종신', 1969, '경남', NULL, NULL, 170, '2005-5-5')
     , ('EJW', '은지원', 1972, '경북', '011', '8888888', 174, '2014-3-3')
     , ('JKW', '조관우', 1965, '경기', '018', '9999999', 172, '2010-10-10')
     , ('BBK', '바비킴', 1973, '서울', '010', '0000000', 176, '2013-5-5');


-- BBK -> VVK
select *
from user
order by user_id;
select *
from buy
order by user_id;

alter table buy
    drop constraint fk_user_buy;

alter table buy
    add constraint fk_user_buy foreign key (user_id) references user (user_id) on update cascade on delete cascade;

update user
set user_id = 'VVK'
where user_id = 'BBK';

delete
from user
where user_id = 'VVK';


-- 제약조건이 있어도 삭제
alter table user
    drop birth_year;


# 뷰~
create or replace view v_user
as
select user_id, name, addr
from user;

select *
from v_user;

update v_user
set addr='부산'
where user_id = 'JKW';

insert into v_user
values ('ABC', '에이비', '씨디');

create or replace view v_sum as
select sum(price * amount)
from buy;

select *
from information_schema.views
where table_name like '%v_%';



create view v_height177
as
select *
from user
where height >= 177
;

alter view v_height177
    as
        select *
        from user
        where height >= 177
    with check option
;

insert into v_height177
values ('SJH', '서장훈', '서울', '010', '33333333', 155, '2023-05-05');


check table v_height177;


