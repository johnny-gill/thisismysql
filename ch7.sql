use sqldb;

# limit에 변수 사용시 prepare/execute로 해야함
set @var = 3;
prepare abc
    from 'select name, height from user order by height limit ?';
execute abc using @var;

# 명시적인 형변환 (explicit conversion) : cast 또는 convert
select avg(amount), cast(avg(amount) as signed integer), convert(avg(amount), signed integer)
from buy
;

# 암시적인 형변환 (implicit conversion)
select '100' + '200'; -- 숫자
select concat(100, 200);
-- 문자

# 조건
select if(100 > 200, '참', '거짓');
select ifnull(null, '널입니다'); -- 왼쪽항이 null이면 오른쪽항 출력
select ifnull(9999, '널입니다'); -- 왼쪽항이 null이 아니면 왼쪽항 출력
select nullif(100, 100); -- 두항이 같으면 null 출력
select nullif(100, 1000); -- 두항이 같지않으면 왼쪽항 출력

select case 10
           when 1 then '하나'
           when 2 then '둘'
           when 3 then '삼'
           when 10 then '열'
           else '몰라'
           end as '케이스'
;

# 길이
select bit_length('가나다'); -- 3글자 * 3byte * 8bit = 72bit
select bit_length('abc'); -- 3글자 x 1byte x 8bit = 24bit
select char_length('가나다');
select char_length('abc');

# 합치기
select concat('A', '@', 'B', '@', 'C');
select concat_ws('@', 'A', 'B', 'C');

# 찾기
select elt(2, 'a', 'b', 'c'); -- b
select field('b', 'a', 'b', 'c'); -- 2

select find_in_set('b', 'a,b,c'); -- 2

select instr('abc', 'b'); -- 2
select locate('b', 'abc');
-- 2

# 실수 포맷
select format(12345.123456789, 5);
-- 12,345.12346

# 삽입
select insert('123456789', 3, 5, '@@@@');
-- 12@@@@89, 3번째부터 5개 문자를 지우고 @@@@삽입

# 패딩
select lpad('123456789', 11, '@'); -- @@123456789, 길이를 11로 늘리고 빈곳을 @로 채우기
select rpad('123456789', 11, '@');
-- 123456789@@

# 문자열 자르기
select left('123456789', 3); -- 123
select right('123456789', 3); -- 789

select substring('123456789', 1, 3); -- 123
select substring('123456789', 4, 3); -- 456

select substring_index('123.456.789', '.', 2); -- 123.456
select substring_index('123.456.789', '.', -2);
-- 456.789

# 공백 제거 - 중간 공백은 처리 불가
select ltrim('      12345 6789      '); -- '12345 6789      '
select rtrim('      12345 6789      '); -- '      12345 6789'
select trim('      12345 6789      '); -- '12345 6789'
select trim(both ' ' from '      12345 6789      '); -- '12345 6789'
select trim(leading ' ' from '      12345 6789      '); -- '12345 6789      ', ltrim과 동일
select trim(trailing ' ' from '      12345 6789      ');
-- '      12345 6789', rtrim과 동일

# 공백 추가
select space(10);
-- '          '

# 반복
select repeat('123456789', 2);
-- 123456789123456789

# 변경
select replace('123456789', '123', '#####');
-- #####456789

# 거꾸로
select reverse('123456789');


# 날짜 계산
select adddate('2024-05-01', interval 31 day); -- 2024-06-01
select adddate('2024-05-01', interval 1 month); -- 2024-06-01
select subdate('2024-07-01', interval 30 day); -- 2024-06-01
select subdate('2024-07-01', interval 1 month);
-- 2024-06-01


# 시간 계산
select addtime('2024-05-31 23:59:59', '0:0:1'); -- 2024-06-01 00:00:00
select addtime('23:59:59', '0:0:1'); -- 24:00:00
select subtime('2024-06-02 00:00:00', '0:0:1'); -- 2024-06-01 23:59:59
select subtime('24:00:00', '0:0:1');
-- 23:59:59


# 현재날짜/시간
select curdate();
select curtime();
select now(); -- sysdate와 동일
select sysdate();

# 날짜/시간 추출
select date('2024-06-01 00:00:00'); -- 2024-06-01
select time('2024-06-01 00:00:00');
-- 00:00:00

# 날짜/시간 차이
select datediff('2024-06-02', '2024-06-01'); -- 1
select timediff('2024-06-02 00:00:00', '2024-06-01 12:00:00');
-- 12:00:00

# 뭐가 많군.....

# 정보
select user(), database(), version(), sleep(4);


# blob, clob
create table movie
(
    id       int,
    title    varchar(30),
    director varchar(20),
    star     varchar(20),
    script   longtext,
    film     longblob
);

insert into movie
values (1, '파묘', '김또깡', '최민식', LOAD_FILE('C:/test/test.txt'), LOAD_FILE('C:/test/test.mp4'));
select *
from movie;

-- longtext, longblob이 null이면 아래 값들 확인. 값은 my.ini(리눅스는 my.enf)에서 수정
show variables like 'max_allowed_packet'; -- 최대 파일 크기
show variables like 'secure_file_priv'; -- 파일 업/다운 폴더 위치

truncate movie;
insert into movie
values (1, '파묘', '김또깡', '최민식', LOAD_FILE('C:/test/test.txt'), LOAD_FILE('C:/test/test.mp4'));
select *
from movie;

select script
from movie
where id = 1
into outfile 'C:/test/test_bak.txt' lines terminated by '\\n'; -- longtext 다운로드

select film
from movie
where id = 1
into dumpfile 'C:/test/test_bak.mp4';
-- longblob 파일 다운로드


# 피벗
drop table if exists pivot;
create table pivot
(
    name   char(3),
    season char(2),
    amount int
);
insert into pivot
values ('김범수', '겨울', 10),
       ('윤종신', '여름', 15),
       ('김범수', '가을', 25),
       ('김범수', '봄', 3),
       ('김범수', '봄', 37),
       ('윤종신', '겨울', 40),
       ('김범수', '여름', 14),
       ('김범수', '겨울', 22),
       ('윤종신', '여름', 64)
;

select *
from pivot;

select name
     , sum(if(season = '봄', amount, 0))  as '봄'
     , sum(if(season = '여름', amount, 0)) as '여름'
     , sum(if(season = '가을', amount, 0)) as '가을'
     , sum(if(season = '겨울', amount, 0)) as '겨울'
     , sum(amount)                       as '합계'
from pivot
group by name
;

select season
     , sum(if(name = '김범수', amount, 0)) as '김범수'
     , sum(if(name = '윤종신', amount, 0)) as '윤종신'
     , sum(amount)                      as '합계'
from pivot
group by season
;


-- JSON
select JSON_OBJECT('name', name, 'height', height)
from user
where height >= 180
;

SET @json = '{"user" :
    [
        {"name": "임재범", "height": 182},
        {"name": "이승기", "height": 182},
        {"name": "성시경", "height": 186}
    ]
}';

select @json;
select json_valid(@json)                                  as valid
     , json_search(@json, 'one', '성시경')                   as search
     , json_extract(@json, '$.user[2].name')              as extract
     , json_insert(@json, '$.user[0].date', '2024-05-01') as `insert`
     , json_replace(@json, '$.user[0].name', '홍길동')       as `replace`
     , json_remove(@json, '$.user[1]')                    as remove
;


# join
drop table if exists student;
create table student
(
    name    char(4) not null primary key,
    address char(2) not null
);
insert into student
values ('김범수', '경남'),
       ('성시경', '서울'),
       ('조용필', '경기'),
       ('은지원', '경북'),
       ('바비킴', '서울')
;
select *
from student
;


drop table if exists club;
create table club
(
    name     char(4) not null primary key,
    room_num char(4) not null
);
insert into club
values ('수영', '101호')
     , ('바둑', '102호')
     , ('축구', '103호')
     , ('봉사', '104호');
select *
from club;


drop table if exists stdclub;
create table stdclub
(
    id        int auto_increment not null primary key,
    name      char(4)            not null,
    club_name char(4)            not null,
    foreign key (name) references student (name),
    foreign key (club_name) references club (name)
);

insert into stdclub
values (null, '김범수', '바둑'),
       (null, '김범수', '축구'),
       (null, '조용필', '축구'),
       (null, '은지원', '축구'),
       (null, '은지원', '봉사'),
       (null, '바비킴', '봉사');



create table emp
(
    name    char(3),
    manager char(3),
    tel     varchar(8)
);

INSERT INTO emp
VALUES ('나사장', NULL, '0000'),
       ('김재무', '나사장', '2222'),
       ('김부장', '김재무', '2222-1'),
       ('이부장', '김재무', '2222-2'),
       ('우대리', '이부장', '2222-2-1'),
       ('지사원', '이부장', '2222-2-2'),
       ('이영업', '나사장', '1111'),
       ('한과장', '이영업', '1111-1'),
       ('최정보', '나사장', '3333'),
       ('윤차장', '최정보', '3333-1'),
       ('이주임', '윤차장', '3333-1-1');

-- 우대리 상관의 연락처
select e1.name, e1.manager, e2.tel
from emp e1
         join emp e2
              on e1.manager = e2.name
where e1.name = '우대리'
;

-- stored procedure
drop procedure if exists ifProc;
delimiter $$
create procedure ifProc()
begin
    declare var int;
    set var = 100;

    if var = 100 then
        select '100입니다..';
    else
        select '100아님..';
    end if;
end $$
delimiter ;
call ifProc();


# 10001번 직원의 입사일이 5년이 넘었는가?
use employees;
drop procedure if exists ifProc2;

delimiter $$
create procedure ifProc2()
begin
    declare hireDate date;
    declare curDate date;
    declare days int; -- 근무 일수

    select hire_date
    into hireDate
    from employees.employees
    where emp_no = 10001;

    set curDate = curdate();
    set days = datediff(curdate(), hireDate);

    if (days / 365) >= 5 then
        select concat('입사한지 5년 이상입니다!!', days);
    else
        select concat('입사한지 5년 미만입니다ㅠㅠ', days);
    end if;
end $$
delimiter ;
call ifProc2();

# procedure + case
drop procedure if exists ifProc3;
delimiter $$
create procedure ifProc3()
begin
    declare point int;
    declare credit char(1);
    set point = 77;

    case
        when point >= 90 then set credit = 'A';
        when point >= 80 then set credit = 'B';
        when point >= 70 then set credit = 'C';
        when point >= 60 then set credit = 'D';
        else set credit = 'E';
        end case;

    select credit;
end $$
delimiter ;
call ifProc3();


# 유저별 총구매액
use sqldb;
select u.user_id
     , sum(price * amount) as total
     , case
           when sum(price * amount) >= 1500 then '최우수고객'
           when sum(price * amount) >= 1000 then '우수고객'
           when sum(price * amount) >= 1 then '일반고객'
           else '유령고객'
    end                    as '고객등급'
from buy b
         right join user u
                    on b.user_id = u.user_id
group by u.user_id, u.name
order by total desc;

# while
drop procedure if exists whileProc;
delimiter $$
create procedure whileProc()
begin
    declare i int;
    declare sum int;
    set i = 1;
    set sum = 0;

    myWhile:
    while (i <= 100)
        do
            if (i % 7 = 0) then
                set i = i + 1;
                iterate myWhile;
            end if;

            set sum = sum + i;

            if (sum > 1000) then
                leave myWhile;
            end if;

            set i = i + 1;
        end while;

    select sum;
end $$
delimiter ;
call whileProc();


# 예외 처리
drop procedure if exists errorProc;
delimiter $$
create procedure errorProc()
begin
    declare continue handler for 1146 select '테이블이 없네요' as 'message';
    select * from aaaaaaaaaaaaaa;
end $$
delimiter ;
call errorProc();

# 예외처리
drop procedure if exists errorProc2;
delimiter $$
create procedure errorProc2()
begin
    declare continue handler for sqlexception
        begin
            show errors;
            select '오류 발생' as 'message';
            rollback;
        end;
    INSERT INTO user VALUES ('LSG', '이승기', 1987, '서울', '011', '1111111', 182, '2008-08-08');
end $$
delimiter ;
call errorProc2();


# prepare, execute
drop table if exists prepare;
create table prepare
(
    id       int not null auto_increment primary key,
    datetime datetime
);

set @curDatetime = current_timestamp;
prepare myQuery from 'insert into prepare values (null, ?)';
execute myQuery using @curDatetime;
deallocate prepare myQuery;

select *
from prepare;
