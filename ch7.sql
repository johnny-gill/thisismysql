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
select locate('b', 'abc'); -- 2

# 실수 포맷
select format(12345.123456789, 5); -- 12,345.12346

# 삽입
select insert('123456789', 3, 5, '@@@@'); -- 12@@@@89, 3번째부터 5개 문자를 지우고 @@@@삽입

# 패딩
select lpad('123456789', 11, '@'); -- @@123456789, 길이를 11로 늘리고 빈곳을 @로 채우기
select rpad('123456789', 11, '@'); -- 123456789@@

# 문자열 자르기
select left('123456789', 3); -- 123
select right('123456789', 3); -- 789

select substring('123456789', 1, 3); -- 123
select substring('123456789', 4, 3); -- 456

select substring_index('123.456.789', '.', 2); -- 123.456
select substring_index('123.456.789', '.', -2); -- 456.789

# 공백 제거 - 중간 공백은 처리 불가
select ltrim('      12345 6789      '); -- '12345 6789      '
select rtrim('      12345 6789      '); -- '      12345 6789'
select trim('      12345 6789      '); -- '12345 6789'
select trim(both ' ' from '      12345 6789      '); -- '12345 6789'
select trim(leading ' ' from '      12345 6789      '); -- '12345 6789      ', ltrim과 동일
select trim(trailing ' ' from '      12345 6789      '); -- '      12345 6789', rtrim과 동일

# 공백 추가
select space(10); -- '          '

# 반복
select repeat('123456789', 2); -- 123456789123456789

# 변경
select replace('123456789', '123', '#####'); -- #####456789

# 거꾸로
select reverse('123456789');


# 날짜 계산
select adddate('2024-05-01', interval 31 day); -- 2024-06-01
select adddate('2024-05-01', interval 1 month); -- 2024-06-01
select subdate('2024-07-01', interval 30 day); -- 2024-06-01
select subdate('2024-07-01', interval 1 month); -- 2024-06-01


# 시간 계산
select addtime('2024-05-31 23:59:59', '0:0:1'); -- 2024-06-01 00:00:00
select addtime('23:59:59', '0:0:1'); -- 24:00:00
select subtime('2024-06-02 00:00:00', '0:0:1'); -- 2024-06-01 23:59:59
select subtime('24:00:00', '0:0:1'); -- 23:59:59


# 현재날짜/시간
select curdate();
select curtime();
select now(); -- sysdate와 동일
select sysdate();

# 날짜/시간 추출
select date('2024-06-01 00:00:00'); -- 2024-06-01
select time('2024-06-01 00:00:00'); -- 00:00:00

# 날짜/시간 차이
select datediff('2024-06-02', '2024-06-01'); -- 1
select timediff('2024-06-02 00:00:00', '2024-06-01 12:00:00'); -- 12:00:00

# 뭐가 많군.....

# 정보
select user(), database(), version(), sleep(4);

#
update buy set price=price*2;
select row_count();

