/*
 * 1. 계층형 쿼리
 * 2. WITH절
 * 3. 분석함수와 window 함수
 * 4. 다중테이블 INSERT 
 */

--## 1. 계층형 쿼리
/* 계층형쿼리란, 2차원 형태의 테이블에 저장된 데이터를 계층형 구조로 결과를 반환하는 쿼리를 말한다. (=상하수직관계의 구조) 
 * 
 * 계층쿼리 사용법 : SELECT expr1, expr2 ..
 *          FROM 테이블
 *         WHERE 조건
 *        START WITH [최상위조건] --계층형 구조에서 최상위 계층의 로우를 식별하는 조건을 명시. 
 *        CONNECT BY [NOCYCLE][PRIOR 계층형 구조 조건]  --계층형구조가 어떤식으로 연결되는지를 기술하는 부분 (부서테이블은 parent_id에 상위부서정보를 가지고 있는데 이를 표현하려면 connect by prior department_id = parent_id; 로 기술해야함.
 * 
 * LPAD 사용법 : LPAD(값, 총문자길이, 채움문자) --지정한 길이만큼 왼쪽부터 채움문자로 채운다. (채운문자를 지정하지 않으면 공백으로 해당길이만큼 채움)
 *        ;   
 *       
 * */
select LPAD('> ', 4*(LEVEL-1)) || department_id
     , LPAD('> ', 4*(LEVEL-1)) || DEPARTMENT_NAME as DEPARTMENT_NAME
     , parent_id, LEVEL
  from DEPARTMENTS
START WITH parent_id is null
connect by prior department_id = parent_id
;

--# 사원정보 계층으로 보기
select a.employee_id, LPAD(' ', 3*(LEVEL-1)) || a.emp_name, LEVEL, a.department_id, b.department_name , a.manager_id
from employees a,
     departments b
where a.department_id = b.department_id
--add condition 
--  and a.department_id = '30' --최상위 로우 제외됨.
START WITH a.manager_id is null 
CONNECT BY prior a.employee_id = a.manager_id
--add condition 
  and a.department_id = '30' --자식 로우의 조건 
;

select * from employees a
where a.manager_id is null 
;

------- 계층형 쿼리 심화학습 --------
--# 1. 계층형 쿼리 정렬 
--계층형 쿼리는 계층형 구조에 맞세 순서대로 출력되는데 ORDER BY 절로 그 순서를 변경할 수 있다. 
select department_id, LPAD(' >', 3*(LEVEL-1)) || department_name , LEVEL
from departments
START WITH parent_id is null
CONNECT BY prior department_id = parent_id
--ORDER BY department_name --ORDER BY를 쓰면 계층구조가 깨져버림..
ORDER SIBLINGS BY department_name --동일한 계층내의 순서적용  
;

--# 2. CONNECT_BY_ROOT
--계층형 쿼리에서 최상위 로우를 반환하는 연산자. (연산자이므로, CONNECT_BY_ROOT 다음에는 아래와 같은 표현식이 붙음)
select department_id, LPAD(' >', 3*(LEVEL-1)) || department_name , LEVEL  
	  ,CONNECT_BY_ROOT department_name AS root_name --최상위 로우 반환 
from DEPARTMENTS
START WITH parent_id is null
CONNECT BY prior department_id = parent_id
;

--# 3. CONNECT_BY_ISLEAF
--CONNECT BY 조건에 정의된 관계에 따라 해당 로우가 최하위 자식로우이면 1을 반환, 그렇지 않으면 0을 반환함.
select department_id, LPAD(' >', 3*(LEVEL-1)) || department_name , LEVEL  
	  , CASE WHEN CONNECT_BY_ISLEAF = 1 THEN '최하위 로우(1)' ELSE ' ' END AS ISLEAF   
from DEPARTMENTS
START WITH parent_id is null
CONNECT BY prior department_id = parent_id
;

--# 4. SYS_CONNECT_BY_PATH(colm,char) --> 첫번째 param : 컬럼 , 두번째 param : 구분자 (구분자로 해당 컬럼값에 포함된 문자는 사용할수 없음) e.g) 구매/생산부 ---> '/' 사용못함. 
--계층형 쿼리에서만 사용할수 있는함수.루트노드에서 시작해 자신의 행까지 연결된 경로 정보를 반환함.
select department_id , LPAD('  >', 3*(LEVEL-1)) || department_name, LEVEL , parent_id
	  --,SYS_CONNECT_BY_PATH(department_name, '|')
from departments
START WITH parent_id is null
CONNECT BY prior department_id = parent_id
;

--# 5. CONNECT_BY_ISCYCLE (무한루프 오류시 확인하기)
-- NOCYCLE 조건을 걸어주고, CONNCEC_BY_ISCYCLE로 무한루프 로우 확인 (사이클이면 1을 표기) 
select * from departments where department_id = 30 --parent_id 10 
;
--무한루프 조건으로 업데이트 해서 오류 발생시킴 
--update departments
--   set parent_id = 170
-- where department_id = 30;
rollback;

select department_id , LPAD('  >', 3*(LEVEL-1)) || department_name, LEVEL 
	  ,parent_id
	  ,CONNECT_BY_ISCYCLE isLoop --오류찾는 로우 (사이클 : 1, 아니면 0) 
from departments
START WITH department_id = 30
CONNECT BY NOCYCLE prior department_id = parent_id
;




/********************
--# 계층형 쿼리 응용 #
********************/
--# 1) 샘플데이터 생성
 
--예제 데이터 생성시 CONNECT BY 구문을 자주 사용함. 
--튜닝효과를 위해 다량의 데이터 생성시 계층형쿼리와 오라클에서 제공하는 DBMS_RANDOM이란 패키지(난수생성)을 사용하면 몇만건의 데이터도 쉽게 생성가능. 
CREATE TABLE ex7_1 AS (
select ROWNUM seq,
	   '2014'||LPAD(CEIL(ROWNUM/1000), 2, '0') month, --★LPAD(값, 총문자길이, 채움문자)
	   ROUND(DBMS_RANDOM.VALUE (100, 1000)) amt 	  --★DBMS_RANDOM.VALUE(low IN NUMBER, high IN NUMBER) 랜덤한 숫자생성(최소범위,최대범위) 
	   --,LEVEL
from dual
CONNECT BY LEVEL <= 12000
)
;

select month, sum(amt)--* 
from ex7_1 
group by month
order by month 
;

/* CONNECT BY LEVEL <= 숫자 : 명시한 숫자만큼의 로우를 반환.  
 * 내부적으로 보면 등비수열의 합만큼 로우를 생성. 
 * DUAL 테이블은 기본 로우 개수는 1개인데 "SELECT ... FROM DUAL CONNECT BY LEVEL <= 3"이라고 명시할때 이는 첫째항(a=1), 공비(r=1), 항의 수(n=3)인 등비수열에 해당한다.*/
SELECT * FROM DUAL 
CONNECT BY LEVEL <= 3 --3 row 리턴 
;


--다음과 같이 서브쿼리로 DUAL테이블을 조회하는 쿼리를 UNION ALL로 연결하면, 맨 바깔에 있는 쿼리의 기본 로우수는 1이 아닌, 2가 된다.
SELECT ROWNUM, ROW_NUM, LEVEL--, RN
FROM (SELECT '1_A' ROW_NUM 
	  FROM DUAL 
	  UNION ALL
	  SELECT '1_B' ROW_NUM  
	  FROM DUAL
	  )
CONNECT BY LEVEL <= 4 -- 서브쿼리 2 row^4 
;
항수^
 a^n
 2^1, 2^2, 2^3, 2^4 
= 2  + 4  + 8 + 16 

/* 등비수열 합(S)공식
 * 등비수열이란 : 첫째항부터 차례대로 일정한 수(=공비)를 곱하여 만든 수열
 * 공비r = 1이면, S = a*n
 * 공비r!= 1이면, S = a(1-r^n)/(1-r)
      r = 2  , S = 2(1-2^4)/(1-2)
                 = 2(1-16)/-1
                 = 2(-15)/-1
                 = 30  
 **/
--공비 r = 1 경우 
--a=1, r=1, n=3 
--1*3 = 3
select rownum from (
	select rownum
	from dual
	--connect by level <= 3
)
connect by level <= 3
;

--공비 r!= 1 경우
--a=2 , r=2, n=4
--2(1-16)/(1-2)  ---> 2*15 = 30 
select ROWNUM, A.*, LEVEL, SYS_CONNECT_BY_PATH(row_num, '|')
from (
		select 1 AS row_num --, LEVEL
		from dual
		UNION ALL
		select 2 AS row_num --, LEVEL
		from dual 
		--CONNECT BY LEVEL <= 4
) A
CONNECT BY LEVEL <= 4
order by LEVEL, ROW_NUM
; 

--test 
select ROWNUM, A.*, LEVEL, SYS_CONNECT_BY_PATH(row_num, '|')
from (
		select 1 AS row_num 
		from dual
		UNION ALL
		select 2 AS row_num 
		from dual 
		UNION ALL
		select 3 AS row_num 
		from dual 
) A
CONNECT BY LEVEL <= 2
order by LEVEL
; 
 a^n
 3^1, 3^2--, 2^3, 2^4 
= 3  + 9 -- + 8 + 16 


---------------------------------

--# 2) 로우를 컬럼으로 변환하기 (LISTAGG)
--LISTAGG(expr, delimiter) WITHIN GROUP(ORDER BY절) --> expr을 delimiter로 구분해서 로우를 컬럼으로 변환해 조회하는 함수.
--LISTAGG는 그룹함수이기 떄문에, GROUP BY 또는 PARTITION BY절과 함께 사용한다. 
CREATE TABLE ex7_2 AS (
select --department_id ,
		LISTAGG(emp_name, ',') WITHIN GROUP (ORDER BY emp_name) as empnames
from employees
where department_id is not null
GROUP BY department_id
)
;
select * from employees ;

select manager_id, LISTAGG(emp_name,', ') WITHIN GROUP(ORDER BY emp_name) as names 
from employees
group by manager_id
; 


--# 3) 컬럼을 로우로 변환하기 (계층형 쿼리 사용)
select REPLACE(SUBSTR(empnames, start_pos, end_pos - start_pos), ',' , '') as emp_name
		--SUBSTR(empnames, start_pos, end_pos)
		--INSTR 사용법 : INSTR(컬럼명, '찾을문자', 1:앞에서부터검색, 몇번째 찾은위치)
from ( 
		select empnames
			 , LEVEL as lvl
			 , DECODE(level , 1, 1, INSTR(empnames, ',',1, LEVEL-1)) start_pos
			 , INSTR(empnames, ',' ,1 ,LEVEL) end_pos
		from (
				select empnames || ',' AS empnames
					  , LENGTH(empnames) ori_len
					  , LENGTH(REPLACE(empnames, ',', '')) new_len
				from ex7_2
				where department_id = '90'
		)
		CONNECT BY LEVEL <= ori_len - new_len +1
)
;



---------------------------------------------------
/********************
 # 02.WITH 절 #
********************/
--개선된 서브쿼리 

/* 연도별 최종월 기준 가장 대출이 많은 도시와 잔액을 구하라. (합계) 
 * 1) 연도별 최종월 구하기 (max)
 * 2) 연도별 최동월 도시의 대출합계 구하기
 * 3)   
 * */
with t1 as 
( --연도별 최종월
  select max(period) as max_year
    from kor_loan_status
  group by substr(period,1,4)
)
, t2 as 
( --연도별 최종월 도시별 잔액 
  select t1.max_year, region, sum(loan_jan_amt) as sum_loan 
    from kor_loan_status aa, t1
   where aa.period = t1.max_year
  group by max_year, region
)
select  *
from t2 
where (max_year,sum_loan) IN (select max_year, max(sum_loan) from t2 group by max_year)
order by 1
; 
 201112   서울     334728.3
 201212   서울     331572.3
 201311   서울     334062.7

-----------------------------------
--[책에 있는 쿼리]
 201112 서울     334728.3
 201212 서울     331572.3
 201311 서울     334062.7

with b2 as (select period, region, sum(loan_jan_amt) jan_amt
 			from kor_loan_status
 			group by period, region
		   ),
	 c as (select b2.period, max(b2.jan_amt) max_jan_amt
	 	   from b2, (select max(period) max_month
	 	   			 from kor_loan_status
	 	   			 group by substr(period,1,4)
	 	   			 )a
	 	   where b2.period = a.max_month
	 	   group by b2.period
		  )
select b2.*
from b2, c
where b2.period = c.period
and b2.jan_amt = c.max_jan_amt
order by 1;