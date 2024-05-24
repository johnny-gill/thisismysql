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
create temporary table if not exists temp (id int);
desc temp;
