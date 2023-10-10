--4장 SQL 함수 살펴보기

--#01 숫자함수 (수식연산)
--매개변수나 반환값이 대부분 숫자형태 
--ABS(n) 절대값

--CEIL / FLOOR 가장 큰 정수를 반환 
SELECT CEIL(10.123), CEIL(10.541), CEIL(11.001),
        FLOOR(10.123), FLOOR(10.541), FLOOR(11.001)
from dual;

--ROUND(n,i)와 TRUNC(n1,n2)
--ROUND : i+1자리수에서 반올림
--TRUNC : 잘라내기 


--#02 문자함수
--INITCAP(char), LOWER(cahr), UPPPER(char)

--SBUSTR, SUBSTRB(char, pos, len)

--LTRIM, RTRIM(char, set): set문자 생략 (공백제거용)
select LTRIM('ABCDEFG', 'ABC') from dual;

--LPAD, RPAD(expr1, n, expr2) :채워넣기
select LPAD('111-111',11, '02-') from dual; 

--REPLACE(char, serach_str, replace_str), TRANSLATE(expr, from_str, to_str) :문자열 대체 (문자열 중간 공백도 제거 가능)
select REPLACE('나는 너를 모르는데 너는 나를 알겠는가?', '나', '너') from dual;
--TRANCLATE : 문자열 자체가 아닌 문자 한 글자씩 매핑해 바꾼 결과를 반환★
select TRANSLATE('나는 너를 모르는데 너는 나를 알겠는가?', '나는', '너를') from dual;

--INSTR(str,substr,pos,occur): 일치하는 위치 반환. occur는 몇번째 일치하는지 자리값 반환 
select INSTR('내가 만약 외로울 때면, 내가 만약 괴로울 때면, 내가 만약 즐거울 때면', '만약') as instr1,
        INSTR('내가 만약 외로울 때면, 내가 만약 괴로울 때면, 내가 만약 즐거울 때면', '만약',5) as instr2,
        INSTR('내가 만약 외로울 때면, 내가 만약 괴로울 때면, 내가 만약 즐거울 때면', '만약',5,2) as instr3
from dual;

--LEGHTH, LEGHTB
select LENGTH('대한민국'), LENGTHB('대한민국') from dual; --4,8



--#03 날짜함수
--SYSDATE, SYSTIMESTAMP
select SYSDATE, SYSTIMESTAMP from dual;

--ADD_MONTHS(date, integer) :월 더하기 계산
select ADD_MONTHS(SYSDATE, 1), ADD_MONTHS(SYSDATE, -1) 
from dual;

--MONTHS_BETWEEN(date1, date2): 정수로 계산하고 싶다면 date1에 더 빠른날짜가 옴 
select MONTHS_BETWEEN(SYSDATE, ADD_MONTHS(SYSDATE,1)) --20230118 = -1
        ,MONTHS_BETWEEN(ADD_MONTHS(SYSDATE,1), SYSDATE) --20230118 = 1
from dual;

--LAST_DAY(date): 월의 마지막날
select LAST_DAY(SYSDATE) from dual;

--ROUND(date, format), TRUNC(date,format): 숫자함수 이면서 날짜함수 
--ROUND: format에 따라 반올림한 날짜를 반환 => 16일 기준으로
--TRUNC: 잘라낸 날짜를 반환
select ROUND(TO_DATE('2022-12-16','YYYY-MM-DD'), 'month'), TRUNC(TO_DATE('2022-12-16','YYYY-MM-DD'), 'month') from dual;
select ROUND(TO_DATE('2022-12-16','YYYY-MM-DD'), 'day'), TRUNC(TO_DATE('2022-12-16','YYYY-MM-DD'), 'day') from dual;
select ROUND(TO_DATE('2022-12-16','YYYY-MM-DD'), 'year'), TRUNC(TO_DATE('2022-12-16','YYYY-MM-DD'), 'year') from dual;
select TO_DATE('2022-12-16','YYYY-MM-DD') from dual;

--NEXT_DAY(date, char): char에서 명시한 날짜로 "다음 주중 일자"를 반환
select NEXT_DAY(SYSDATE, '화요일') from dual;



--#04 변환함수 (=명시적 형변환)
--TO_CHAR(숫자 혹은 날짜, format)
select TO_CHAR(123456789, '999,999,999') from dual;
select TO_CHAR(SYSDATE, 'YYYY-MM-DD') from dual;
--AM/PM
select TO_CHAR(SYSDATE, 'AM') from dual;
--년/월/일
select TO_CHAR(SYSDATE, 'YYYY') from dual;
select TO_CHAR(SYSDATE, 'MM') from dual;
select TO_CHAR(SYSDATE, 'DD') from dual;
--요일표기 (1 일요일, 2 월요일)
select TO_CHAR(SYSDATE, 'D') from dual;
select TO_CHAR(SYSDATE, 'DAY') from dual;
--365일 기준으로 표기
select TO_CHAR(SYSDATE, 'DDD') from dual;
--현재일을 요일까지 표기
select TO_CHAR(SYSDATE, 'DL') from dual;
--시간 표기
select TO_CHAR(SYSDATE, 'HH') from dual;
select TO_CHAR(SYSDATE, 'HH12') from dual;
select TO_CHAR(SYSDATE, 'HH24') from dual;
--분 (00~59)
select TO_CHAR(SYSDATE, 'MI') from dual;
--주를 01~53주 형태로 표기 
select TO_CHAR(SYSDATE, 'WW') from dual;
--숫자형식
select TO_CHAR(123456, '999,999') from dual; --콤마
select TO_CHAR(123456.4, '999,999.9') from dual; --소숫점 표시
select TO_CHAR(-123, '999PR') from dual; --음수일때<>로 표시
select TO_CHAR(123, 'RN') from dual; --로마숫자
select TO_CHAR(123456, 'S999999') from dual; --양수/음수 기호표시

--TO_NUMBER(expr, format): 숫자로 형변환
select TO_NUMBER('123456') from dual;

--TO_DATE(char, format), TO_TIMESTAMP()
select TO_DATE('20221212','YYYY-MM-DD') from dual;
select TO_DATE('20221212 13:44:50','YYYY-MM-DD HH24:MI:SS') from dual;



--#05 NULL 관련 함수
--NVL(expr1, expr2), NVL2(expr1, expr2, expr3)
select NVL(manager_id, employee_id) from employees
where manager_id IS NULL ;

--NVL2(expr1, expr2, expr3) : expr1이 null이 아니면 expr2를, null이면 expr3을 반환
select employee_id, NVL2(commission_pct, salary + (salary * commission_pct), salary) 
from employees;
with temp as (
    select 'exp1' as expr1, 'exp2_notNull' as expr2, 'exp3_notNull' as expr3 from dual
    union all
    select '' as expr1, 'exp2_Null' as expr2, 'exp3_Null' as expr3 from dual
)
select nvl2(expr1, expr2, expr3) from temp ;
    

--COALESCE(expr1, expr2) :null이 아닌 첫번째 표현식을 반환
select employee_id, salary, commission_pct
        , COALESCE(salary * commission_pct, salary) AS salary2
        , nvl(salary * commission_pct, salary) AS salary3
from employees
;


--LNNVL(조건식):조건식의 결과가 false 나 unknown이면 TRUE를, true이면 FALSE를 반환한다
--컬럼이 NULL인 경우 = TRUE
--함수 내부 조건이 FALSE인 경우 = TRUE
--e.g) 커미션이 0.2 이하인 사원 조회(null포함) 
/*
LNNVL(comm = 0) 은 아래와 동일한 조건으로 해석됨 
== AND (comm is null OR comm != 0)
★즉, LNNVL을 사용하는 이유는 null도 함께 조회되도록 하기위함이며, 
LNNVL 함수 내부의 조건은 조회하려고 하는 조건의 반대 조건으로 부여하는 것을 기억해야 한다. https://gent.tistory.com/387
*/
select employee_id, commission_pct from employees 
where commission_pct < 0.2; --11건 => 커미션이 null인 사람은 반환안됨
--case1) NVL로 null인 사원 0원 처리후 조회 
select count(*) from employees
where NVL(commission_pct, 0) <0.2; --83건
--case2) LNNVL로 해결
select  employee_id, commission_pct --count(*) 
from employees
where LNNVL(commission_pct >= 0.2);--83


--NULLIF(expr1, expr2): expr1, expr2를 비교해 같으면 NULL을, 같지않으면 expr1을 반환한다
select employee_id
--,start_date
        ,TO_CHAR(start_date, 'YYYY') start_year
        ,TO_CHAR(end_date, 'YYYY') end_year
        ,NULLIF(TO_CHAR(end_date, 'YYYY'), TO_CHAR(start_date, 'YYYY')) null_ifyear
from job_history
;

select  employee_id
        ,TO_CHAR(start_date, 'YYYY') start_year
        ,TO_CHAR(end_date, 'YYYY') end_year
        ,TRUNC(MONTHS_BETWEEN(TO_CHAR(end_date,'YYYYMMDD'), TO_CHAR(start_date, 'YYYYMMDD'))/12)
from job_history
where TRUNC(MONTHS_BETWEEN(TO_CHAR(end_date,'YYYYMMDD'), TO_CHAR(start_date, 'YYYYMMDD'))/12) > 0
;






--##06 기타함수
--GREATES(expr1, expr2,...), LEAST(expr1, expr2,...)
--숫자비교
select GREATEST(1,2,3,2), LEAST(1,2,3,2) from dual;

--문자비교
select GREATEST('이순신', '강감찬','세종대왕'), LEAST('이순신', '강감찬','세종대왕') from dual;

--DECODE(expr, search1, result1, search2, result2, ..., default)
select prod_id, channel_id,
        DECODE(channel_id, 3, 'Direct',
                           9, 'Direct',
                           5, 'Indirect',
                           4, 'Indirect',
                              'Others') decodes
from sales
where rownum < 10 
    and prod_id = 18
;


--SelfCheck
--1) (02) 붙이기 
select phone_number, LPAD(phone_number,16,'(02)') 
from employees;

--2) 근속년수 10년이상 집계 (오름차순)
select EMPLOYEE_ID, EMP_NAME, HIRE_DATE, trunc(months_between(sysdate,hire_date)/12) as work_year 
from EMPLOYEES
where months_between(sysdate,hire_date)/12 > 10
order by work_year desc
;

--3)전화번호 '-' -> '/'로 변환 
select CUST_MAIN_PHONE_NUMBER, replace(CUST_MAIN_PHONE_NUMBER, '-', '/')
from customers ;

--4) 고객전화번호 암호화
select CUST_MAIN_PHONE_NUMBER, translate(CUST_MAIN_PHONE_NUMBER, '12345678900-', 'qwertyuiopa')
from customers
;

--5)cust_year_of_birth 컬럼으로 30,40,50대 연령구분 (DECODE 사용)
WITH T_AGE AS (
select  CUST_ID
        , CUST_NAME
        , trunc(months_between(sysdate, TO_DATE(CUST_YEAR_OF_BIRTH||'0101','YYYYMMDD') )/12)+1 AS K_AGE
from customers
)
select CUST_ID
     , CUST_NAME 
     , K_AGE
     , DECODE (substr(K_AGE,1,1),'3', '30대', '4','40대', '5','50대', '기타') AS AGE
from T_AGE
order by K_AGE
;



--##6. 5번문제 CASE문 사용
WITH T_AGE AS (
select  CUST_ID
        , CUST_NAME
        , trunc(months_between(sysdate, TO_DATE(CUST_YEAR_OF_BIRTH||'0101','YYYYMMDD') )/12)+1 AS K_AGE
from customers
)
select --CUST_ID
--     , CUST_NAME 
--     , K_AGE
        distinct K_AGE
     , CASE WHEN substr(K_AGE,1,1) = '3' THEN '30대'
      WHEN substr(K_AGE,1,1) = '4' THEN '40대'
      WHEN substr(K_AGE,1,1) = '5' THEN '50대'
      WHEN substr(K_AGE,1,1) = '6' THEN '60대'
      ELSE '기타'
      END AS AGE 
from T_AGE
order by K_AGE
;


