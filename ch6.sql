################ db 생성
drop database if exists sqldb;
create database sqldb;
use sqldb;

################ table 생성
drop table if exists user;
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


drop table if exists buy;
create table buy
(
    id           int auto_increment not null primary key,
    user_id      char(8)            not null,
    product_name char(6)            not null, -- 물품명
    group_name   char(4),                     -- 분류
    price        int                not null, -- 단가
    amount       smallint           not null, -- 수량
    foreign key (user_id) references user (user_id)
);


################ 데이터 추가 : index가 있는 userId로 정렬됨
insert into user
VALUES ('KKH', '김경호', 1971, '전남', '019', '3333333', 177, '2007-7-7'),
       ('KBS', '김범수', 1979, '경남', '011', '2222222', 173, '2012-4-4'),
       ('LSG', '이승기', 1987, '서울', '011', '1111111', 182, '2008-8-8'),
       ('JYP', '조용필', 1950, '경기', '011', '4444444', 166, '2009-4-4'),
       ('SSK', '성시경', 1979, '서울', NULL, NULL, 186, '2013-12-12'),
       ('LJB', '임재범', 1963, '서울', '016', '6666666', 182, '2009-9-9'),
       ('YJS', '윤종신', 1969, '경남', NULL, NULL, 170, '2005-5-5'),
       ('EJW', '은지원', 1972, '경북', '011', '8888888', 174, '2014-3-3'),
       ('JKW', '조관우', 1965, '경기', '018', '9999999', 172, '2010-10-10'),
       ('BBK', '바비킴', 1973, '서울', '010', '0000000', 176, '2013-5-5');

insert into buy
    value (NULL, 'KBS', '운동화', NULL, 30, 2),
    (NULL, 'KBS', '노트북', '전자', 1000, 1),
    (NULL, 'JYP', '모니터', '전자', 200, 1),
    (NULL, 'BBK', '모니터', '전자', 200, 5),
    (NULL, 'KBS', '청바지', '의류', 50, 3),
    (NULL, 'BBK', '메모리', '전자', 80, 10),
    (NULL, 'SSK', '책', '서적', 15, 5),
    (NULL, 'EJW', '책', '서적', 15, 2),
    (NULL, 'EJW', '청바지', '의류', 50, 1),
    (NULL, 'BBK', '운동화', NULL, 30, 2),
    (NULL, 'EJW', '책', '서적', 15, 1),
    (NULL, 'BBK', '운동화', NULL, 30, 2);

delete
from user;
delete
from buy;


################ any : 서브쿼리의 결과들을 하나라도 만족하면 true
select *
from user
where height <= any (select height from user where address = '경남');

################ in과 똑같음
select *
from user
where height = any (select height from user where address = '경남');

################ all : 서브쿼리의 모든 결과들을 만족하면 true
select *
from user
where height <= all (select height from user where address = '경남');


################ table 복사 : 제약조건은 세팅 안됨
drop table if exists buy2;
create table buy2 (select *
                   from buy);


select *
from buy
order by user_id;

select *
from user
order by user_id
;

# 가장 키가 큰 사람과 가장 키가 작은 사람의 이름과 키
select name, height
from user
where height = (select max(height) from user)
   or height = (select min(height) from user)
;

# 휴대폰이 있는 회원수
select count(mobile1)
from user
;

# 사용자별 총 구매액 중 1000이상만. 금액 적은 순으로 정렬
select user_id, sum(price * amount) as total
from buy
group by user_id
having sum(price * amount) > 1000
order by total
;

# rollup : 중간 합계
# group by 에 순서가 있었군요~
select id, group_name, sum(price * amount)
from buy
group by group_name, id
with rollup
;

# pk 중복 오류시 건너뛰기
create table user2 (select user_id, name, address
                    from user
                    limit 3)
;
alter table user2
    add constraint pk_user2 primary key (user_id);
select *
from user2;

insert ignore into user2
values ('BBK', '비비코', '미국'),
       ('SJH', '서장훈', '서울'),
       ('HJY', '현주엽', '경기')
;
select *
from user2;

# pk 중복 오류시 update
insert into user2
values ('BBK', '비비코', '미국')
on duplicate key update name='비비코',
                        address='미국';
select *
from user2;


# cte
with abc(user_id, total)
         as (select user_id, sum(price * amount)
             from buy
             group by user_id)
select *
from abc
order by total desc
;

# 지역별 가장 키 큰 사람들의 평균
with cte(address, max_height)
         as (select address, max(height)
             from user
             group by address)
select avg(max_height)
from cte
;

#