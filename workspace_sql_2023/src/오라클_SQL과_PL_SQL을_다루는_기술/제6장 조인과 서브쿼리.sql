/****************************
 * 2. 내부조인과 외부조인
 ****************************/
--#동등조인 (where절 등호(=)연산자 사용, pk컬럼 사용)
select a.employee_id
     , a.emp_name
     , a.department_id
     , B.DEPARTMENT_ID
     --, a.DEPARTMENT_ID
from EMPLOYEES a
   , DEPARTMENTS b
where A.DEPARTMENT_ID = B.DEPARTMENT_ID ; ----> null은 제외됨  
										/*사원테이블에 부서번호가 있는건만 추출됨 
                                        (사원테이블의 전체건수: 107, 부서번호 없는 사원: 1건 존재)
                                        즉, 106건만 추출됨
                                        */
                                        
select a.employee_id
     , a.emp_name
     , a.department_id
     --, B.DEPARTMENT_ID
     , a.DEPARTMENT_ID
from EMPLOYEES a
    , DEPARTMENTS b
where A.DEPARTMENT_ID = B.DEPARTMENT_ID(+) --사원테이블에 null 포함해서 조회됨 
;

select * from EMPLOYEES where EMPLOYEE_id = '178' ;



-------------------------------------------------------------------------------------------------
--#세미조인 (서브쿼리 사용해서 서브쿼리에 존재하는 데이터만 메인쿼리에서 추출, IN/EXISTS 사용)
--메인쿼리 테이블 A, 서브쿼리 테이블 B => B테이블에 존재하는 A테이블의 데이터를 추출
--!!! 세미조인의 가장 포인트 : 서브쿼리에 존재하는 메인쿼리 데이터가 여러건 존재하더라도 최종 반환되는 메인쿼리데이터에는 중복이 없다는점이 일반조인과의 차이점이다.  

--1) exists (메인쿼리 데이터 중복없음)
select A.DEPARTMENT_ID, A.DEPARTMENT_NAME
  from DEPARTMENTS a
 where EXISTS (select 1 
 				 from EMPLOYEES b
                where a.department_id = b.department_id --조인조건
                  and b.salary > 3000)
;              
--2) in (메인쿼리 데이터 중복없음)
select department_id, department_name
  from DEPARTMENTS a
 where A.DEPARTMENT_ID in (select B.DEPARTMENT_ID 
                             from employees b
                            where B.SALARY > 3000 ) --조인조건 없음 
;  
--위의 쿼리를 일반조인으로 하면 결과건수가 훨씬 많음 (중복건 발생)
select A.DEPARTMENT_ID, A.DEPARTMENT_NAME
  from DEPARTMENTS a 
     , EMPLOYEES b
 where a.department_id = b.department_id --조인조건
   and b.salary > 3000       
;


--조회
select department_id, manager_id  
  from departments b
--where b.manager_id is not null
;    

select distinct department_id, max(manager_id)
  from employees
group by department_id
order by department_id
;



-------------------------------------------------------------------------------------------------
--#안티조인
--서브쿼리의 b 테이블에는 없는 메인쿼리 a 테이블의 데이터만 추출 (한쪽 테이블에만 있는 데이터 추출)
--NOT IN / NOT EXISTS 사용

--1) NOT IN 사용 : 106건 조회 ===> a.department_id 가 null이면, not in과의 연산결과가 false가 되어 제외됨. null 은 in/not in으로 비교되지않고 is null/is not null을 써야됨!!! 
--즉, is not null 조건을 꼭 같이 추가해주자! ★★★
select A.EMPLOYEE_ID, A.EMP_NAME, A.DEPARTMENT_ID--, B.DEPARTMENT_NAME
from EMPLOYEES a--, DEPARTMENTS b
where 1=1 --A.DEPARTMENT_ID = B.DEPARTMENT_ID
  and a.department_id not in (select department_id
                              from departments
                              where manager_id is null) 
order by A.DEPARTMENT_ID,A.EMPLOYEE_ID
;
--부서코드 없는대상 확인 
select * from Employees where department_id is null ; --178


--in/exists count 확인
--106 --> null은 IN으로 비교가 되지않고, IS NULL로 비교 해야하기 때문.
--★사원테이블의 department_id 값이 null 이면, not in과의 연산결과가 false과 됨.
select distinct department_id --count(*) 
from employees
where department_id not in (select department_id
                              from departments
                              where manager_id is null)
order by department_id desc
;


--107 --null도 포함!
select distinct a.department_id --count(*) 
from employees a
where not exists (select 1 
                  from departments b
                  where b.department_id = a.department_id
                    and b.manager_id is null)
order by department_id desc
;

--not exists
select A.EMPLOYEE_ID, A.EMP_NAME, A.DEPARTMENT_ID--, B.DEPARTMENT_NAME
from EMPLOYEES a--, DEPARTMENTS b
where 1=1--A.DEPARTMENT_ID = B.DEPARTMENT_ID
  and not exists (select c.department_id
                  from departments c
                  where c.manager_id is null) --★조인조건필수!!!
;


select count(*) 
from EMPLOYEES a
where not exists (select 1--department_id
                  from departments c
                  where a.department_id = c.department_id --★조인조건필수!!!
                    and c.manager_id is null) 
;



-------------------------------------------------------------------------------------------------
--##셀프조인:동일한 테이블 사용하여 조인.
select a.employee_id, a.emp_name, b.employee_id, b.emp_name, a.department_id
  from employees a,
       employees b
where 1=1--a.employee_id < b.employee_id
  and A.DEPARTMENT_ID = B.DEPARTMENT_ID
  and A.DEPARTMENT_ID = 20
  order by A.EMPLOYEE_ID
  ;

select department_id, employee_id
  from EMPLOYEES
 where DEPARTMENT_ID = 20
order by department_id;


-------------------------------------------------------------------------------------------------
--##외부조인(OUTER JOIN) :일반조인의 확장개념. 조인조건에 만족하는 데이터 뿐만 아니라, 어느 한쪽테이블에 조인조건에 명시된 컬럼에 값이 없거나(null) 해당 로우가 아예 없더라고 데이터를 모두 추출한다. 
select * from job_history 
;
--1) 일반조인 
select a.department_id, a.department_name, b.job_id, b.department_id 
  from departments a
	 , job_history b
where a.department_id = b.department_id 
;

--2) 외부조인 
select a.department_id, a.department_name, b.job_id, b.department_id 
  from departments a
	 , job_history b
where a.department_id = b.department_id (+)
;


-------------------------------------------------------------------------------------------------
--##카타시안 조인(CATASIAN PRODUCT): where절에 조인조건이 없는 조인을 말함. (결과는 두 테이블 건수의 곱)

-------------------------------------------------------------------------------------------------


/****************************
 * 3. ANSI 조인
 ****************************/
--ANSI 조인의 차이점은 조건이 WHERE절이 아닌 FROM 절에 들어간다는 것. 








/****************************
 * 4. 서브쿼리 
 ****************************/
--서브쿼리란 SQL문장 안에서 보조로 사용되는 또다른 select문을 의미. 
/* 
 * 1) select, from, where, insert, update, merge, delete문에서 사용가능. 
 * 2) 특성과 형태에 따라 구분 
 *    - 메인쿼리와의 연관성에 따라 : 연관성 없는(noncorrelated) 서브쿼리 vs 연관성있는 쿼리
 *    - 형태에 따라 : 일반서브쿼리(select절), 인라인 뷰(from 절), 중첩쿼리(where절)  
 */
--# 연관성 없는 서브쿼리
select count(*) from employees
where salary >= (select avg(salary) from employees)
;

select count(*)
from employees
where department_id in (select department_id --10 (1건)
						from departments
						where parent_id is null
						)
;

select employee_id, emp_name, job_id --2건 
from employees 
where (employee_id, job_id) in (select employee_id, job_id 
								from job_history )
;
--검증
select employee_id, emp_name, job_id 
from employees 
where employee_id in ('101',
					'101',
					'102',
					'114',
					'122',
					'176',
					'176',
					'200',
					'200',
					'201'
					)
;
								

-- update문에서의 사용 
update employees
set salary = (select avg(salary) from employees)
; 
rollback; 

delete employees
where salary >= (select avg(salary) from employees )
;

/*
 * insert into ora_user.employees
	(EMPLOYEE_ID
	 ,EMP_NAME
	 ,EMAIL
	 ,PHONE_NUMBER
	 ,HIRE_DATE
	 ,SALARY
	 ,MANAGER_ID
	 ,COMMISSION_PCT
	 ,RETIRE_DATE
	 ,DEPARTMENT_ID
	 ,JOB_ID
	 ,CREATE_DATE
	 ,UPDATE_DATE )
select 
	EMPLOYEE_ID
	,FIRST_NAME||' '||LAST_NAME
	,EMAIL
	,PHONE_NUMBER
	,HIRE_DATE
	,SALARY
	,MANAGER_ID
	,COMMISSION_PCT
	,''
	,DEPARTMENT_ID
	,JOB_ID 
	,SYSDATE
	,SYSDATE
from hr.employees
;
 * */
select * from employees
;

--# 연관성이 있는 서브 쿼리 
select a.department_id, a.department_name 
from departments a
where EXISTS (select 1 
			  from job_history b
			  where a.department_id = b.department_id ) 
;

select a.employee_id,
	(select b.emp_name from employees b where a.employee_id = b.employee_id) as emp_name ,
	a.department_id ,
	(select b.department_name from departments b where a.department_id = b.department_id) as dep_name 
from job_history a
;



-------------------------------------------------------------------------------------------------
--# update, merge, delete 에서 사용하는 케이스 
--부서별 평균 급여 조회 
select department_id, avg(salary) as sal 
from employees a
where department_id in (select department_id from departments where parent_id = 90)
group by department_id 
;
/*          60                                      5760
            70                                     10000
           100 8601.333333333333333333333333333333333333
           110                                     10154 */


update employees a
set a.salary = ( select sal  
				 from --상위부서가 90인 하위 부서의 부서별 직원 평균금액 
					(select b.department_id, avg(c.salary) as sal 
					 from departments b, employees c
					 where b.parent_id = 90 --상위부서 90
					   and b.department_id = c.department_id
					 group by b.department_id
					) d
				 where a.department_id = d.department_id 
				 )
where a.department_id in (select department_id from departments
						  where parent_id = 90)
;
--업데이트 될 대상 건수 확인 :14건 
select * from employees a 
where a.department_id in (select department_id from departments
						  where parent_id = 90) 
;
rollback

--위의 update문을 merge 문으로 변환(훨씬 깔끔!)
MERGE INTO employees a
using (select b.department_id, avg(c.salary) as sal 
		 from departments b, employees c
		 where b.parent_id = 90 --상위부서 90
		   and b.department_id = c.department_id
		 group by b.department_id ) d
on (a.department_id = d.department_id)
when matched then 
update set a.salary = d.sal;


-------------------------------------------------------------------------------------------------
--## 인라인 뷰 : from 절에 사용하는 쿼리 (from절에 서브쿼리를 사용해, 하나의 테이블이나 뷰 처럼 사용 = 인라인 뷰)
select a.employee_id, a.emp_name, b.department_id, b.department_name
from employees a,
     departments b, 
     (select AVG(c.salary) AS avg_salary
      from departments b, employees c
      where b.parent_id = 90 --기획부  
      and b.department_id = c.department_id ) d
where a.department_id = b.department_id
and a.salary > d.avg_salary 
; 
     
--또 다른 예 
select * from sales 
;
select a.* , b.*
from 
	(select a.sales_month, round(avg(a.amount_sold)) as month_avg --월평균 판매량 
	 from sales a, 
		customers b,
		countries c
	 where a.sales_month between '200001' and '200012'
	   and a.cust_id = b.cust_id
	   and b.country_id = c.country_id
	   and c.country_name = 'Italy'
	 group by a.sales_month
	) a, 
	( select round(avg(a.amount_sold)) as year_avg --년평균 매출액  
	  from sales a, 
	  	   customers b, 
	  	   countries c 
	  where a.sales_month between '200001' and '200012'
	    and a.cust_id = b.cust_id
	    and b.country_id = c.country_id
	    and c.country_name = 'Italy'
	) b
where a.month_avg > b.year_avg --연평균 매출액 보다 높은 월 매출액 
;




/* 복잡한 쿼리를 작성해야할때 어떻게 해야할까? ---> devide & conquer!(분할해서 정복하라) 
 * 1) 최종적으로 조회되는 결과항목을 정희한다
 * 2) 필요한 테이블과 컬럼을 파악한다
 * 3) 작은단위로 분할해서 쿼리를 작성한다
 * 4) 분할한 단위의 쿼리를 하나로 합쳐 최종결과를 산출한다
 * 5) 결과를 검증한다
 * */

--e.g) 연도별로 이탈리아 매출 데이터를 살펴 매출실적이 가장 많은 사원의 목록과 매출액을 구하는 쿼리를 작성해보자 
select substr(a.sales_month, 1,4) as years
	 , a.employee_id , (select emp_name from employees where employee_id = a.employee_id) as emp_name 
	 , sum(a.amount_sold) as amount_sold 
from sales a
	, customers b
	, countries c	
where a.cust_id = b.cust_id 
  and b.country_id = c.country_id 
  and c.country_name = 'Italy'
group by substr(sales_month, 1,4), a.employee_id 
;

--연도별 최대/최소 매출 구하기
select emp.years, emp.employee_id, emp.emp_name, emp.amount_sold, sale.max  
from (select substr(a.sales_month, 1,4) as years
			 , a.employee_id , (select emp_name from employees where employee_id = a.employee_id) as emp_name 
			 , sum(a.amount_sold) as amount_sold 
		from sales a
			, customers b
			, countries c	
		where a.cust_id = b.cust_id 
		  and b.country_id = c.country_id 
		  and c.country_name = 'Italy'
		group by substr(sales_month, 1,4), a.employee_id 
	 ) emp
	,(--연도별 최대/최소 매출 
		select years, max(amount_sold) as max--, min(amount_sold) as min 
		from (
				select substr(a.sales_month, 1,4) as years
					 , a.employee_id , (select emp_name from employees where employee_id = a.employee_id) as emp_name 
					 , sum(a.amount_sold) as amount_sold 
				from sales a
					, customers b
					, countries c	
				where a.cust_id = b.cust_id 
				  and b.country_id = c.country_id 
				  and c.country_name = 'Italy'
				group by substr(sales_month, 1,4), a.employee_id 		
				) K
		group by years
		order by years
	) sale
where emp.years = sale.years
  and emp.amount_sold = sale.max
order by emp.years
;