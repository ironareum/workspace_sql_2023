/*
 * 1. 계층형 쿼리
 * 2. WITH절
 * 3. 분석함수와 window 함수
 * 4. 다중테이블 INSERT 
 */

/****************** 
 ## 1. 계층형 쿼리 ##
 ******************/

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
/* 24.5.29 복습 Start */
with T_empList as ( 
	select * from employees
	where rownum <= 3
)
--로우를 컬럼으로 변환
, T_toCol as ( 
	select LISTAGG(EMP_NAME, ', ') WITHIN GROUP (order by EMP_NAME) AS row_to_col 
	from T_empList
)
selct * from T_toCol 
;

--컬럼을 로우로 변환 

/**/

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
		--INSTR ( [문자열], [찾을 문자 값], [찾기를 시작할 위치(1,-1)], [찾은 결과의 순번(1...n)] )
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





--## 순환서브쿼리 (like 계층형 쿼리)
/* Recursive WITH절 사용법 : 
 * UNION ALL을 가지고 초기값을 정해주는 초기서브쿼리와 , 
 * 이후에 행위를 작성하는 Recursive 서브 쿼리로 나뉜다. 
 * 단, 항상 재귀함수에서 그래듯이 무한루프에 빠지지않도록 종료조건을 조건절로 표현해야함!★
 * */
/*----------[Recursive WITH절 사용법] START------------*/
WITH CONTINUOUS(NUM, RESULT) AS(
    SELECT 1,1 FROM DUAL --초기값을 정해주는 서브쿼리 
    UNION ALL
    SELECT --이후에 행위를 작성하는 Recursive 서브쿼리 
          NUM+1, (NUM+1)+RESULT
    FROM CONTINUOUS
    WHERE NUM < 9 --무한루프에 빠지지않도록 하는 조건절! 
)
SELECT
    NUM
    ,RESULT
FROM CONTINUOUS;
/*----------[Recursive WITH절 사용법] E N D------------*/

select * from departments order by parent_id;
--1) 계층형 쿼리란
select parent_id, department_id, LPAD(' ', 3*(LEVEL-1))||department_name, LEVEL 
from departments
start with parent_id is null
connect by prior department_id = parent_id;

--2) with절을 사용해 위 계층형 쿼리와 동일한 결과를 뽑아낼수있다.
with recur(parent_id, department_id, department_name, lvl)
	 as ( select parent_id, department_id, department_name, 1 as lvl  --초기값 서브쿼리 
	 		from departments
	 	   where parent_id is null --> start with parent_id is null 과 같음
	 	   union all 
	 	  select a.parent_id, a.department_id, a.department_name, b.lvl +1
	 	  	from departments a, recur b
	 	   where a.parent_id = b.department_id --> connect by prior department_id = parent_id와 같음
	 	)
select parent_id, department_id, LPAD(' ', 3*(lvl-1)) || department_name as department_name, lvl
from recur; 

--3) recursive with절에서 order by 사용하기 
/* 계층형 쿼리에서는 자동으로 레벨에 따라 계층별로 조회되었지만, 
 * 순환서브쿼리에서는 단순히 레벨순으로만 조회되므로 
 * order siblings by 절과 같은 기능이 필요함! ---> SEARCH 구문 사용하기!!  
 * 
 * [SEARCH 구문 용법]
 *  -DEPTH FITST BY   : 같은 노드에 있는 로우, 즉 형제(siblings) row 보다 자식 row가 먼저 조회됨.
 *  -BREADTH FIRST BY : 자식로우보다 형제로우가 먼저 조회됨.
 *  -같은 레벨에 있는 형제로우일때는 BY 다음에 명시한 컬럼 순으로 조회됨. 
 *  -SET 다음에는 가상 컬럼 형태로 최종 SELECT 절에서 사용할 수 있다.
 */
with recur(parent_id, department_id, department_name, lvl)
	 as ( select parent_id, department_id, department_name, 1 as lvl  --초기값 서브쿼리 
	 		from departments
	 	   where parent_id is null --> start with parent_id is null 과 같음
	 	   union all 
	 	  select a.parent_id, a.department_id, a.department_name, b.lvl +1
	 	  	from departments a, recur b
	 	   where a.parent_id = b.department_id --> connect by prior department_id = parent_id와 같음
	 	)
	 	/* order by와 같음 */
	 	SEARCH DEPTH FIRST BY department_id SET order_seq -->자식로우 먼저 조회, 같은 레벨에서는 department_id순으로, order_seq 은 가상컬럼형태로 최종 select 절에서만 사용할수있음. 	 		
--select * from recur; 
--최종 조회 쿼리
select parent_id, department_id, LPAD(' ', 3*(lvl-1)) || department_name as department_name, lvl, order_seq 
from recur; 


--4) 
with recur(parent_id, department_id, department_name, lvl)
	 as ( select parent_id, department_id, department_name, 1 as lvl  --초기값 서브쿼리 
	 		from departments
	 	   where parent_id is null --> start with parent_id is null 과 같음
	 	   union all 
	 	  select a.parent_id, a.department_id, a.department_name, b.lvl +1
	 	  	from departments a, recur b
	 	   where a.parent_id = b.department_id --> connect by prior department_id = parent_id와 같음
	 	)
	 	/* order by와 같음 */
	 	SEARCH BREADTH FIRST BY parent_id SET order_seq -->형제로우 먼저 조회, 같은 레벨에서는 parents_id순으로, order_seq 은 가상컬럼형태로 최종 select 절에서만 사용할수있음. 	 		
--최종 조회 쿼리
select parent_id, department_id, LPAD(' ', 3*(lvl-1)) || department_name as  department_name, lvl, order_seq 
from recur; 


--/////////////////////// s
--## WITH절 다시 공부하기 (2024.10.20)
--요건1) kor_loan_status 테이블에서, 연도별 최종월 기준 가장 대출이 많은 도시와 잔액 구하기 

select * from kor_loan_status ;

--연도별 최종월 구하기
/*
201112
201212
201311*/
select max(period) from kor_loan_status
group by substr(PERIOD,1,4) 
order by substr(PERIOD,1,4)
;

--최종년월별 가장 대출이 많은 잔액 구하기
select PERIOD, max(LOAN_JAN_AMT) from kor_loan_status 
where period in (select max(period) from kor_loan_status
                  group by substr(PERIOD,1,4))
group by period 
;


--최종년월별 가장 대출이 많은 도시와 잔액 구하기
select a.* from KOR_LOAN_STATUS a 
              , (select PERIOD, max(LOAN_JAN_AMT) max_jan 
                   from kor_loan_status 
                  where period in (select max(period) --년도별 최종월 
                                     from kor_loan_status
                                    group by substr(PERIOD,1,4))
                  group by period ) b
where A.PERIOD = B.PERIOD
  and A.LOAN_JAN_AMT = b.max_jan 
;

--검증
select * from KOR_LOAN_STATUS
where loan_jan_amt in (204275.7, 203344.9, 205644.3)
;
--////////////////////////// e



/****************************** 
 ## 2. 분석함수와 window 함수 ##
 ******************************/

/* 분석함수 */
/* 분석함수란 테이블에 있는 로우에 대해 특정 그룹별로 집계 값을 산출할때 사용.
 * 집계값을 구할때 보통은 그룹쿼리를 사용하는데, 이때 GROUP BY 절에 의해 최종쿼리 결과는 그룹별로 로우수가 줄어든다. 
 * 이에반해, 집계함수를 사용하면 로우의 손실없이도 그룹별 집계값을 산출해 낼 수 있다.
 * 
 * 분석함수에서 사용하는 로우별 그룹을 ★윈도우(window)라고 부르는데, 이는 집계 값 계산을 위한 로우의 범위를 결정하는 역할★을 한다.   
 * 
 * [분석함수 구문]
 *  분석함수(매개변수) OVER
 *  (PARTITION BY expr1, expr2, ...
 *       ORDER BY expr3, expr4...
 *    window 절)
 * */

--분석함수 : 분석함수 역시 특정 그룹별 집계를 담당하므로 집계함수에 속한다. 
--1. ROW_NUMBER()
--요건: 사원 텡비르에서 부서별 사원들의 로우수를 출력하기
select A.DEPARTMENT_ID
      ,A.EMP_NAME 
      ,ROW_NUMBER() over(partition by department_id order by DEPARTMENT_ID, A.EMP_NAME) RN
  from employees a
;

--RANK, DENSE_RANK
--RANK: 순서별로 중복있으면 건너뛰고 순서매김
--DENSE_RANK 중복있어도 쭉이어서 순서매김

--부서별로 급여순위를 매겨보자
select DEPARTMENT_ID, emp_name, SALARY
     , rank() over(partition by department_id order by salary) RN 
 from EMPLOYEES
where department_id = '50'
;

select DEPARTMENT_ID, emp_name, SALARY
     , dense_rank() over(partition by department_id order by salary) RN 
 from EMPLOYEES
where department_id = '50'
;

--각 부서별로 급여가 상위 3위까지인 사원 추출
select department_id, salary, sal_rank, emp_name from (
    select DEPARTMENT_ID, emp_name, SALARY
         , rank() over(partition by department_id order by salary desc) sal_rank 
     from EMPLOYEES
) where sal_rank <= 3
order by department_id, sal_rank 
;



--##CUME_DIST, PERCENT_RANK
--CUME_DIST : 주어진 그룹안에서 상대적인 분포도값 반환 (0초과 1이하)

--부서별 급여에 따른 "누적"분포도값을 구해보자
select department_id, emp_name, salary
      ,CUME_DIST() over(partition by DEPARTMENT_ID order by salary) dep_dist
from EMPLOYEES ;

--PERCENT_RANK : 해당그룹 내의 백분위 순위 (0이상 1이하) 
--*백분위 순위란: 그룹 안에서 해당 로우의 값도가 작은값의 비율.
select department_id, emp_name, salary
      ,dense_rank() over(partition by department_id order by salary) sal_rank 
      ,CUME_DIST() over(partition by DEPARTMENT_ID order by salary) dep_dist
      ,PERCENT_RANK() over(partition by DEPARTMENT_ID order by salary) percentile
from EMPLOYEES 
where department_id = '60' 
;

--## NTILE(expr) : expr안에 명시된 값만큼 분할한 결과를 반환 
--e.g 1) 한그룹의 row가 5일때: NTILE(5): 1에서 5까지 숫자를 반환(1,2,3,4,5)
--e.g 2) 한그룹의 row가 5일때: NTILE(4): 1에서 5까지 숫자를 반환(12,3,4,5)
select department_id, emp_name, salary
     , NTILE(4) over(partition by department_id order by salary) NTILES 
from EMPLOYEES
where department_ID IN (30,60)
;

--## LAG(expr, offset, default_value) | LEAD(expr, offset, default_value)
--LAG  : 선행로우 참조
--LEAD : 후행로우 참조 

