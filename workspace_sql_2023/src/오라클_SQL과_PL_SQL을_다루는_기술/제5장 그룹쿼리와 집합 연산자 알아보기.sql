--###5장 그룹쿼리와 집합 연산자 알아보기 

--##01 기본 집계함수 : 대상 데이터를 특정 그룹으로 묶은 다음 이그룹에 대해 총합, 평균, 최댓값, 최솟값 등을 구하는 함수 
--COUNT(expr): 쿼리결과 건수 반환 **null이 아닌 건에 대해서만 로우의 수 반환 
select count(*) from employees; --107
select count(department_id) from employees; --106(null제외)
select count(distinct department_id) from employees; --11건
select distinct department_id from employees; --12건 (유일값, null 제외)

--SUM(expr): expr는 숫자형만 가능 
select SUM(salary) from employees;
select SUM(distinct salary) from employees;


--AVG(expr) : 평균값
select ROUND(AVG(salary),5)
        , ROUND(AVG(distinct salary),5)
from employees;


--MIN(expr), MAX(expr) : 최솟값, 최댓값
select MIN(salary), MAX(salary) from employees;


--VARIANCE(expr): 분산 (주어진 범위의 개별 값과 평균값과의 차이인 편차를 구해 이를 제곱해서 평균한 값)
--STDDEV(expr) : 표준편차(분산 값의 제곱근) => 실제 통계에서는 평균을 중심으로 값들이 어느정도 분포하는지를 나타내는 수치인 표준편차를 사용
select ROUND(VARIANCE(salary),5)
    , ROUND(STDDEV(salary),5) 
from employees;



--##02 GROUP BY절, HAVING 절
--전체가 아닌 특정 그룹으로 묶어 데이터를 집계할때 사용 
--GROUP BY : WHERE와 ORDER절 사이에 위치 
select department_id, SUM(salary)
from employees
group by department_id
order by DEPARTMENT_ID
;


select * from KOR_LOAN_STATUS ;
--2013년 지역별 가계대출 총 잔액 구하기
select 
    period
    , region 
    , SUM(loan_Jan_AMT) AS "대출잔액(십억)"
from KOR_LOAN_STATUS
where period like '2013%'
group by period, region
order by period, region 
;

--2013년 11월 총 잔액
select period
    , region
    , SUM(loan_jan_amt) as 잔액
from kor_loan_status
where PERIOD = '201311'
group by period, region  --> 구문 문법상, select 리스트에 있는 컬럼명이나 표현식중 집계함수를 제외하고는 모두 group by 절에 명시해야함
;

--HAVING : GROUP BY절 다음에 위치해 group by한 결과를 대상으로 다시 필터를 거는 역할수행.
--즉, HAVING 필터조건 형태로 사용 
select period
    , region
    , SUM(loan_jan_amt) as 잔액
from kor_loan_status
where PERIOD = '201311'
group by period, region
having sum(loan_jan_amt) >= 100000
order by region
;



--ROLLUP절과 CUBE절: GROUP BY 절에서 사용되어 그룹별 소계를 추가로 보여주는 역할.

--ROLLUP(expr1, expr2, ...): expr로 명시한 표현식을 기준으로 집계한 결과(=추가적인 집계정보)를 보여줌
--ROLLUP절에 명시할 수 있는 표현식에는 그룹핑 대상(select 리스트에서 집계함수를 제외한 컬림)이 올수있고, 
--명시한 표현식 수와 순서(오른쪽에서 왼쪽 순으로)에 따라 레벨별로 집계한 결과가 반환됨
--표현식 개수가 n개이면, n+1레벨까지, 하위레벨에서 상위레벨 순으로 데이터가 집계된다.
select period, gubun, round(sum(loan_jan_amt),2) totl_jan
from kor_loan_status
where period like '2013%'
--group by period, gubun
group by rollup(period, gubun) --n+1 레벨까지 집계됨
order by period;
/*
201310	기타대출	    676078
201310	주택담보대출	411415.9    -> level 3 (period, gubun)
201310		        1087493.9   -> level 2 (period)
201311	기타대출	    681121.3    
201311	주택담보대출	414236.9
201311		        1095358.2   -> levle 2 (period)
                    2182852.1   -> level 1 (total)
*/

--분할ROLLUP: e.g) GROUP BY expr1, ROLLUP(expr2, expr3)
select period, gubun, sum(loan_jan_amt) totl_jan
from kor_loan_status
where period like '2013%'
GROUP BY period, ROLLUP(gubun); -- n+1 level = 2
/*
201310	기타대출	    676078
201310	주택담보대출	411415.9    -> level 2 (period, gubun)
201310		        1087493.9   -> level 1 (period)
201311	기타대출	    681121.3
201311	주택담보대출	414236.9
201311		        1095358.2
*/


select period, gubun, sum(loan_jan_amt) totl_jan
from kor_loan_status
where period like '2013%'
GROUP BY ROLLUP(period), gubun; -- n+1 level = 2
/*
201310	기타대출	    676078
201311	기타대출	    681121.3
        기타대출	    1357199.3
201310	주택담보대출	411415.9
201311	주택담보대출	414236.9
        주택담보대출	825652.8
*/


--CUBE(expr1, expr2, ...) :ROLLUP과 비슷하지만 다른 개념
--ROLLUP: 레벨별로 순차적 집계
--CUBE  : 명시한 표현식 개수에 따라 "가능한 모든 조합별"로 집계결과 반환 (= 2의 expr제곱 만큼 종류별로 집계됨)
--        e.g) expr 수가 3이면 2^3 = 8개의 집계유형으로 결과 반환 
select period, gubun, sum(loan_jan_amt) totl_jan
from kor_loan_status
where period like '2013%'
group by CUBE(period, gubun); --2^2 = 총 4가지 유형
/*
                    2182852.1   -> type 1 (total)
        기타대출	    1357199.3   -> type 2 (gubun)
        주택담보대출	825652.8
201310	    	    1087493.9   -> type 3 (period)
201310	기타대출	    676078      -> type 4 (period, gubun)
201310	주택담보대출	411415.9
201311		        1095358.2
201311	기타대출	    681121.3
201311	주택담보대출	414236.9
*/

--분할 CUBE
select period, gubun, sum(loan_jan_amt) totl_jan
from kor_loan_status
where period like '2013%'
group by period, CUBE(gubun); -- 2^1 = 2 유형 결과반환 
/*
201310		        1087493.9   -> type 1) period
201310	기타대출	    676078      -> type 2) period, gubun 
201310	주택담보대출	411415.9
201311		        1095358.2
201311	기타대출	    681121.3
201311	주택담보대출	414236.9
*/



--#04 집합 연산자
--UNION, UNION ALL, INTERSECT, MINUS 


--UNION 합집합
CREATE TABLE exp_goods_asia (
    country VARCHAR2(10)
    , seq   NUMBER
    , goods VARCHAR2(80)
);

select * from exp_goods_asia;

INSERT INTO exp_goods_asia VALUES('한국', 1, '원유제외 석유류');
INSERT INTO exp_goods_asia VALUES('한국', 2, '자동차');
INSERT INTO exp_goods_asia VALUES('한국', 3, '전자집적회로');
INSERT INTO exp_goods_asia VALUES('한국', 4, '선박');
INSERT INTO exp_goods_asia VALUES('한국', 5, 'LCD');
INSERT INTO exp_goods_asia VALUES('한국', 6, '자동차부품');
INSERT INTO exp_goods_asia VALUES('한국', 7, '휴대전화');
INSERT INTO exp_goods_asia VALUES('한국', 8, '환식탄화수소');
INSERT INTO exp_goods_asia VALUES('한국', 9, '무송신기 디스플레이 부속품');
INSERT INTO exp_goods_asia VALUES('한국', 10, '철 또는 비합금강');


INSERT INTO exp_goods_asia VALUES('일본',1 , '자동차');
INSERT INTO exp_goods_asia VALUES('일본',2 , '자동차부품');
INSERT INTO exp_goods_asia VALUES('일본',3 , '전자집적회로');
INSERT INTO exp_goods_asia VALUES('일본',4 , '선박');
INSERT INTO exp_goods_asia VALUES('일본',5 , '반도체웨이퍼');
INSERT INTO exp_goods_asia VALUES('일본',6 , '화물차');
INSERT INTO exp_goods_asia VALUES('일본',7 , '원유제외 석유류');
INSERT INTO exp_goods_asia VALUES('일본',8 , '건설기계');
INSERT INTO exp_goods_asia VALUES('일본',9 , '다이오드, 트랜지스터');
INSERT INTO exp_goods_asia VALUES('일본',10, '기계류');

SELECT goods FROM EXP_GOODS_ASIA
where country = '한국'
UNION 
SELECT goods FROM EXP_GOODS_ASIA
where country = '일본'
--order by seq;
;


SELECT goods FROM EXP_GOODS_ASIA
where country = '한국'
UNION ALL
SELECT goods FROM EXP_GOODS_ASIA
where country = '일본'
--order by seq;
;


--INTERSECT  교집합
SELECT goods FROM EXP_GOODS_ASIA
where country = '한국'
INTERSECT
SELECT goods FROM EXP_GOODS_ASIA
where country = '일본'
--order by seq;
;

--MINUS
SELECT goods FROM EXP_GOODS_ASIA
where country = '한국'
MINUS
SELECT goods FROM EXP_GOODS_ASIA
where country = '일본'
--order by seq;
;


--##집합 연산자의 제한사항 
--1) 집합 연산자로 연결되는 각 SELECT문의 SELECT 리스트의 개수와 데이터 타입은 일치해야 한다
SELECT seq, goods 
FROM EXP_GOODS_ASIA
where country = '한국'
UNION
SELECT seq, goods --안됨  
FROM EXP_GOODS_ASIA
where country = '일본'
--order by seq;
;
--위의 쿼리에서 제외된 중복건은 INTERSECT로 확인 가능함
SELECT seq, goods FROM EXP_GOODS_ASIA
where country = '한국'
INTERSECT
SELECT seq, goods FROM EXP_GOODS_ASIA
where country = '일본'
--order by seq;
;

--2)집합 연산자로 SEELCT문을 연결할 때 ORDER BY절은 맨 마지막 문장에서만 사용할 수 있다
SELECT goods FROM EXP_GOODS_ASIA
where country = '한국'
UNION
SELECT goods FROM EXP_GOODS_ASIA
where country = '일본'
order by goods
;

--3)BLOB, CLOB, BFILE 타입의 컬럼에 대해서는 집합 연산자를 사용할 수 없다
--4)UNION, INTERSECT, MINUS 연산자는 LONG형 컬럼에는 사용할 수 없다



--##GROUPING SETS 절
--ROLLUP이나 CUBE처럼 GROUP BY절에 명시해서 그룹쿼리에 사용하는 절. (그룹쿼리이나 UNION ALL 개념이 섞여있음★)
--GROUPING SETS(expr1, expr2, expr3)
--위와 동일. GROUP BY(expr1) UNION ALL GROUP BY(expr2) UNION ALL GROUP BY(expr3)
SELECT period, gubun, SUM(loan_jan_amt) totl_jan
FROM KOR_LOAN_STATUS
WHERE period LIKE '2013%'
GROUP BY GROUPING SETS(period, gubun)
;

SELECT period, gubun, region, SUM(loan_jan_amt) totl_jan
FROM KOR_LOAN_STATUS
WHERE period LIKE '2013%'
GROUP BY GROUPING SETS(period, (gubun, region))
;


--##Self Check
--1. 사원 테이블에서 입사년도별 사원수 구하기
--select CASE WHEN SUBSTR(HIRE_DATE,1,4) IS NOT NULL THEN SUBSTR(HIRE_DATE,1,4)
--        ELSE '총합'
--        END AS HIRE_Y
select    DECODE(GROUPING(SUBSTR(hire_date,1,4)), 1, '총합', SUBSTR(HIRE_DATE,1,4)) AS HIRE_Y2
       , count(*)
from EMPLOYEES
group by rollup(SUBSTR(hire_date,1,4))
;
select count (*) from EMPLOYEES
;

--2.kor_loan_status 테이블에서 2012년도 월별, 지역별 대출 총 잔액을 구하는 쿼리 작성하기
select  PERIOD, REGION, sum(LOAN_JAN_AMT)
from KOR_LOAN_STATUS
where PERIOD like '2012%'
group by GROUPING SETS(PERIOD, REGION)
;

--3. rollup 쓰지않고 아래와 동일한 결과 나오게 쿼리짜기 
select period , gubun, sum(LOAN_JAN_AMT) totl_jan
from KOR_LOAN_STATUS
where period like '2013%'
group by PERIOD, rollup(GUBUN)
;
201310	기타대출	    676078
201310	주택담보대출	411415.9
201310		        1087493.9
201311	기타대출	    681121.3
201311	주택담보대출	414236.9
201311		        1095358.2
;
select period , gubun, sum(LOAN_JAN_AMT) totl_jan
from KOR_LOAN_STATUS
where period like '2013%'
group by PERIOD, gubun
UNION ALL
select period , '' AS gubun, sum(LOAN_JAN_AMT) totl_jan
from KOR_LOAN_STATUS
where period like '2013%'
group by PERIOD
;

--4. 집합연산자로 아래 쿼리와 동일한 결과 만들기 
select period
     , case when gubun = '주택담보대출' then sum(loan_jan_amt) else 0 end 주택담보대출액
     , case when gubun = '기타대출'     then sum(loan_jan_amt) else 0 end 기타대출액   
from kor_loan_status
where period = '201311'
group by period, gubun
;
201311	414236.9	0
201311	0	        681121.3
;
select period--, sum(loan_jan_amt) AS 주택담보대출액
    , case when gubun = '주택담보대출' then sum(loan_jan_amt) else 0 end 주택담보대출액
    , case when gubun = '기타대출'     then sum(loan_jan_amt) else 0 end 기타대출액
from kor_loan_status
where period = '201311' and gubun = '주택담보대출'
group by period, gubun
union all
select period--, sum(loan_jan_amt) AS 기타대출액
    , case when gubun = '주택담보대출' then sum(loan_jan_amt) else 0 end 주택담보대출액
    , case when gubun = '기타대출'     then sum(loan_jan_amt) else 0 end 기타대출액
from kor_loan_status
where period = '201311' and gubun = '기타대출'
group by period, gubun
;


--5. 
