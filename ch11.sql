# fulltext index 전체텍스트 인덱스

# stopword를 제외하고 전체텍스트 인덱스를 만들어준다.
select *
from information_schema.INNODB_FT_DEFAULT_STOPWORD;

# 단어의 최소값 3.. my.ini에서 2로 바꿔보자.
show variables like 'innodb_ft_min_token_size';


# 데이터 생성
create database if not exists `fulltext`;
use `fulltext`;
drop table if exists `fulltext`;
create table `fulltext`
(
    id          int auto_increment primary key,
    title       varchar(15) not null,
    description varchar(1000)
);

insert into `fulltext`
values (NULL, '광해, 왕이 된 남자', '왕위를 둘러싼 권력 다툼과 당쟁으로 혼란이 극에 달한 광해군 8년'),
       (NULL, '간첩', '남한 내에 고장간첩 5만 명이 암약하고 있으며 특히 권력 핵심부에도 침투해있다.'),
       (NULL, '남자가 사랑할 때', '대책 없는 한 남자이야기. 형 집에 얹혀 살며 조카한테 무시당하는 남자'),
       (NULL, '레지던트 이블 5', '인류 구원의 마지막 퍼즐, 이 여자가 모든 것을 끝낸다.'),
       (NULL, '파괴자들', '사랑은 모든 것을 파괴한다! 한 여자를 구하기 위한, 두 남자의 잔인한 액션 본능!'),
       (NULL, '킹콩을 들다', ' 역도에 목숨을 건 시골소녀들이 만드는 기적 같은 신화.'),
       (NULL, '테드', '지상최대 황금찾기 프로젝트! 500년 전 사라진 황금도시를 찾아라!'),
       (NULL, '타이타닉', '비극 속에 침몰한 세기의 사랑, 스크린에 되살아날 영원한 감동'),
       (NULL, '8월의 크리스마스', '시한부 인생 사진사와 여자 주차 단속원과의 미묘한 사랑'),
       (NULL, '늑대와 춤을', '늑대와 친해져 모닥불 아래서 함께 춤을 추는 전쟁 영웅 이야기'),
       (NULL, '국가대표', '동계올림픽 유치를 위해 정식 종목인 스키점프 국가대표팀이 급조된다.'),
       (NULL, '쇼생크 탈출', '그는 누명을 쓰고 쇼생크 감옥에 감금된다. 그리고 역사적인 탈출.'),
       (NULL, '인생은 아름다워', '귀도는 삼촌의 호텔에서 웨이터로 일하면서 또 다시 도라를 만난다.'),
       (NULL, '사운드 오브 뮤직', '수녀 지망생 마리아는 명문 트랩가의 가정교사로 들어간다'),
       (NULL, '매트릭스', ' 2199년.인공 두뇌를 가진 컴퓨터가 지배하는 세계.');
select *
from `fulltext`;


# fulltext index 생성
-- %% 검색은 인덱스가 있든 없든 full table scan을 한다
select *
from `fulltext`
where description like '%남자%';

create fulltext index idx_description on `fulltext` (description);
show index from `fulltext`;

-- 남자~로 시작하는 단어가 있으면..
select *
from `fulltext`
where match(description) against('남자*' in boolean mode);

-- 남자~ or 여자~로 시작하는 단어가 있으면..
select *, match(description) against('남자* 여자*' in boolean mode) as 점수
from `fulltext`
where match(description) against('남자* 여자*' in boolean mode);

-- 남자~ and 여자~
select *
from `fulltext`
where match(description) against('+남자* +여자*' in boolean mode);

-- 남자~인데 여자~는 제외
select *
from `fulltext`
where match(description) against('남자* -여자*' in boolean mode);


# 전체인덱스로 생성된 단어
show variables like 'innodb_ft_aux_table'; -- 빈값임
set global innodb_ft_aux_table = 'fulltext/fulltext'; -- db명/테이블명
select *
from information_schema.INNODB_FT_INDEX_TABLE; -- 전체텍스트 인덱스로 생성된 단어..약 130개.. 필요없는 단어는 중지단어로 추가
drop index idx_description on `fulltext`;


# 중지 단어 추가
-- 무조건 컬럼명은 value, 데이터타입은 varchar
create table stopword
(
    value varchar(30)
);
insert into stopword
values ('그는'),
       ('그리고'),
       ('극에');

show variables like 'innodb_ft_server_stopword_table'; -- 빈값임
set global innodb_ft_server_stopword_table = 'fulltext/stopword';

-- 다시 fulltext index 생성
create fulltext index idx_description on `fulltext` (description);
select *
from information_schema.INNODB_FT_INDEX_TABLE;
-- stopword로 지정된 단어는 전체 테이블 인덱스에 저장되지 않음


# 파티션
-- 파티션은 8192개까지 지원. 파티션 테이블은 파일이 동시에 열리는데, 동시에 파일 열 수 있는 개수가 5000(open_file_limit).
-- 즉, 파티션 5000개 이상일때는 open_file_limit을 수정해줘야함

-- sqldb 초기화
use sqldb;
select *
from user;
select *
from buy;

-- 파티션으로 테이블 생성
create database if not exists part;
use part;
drop table if exists part;

create table part
(
    user_id    char(8)     not null,
    name       varchar(10) not null,
    birth_year int         not null,
    addr       char(2)     not null
)
    partition by range (birth_year) (
        partition part1 values less than (1971), -- birth_year < 1971은 part1에 저장
        partition part2 values less than (1979), -- 1971 <= birth_year < 1979은 part2에 저장
        partition part3 values less than maxvalue -- 1979 <= birth_year < max은 part3에 저장
        );
-- C:\ProgramData\MySQL\MySQL Server 8.0\Data\part에 3개로 나눠서 생성됐음 ㅋㅋ
-- range 열에는 숫자형이여야함.
-- 예) partition by list columns (address) 은 숫자 또는 문자형으로..
-- pk를 지정하고 싶으면 range 열을 포함하여 지정해야함.


insert into part
select user_id, name, birth_year, address
from sqldb.user;
select *
from part; -- 파티션 순서대로 조회됨

select *
from information_schema.PARTITIONS
where table_name = 'part';

explain
select *
from part
where birth_year <= 1965;
-- part1 파티션만 사용했다~


# 파티션 나누기
alter table part
    reorganize partition part3 into (
        partition part3 values less than (1986),
        partition part4 values less than maxvalue
        );
optimize table part;
select *
from information_schema.PARTITIONS
where TABLE_NAME = 'part';


# 파티션 합치기
alter table part
    reorganize partition part1, part2 into (
        partition part12 values less than (1979)
        );
optimize table part;
select *
from information_schema.PARTITIONS
where TABLE_NAME = 'part';


# 파티션 삭제
alter table part
    drop partition part12;
optimize table part;
select *
from information_schema.PARTITIONS
where TABLE_NAME = 'part';
select *
from part;

