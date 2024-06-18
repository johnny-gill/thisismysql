use sqldb;


drop procedure if exists userProc;
delimiter $$
create procedure userProc()
begin
    select * from user;
end $$
delimiter ;
call userProc();

# sqlDB 초기화


# 매개 변수가 있는 프로시져
drop procedure if exists userProc1;
delimiter $$
create procedure userProc1(in user_name varchar(10))
begin
    select * from user where name = user_name;
end $$
delimiter ;
call userProc1('조관우');


# 2개의 매개 변수가 있는 프로시저
drop procedure if exists userProc2;
delimiter $$
create procedure userProc2(in user_birth int, in user_height int)
begin
    select *
    from user
    where birth_year > user_birth
      and height > user_height;
end $$
delimiter ;
call userProc2(1970, 178);


# 출력 매개 변수가 있는 프로시저
drop procedure if exists userProc3;
delimiter $$
create procedure userProc3(in txt_value char(10), out out_value int)
begin
    insert into test values (null, txt_value);
    select max(id) into out_value from test;
end $$
delimiter ;

create table if not exists test
(
    id  int auto_increment primary key,
    txt char(10)
);

call userProc3('테스트~', @myValue);
select @myValue;
select *
from test;


# if/else가 들어간 프로시져~
drop procedure if exists ifElseProc;
delimiter $$
create procedure ifElseProc(in user_name varchar(10))
begin
    declare b_year int;
    select birth_year into b_year from user where name = user_name;
    if (b_year > 1980) then
        select '젊은이';
    else
        select '늙은이';
    end if;
end $$
delimiter ;

call ifElseProc('조용필');
call ifElseProc('이승기');


# case가 들어간 프로시져~~시져~
drop procedure if exists caseProc;
delimiter $$
create procedure caseProc(in v_name varchar(10))
begin
    declare v_birth_year int;
    declare tti char(3);
    select birth_year into v_birth_year from user where name = v_name;
    case
        when (v_birth_year % 12 = 0) then set tti = '12';
        when (v_birth_year % 12 = 1) then set tti = '11';
        when (v_birth_year % 12 = 2) then set tti = '10';
        when (v_birth_year % 12 = 3) then set tti = '9';
        when (v_birth_year % 12 = 4) then set tti = '8';
        when (v_birth_year % 12 = 5) then set tti = '7';
        when (v_birth_year % 12 = 6) then set tti = '6';
        when (v_birth_year % 12 = 7) then set tti = '5';
        when (v_birth_year % 12 = 8) then set tti = '4';
        when (v_birth_year % 12 = 9) then set tti = '3';
        when (v_birth_year % 12 = 10) then set tti = '2';
        else set tti = '1';
        end case;
    select concat(v_name, '은 무슨띠??   ', tti);
end $$
delimiter ;
call caseProc('조용필');


# while 프로시져시져
drop table if exists gugudan;
create table gugudan
(
    txt varchar(100)
);

drop procedure if exists gugudanProc;
delimiter $$
create procedure gugudanProc()
begin
    declare str varchar(100);
    declare i int; -- 앞자리
    declare k int; -- 뒷자리

    set i = 2; -- 2단부터
    while (i < 10)
        do
            set str = '';
            set k = 1;

            while (k < 10)
                do
                    set str = concat(str, ' ', i, 'x', k, '=', i * k);
                    set k = k + 1;
                end while;
            set i = i + 1;
            insert into gugudan values (str);
        end while;
end $$
delimiter ;

call gugudanProc();
select *
from gugudan;


# 오류 처리 프로시져~
drop procedure if exists errorProc;
delimiter $$
create procedure errorProc()
begin
    declare i int;
    declare sum int;
    declare sum_before_ovferflow int;

    declare exit handler for 1264
        begin
            select i, sum_before_ovferflow;
        end;

    set i = 1;
    set sum = 0;

    while (true)
        do
            set sum_before_ovferflow = sum;
            set sum = sum + i;
            set i = i + 1;
        end while;
end $$
delimiter ;

call errorProc();


# 프로시져 정보
select *
from information_schema.ROUTINES
where ROUTINE_SCHEMA = 'sqldb';

select *
from information_schema.PARAMETERS
where SPECIFIC_SCHEMA = 'sqldb';

# 이게 나을듯?
show create procedure sqldb.userProc3;


# 동적 sql 프로시져
drop procedure if exists whatProc;
delimiter $$
create procedure whatProc(in table_name varchar(20))
begin
    set @query = concat('select * from ', table_name);
    prepare myQuery from @query;
    execute myQuery;
    deallocate prepare myQuery;
end $$
delimiter ;

call whatProc('user');

# 프로시쟈 삭제 .. alter는 불가능...
drop procedure whatProc;


# stored function
set global log_bin_trust_function_creators = 1; -- 팡션 생성 권한 허용

use sqldb;
drop function if exists userFunc;
delimiter $$
create function userFunc(val1 int, val2 int)
    returns int
begin
    return val1 + val2;
end $$
delimiter ;
select userFunc(10, 20);


# 나이 구하는 펑션~
drop function if exists getAgeFunc;
delimiter $$
create function getAgeFunc(v_year int)
    returns int
begin
    declare age int;
    set age = year(curdate()) - v_year;
    return age;
end $$
delimiter ;

select getAgeFunc(1990)
into @age1990;
select getAgeFunc(1996)
into @age1996;
select concat('나이차 : ', @age1990 - @age1996, '살');
select user_id, name, birth_year, getAgeFunc(birth_year) as 'age'
from user;


# function 정보 확인
show create function getAgeFunc;

# function 삭제
drop function getAgeFunc;


# cursor 커서입니다
drop procedure if exists cursorProc;
delimiter $$
create procedure cursorProc()
begin
    declare userHeight int;
    declare cnt int default 0; -- 읽은 행의 수
    declare totalHeight int default 0;
    declare endOfRow boolean default false;

    declare userCursor cursor for -- 커서 선언
        select height from user;

    declare continue handler for -- 행의 끝이면 true로
        not found set endOfRow = true;

    open userCursor; -- 커서 open

    cursor_loop:
    loop
        fetch userCursor into userHeight;

        if endOfRow then
            leave cursor_loop;
        end if;

        set cnt = cnt + 1;
        set totalHeight = totalHeight + userHeight;
    end loop cursor_loop;

    select concat('고객 키의 평균  ===>', (totalHeight / cnt));

    close userCursor; -- 커서 close
end $$
delimiter ;

call cursorProc();
select avg(height)
from user;


# 구매액에 따른 고객 등급 지정 커서~~~~~
alter table user
    add grade varchar(5);

drop procedure if exists gradeProc;
delimiter $$
create procedure gradeProc()
begin
    declare id char(8);
    declare sum bigint;
    declare userGrade varchar(5);
    declare endOfRow boolean default false;

    declare userCursor cursor for
        select u.user_id, sum(price * amount)
        from user u
                 left join buy b
                           on u.user_id = b.user_id
        group by u.user_id;

    declare continue handler for
        not found set endOfRow = true;

    open userCursor;

    grade_loop:
    loop
        fetch userCursor into id, sum;

        if endOfRow then
            leave grade_loop;
        end if;

        case
            when sum >= 1500 then set userGrade = '최우수고객';
            when sum >= 1000 then set userGrade = '우수고객';
            when sum >= 500 then set userGrade = '일반고객';
            else set userGrade = '유령고객';
            end case;

        update user set grade = userGrade where user_id = id;
    end loop grade_loop;

    close userCursor;
end $$
delimiter ;

call gradeProc();
select *
from user;


# 트리거
create database if not exists testDB;
use testDB;
create table if not exists test
(
    id  int,
    txt varchar(10)
);
insert into test
values (1, '뉴진스'),
       (2, '아이브'),
       (3, '블핑');


drop trigger if exists testTrg;
delimiter //
create trigger testTrg
    after delete -- 삭제 후 작동
    on test
    for each row -- 각 행마다 적용
begin
    set @msg = '가수 그룹이 삭제됨';
end //
delimiter ;

set @msg = '';

insert into test
values (4, 'bts');
select @msg;

update test
set txt = 'BTS'
where id = 4;
select @msg;

delete
from test
where id = 4;
select @msg;


# 백업 트리거~
use sqldb;
drop table buy;
create table user_bak
(
    user_id    char(8)     not null primary key,
    name       varchar(10) not null,
    birth_year int         not null,
    addr       char(2)     not null,
    mobile1    char(3),
    mobile2    char(8),
    height     smallint,
    join_date  date,
    mod_type   char(2), -- '수정', '삭제'
    mod_date   date,
    mod_user   varchar(256)
);

drop trigger if exists userBak_updateTrg;
delimiter //
create trigger userBak_updateTrg
    after update
    on user
    for each row
begin
    insert into user_bak
    values (old.user_id, old.name, old.birth_year, old.address, old.mobile1, old.mobile2,
            old.height, old.join_date, '수정', curdate(), current_user());
end //
delimiter ;

drop trigger if exists userBak_deleteTrg;
delimiter //
create trigger userBak_deleteTrg
    after delete
    on user
    for each row
begin
    insert into user_bak
    values (old.user_id, old.name, old.birth_year, old.address, old.mobile1, old.mobile2,
            old.height, old.join_date, '삭제', curdate(), current_user());
end //
delimiter ;


select *
from user;
select *
from user_bak;
update user
set address = '일본'
where user_id = 'JKW';
delete
from user
where height >= 177;


# insert trigger
drop trigger if exists user_insertTrg;
delimiter //
create trigger user_insertTrg
    after insert
    on user
    for each row
begin
    signal sqlstate '45000'
        set message_text = '인서트 금지!!!!';
end;
delimiter ;

insert into user
values ('aaa', '오오', 1919, '인천', '010', '12345678', 199, curdate(), null);


# before trigger
-- sqldb 초기화
drop trigger if exists user_beforeInsertTrg;
delimiter //
create trigger user_beforeInsertTrg
    before insert
    on user
    for each row
begin
    if new.birth_year < 1900 then
        set new.birth_year = 0;
    elseif new.birth_year > year(curdate()) then
        set new.birth_year = year(curdate());
    end if;
end //
delimiter ;

insert into user
values ('aaa', '오오', 1888, '인천', '010', '12345678', 199, curdate());
insert into user
values ('bbb', '유유', 3000, '인천', '010', '12345678', 199, curdate());
select *
from user;

show triggers from sqldb;

drop trigger user_beforeInsertTrg;


# 중첩 트리거 nested trigger
drop database if exists triggerDB;
create database if not exists triggerDB;
use triggerDB;


create table `order`
(
    order_no     int auto_increment primary key,
    user_id      varchar(5),
    product_name varchar(5),
    qty          int
);

create table product
(
    product_name varchar(5),
    qty          int
);

create table delivery
(
    delivery_no  int auto_increment primary key,
    product_name varchar(5),
    qty          int
);

insert into product
values ('사과', 100),
       ('수박', 100),
       ('참외', 100);

select *
from product;


drop trigger if exists orderTrg;
delimiter //
create trigger orderTrg
    after insert
    on `order`
    for each row
begin
    update product
    set qty = qty - new.qty
    where product_name = new.product_name;
end //
delimiter ;

drop trigger if exists productTrg;
delimiter //
create trigger productTrg
    after update
    on product
    for each row
begin
    insert into delivery values (null, new.product_name, old.qty - new.qty);
end //
delimiter ;

show triggers from triggerDB;

insert into `order`
values (null, 'john', '수박', 5);
select *
from `order`;
select *
from product;
select *
from delivery;

alter table delivery
    change product_name product_name_chg varchar(5);
insert into `order`
values (null, 'john', '수박', 5);
