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

