# test start
create table member
(
    id      char(8) primary key,
    name    nvarchar(5) not null,
    address nvarchar(20)
)
;

create table product
(
    name      char(10) primary key,
    cost      int unsigned not null,
    make_date date,
    company   nvarchar(10) not null,
    amount    int unsigned
)
;

insert into member
values ('adore1', '하니', '베트남')
     , ('adore2', '혜린', '한국')
     , ('adore3', '민지', '한국')
     , ('adore4', '다니엘', '호주')
     , ('adore5', '혜인', '한국')
     , ('source1', '김채원', '한국')
     , ('source2', '카즈하', '일본')
     , ('source3', '사쿠라', '일본')
     , ('source4', '허윤진', '미국')
     , ('source5', '홍은채', '한국')
;

insert into product
values ('newjeans', 1000, '2022-08-18', 'adore', 5),
       ('lesserafim', 500, '2022-05-08', 'source', 5)
;


select *
from member;

select *
from product;
# test end


# 대량 데이터 index test start
create table employees
(
    first_name varchar(14),
    last_name  varchar(16),
    hire_date  date
);

insert into employees
select first_name, last_name, hire_date
from employees.employees
limit 500;

select *
from employees;

# index 생성 전
# -> Filter: (employees.first_name = 'Mary')  (cost=50.8 rows=50) (actual time=0.0406..0.349 rows=1 loops=1)
#     -> Table scan on employees  (cost=50.8 rows=500) (actual time=0.0284..0.312 rows=500 loops=1)
explain analyze
select *
from employees
where first_name = 'Mary';


# index 생성 후
# -> Index lookup on employees using idx_first_name (first_name='Mary')  (cost=0.35 rows=1) (actual time=0.0203..0.0236 rows=1 loops=1)
create index idx_first_name on employees (first_name);
explain analyze
select *
from employees
where employees.first_name = 'Mary';
# 대량 데이터 index test end


# view test start
create view v_member as
select name, address
from member;
select *
from v_member;
# view test end

# stored procedure start
delimiter //
create procedure myProc()
begin
    select * from member where address = '일본';
    select * from product where company = 'source';
end //
delimiter ;
call myProc();
# stored procedure end

# trigger start
create table deleted_member
(
    id           char(8) primary key,
    name         nvarchar(5) not null,
    address      nvarchar(20),
    deleted_date date
)
;

create trigger trg_deleted_member
    after delete
    on member
    for each row
begin
    insert into deleted_member VALUES (OLD.id, old.name, old.address, curdate());
end;

delete
from member
where name = '김채원';

select *
from member
where name = '김채원';

select *
from deleted_member
where name = '김채원';
# trigger end