--##내부조인과 외부조인 
--#동등조인 (where절 등호(=)연산자 사용, pk컬럼 사용)
select a.employee_id
     , a.emp_name
     , a.department_id
     , B.DEPARTMENT_ID
     --, a.DEPARTMENT_ID
from EMPLOYEES a
    , DEPARTMENTS b
where A.DEPARTMENT_ID = B.DEPARTMENT_ID ; /*사원테이블에 부서번호가 있는건만 추출됨 
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
--#세미조인 (서브쿼리 사용해서 서브쿼리에 존재하는 데이터만 메인쿼리에서 추출, IN/EXISTS 사용)
--메인쿼리 테이블 A, 서브쿼리 테이블 B => B테이블에 존재하는 A테이블의 데이터를 추출 
--1) exists
select A.DEPARTMENT_ID, A.DEPARTMENT_NAME
from DEPARTMENTS a
where EXISTS (select * from EMPLOYEES b
              where a.department_id = b.department_id --조인조건
              and b.salary > 3000              
              )
;              
--2) in 
select department_id, department_name
from DEPARTMENTS a
where A.DEPARTMENT_ID in (select B.DEPARTMENT_ID 
                          from employees b
                          where B.SALARY > 3000 --조인조건 없음 
                        )
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


--#안티조인
--서브쿼리의 b 테이블에는 없는 메인쿼리 a 테이블의 데이터만 추출 (한쪽 테이블에만 있는 데이터 추출)
--NOT IN / NOT EXISTS 사용
select A.EMPLOYEE_ID, A.EMP_NAME, A.DEPARTMENT_ID, B.DEPARTMENT_NAME
from EMPLOYEES a, DEPARTMENTS b
where A.DEPARTMENT_ID = B.DEPARTMENT_ID
  and a.department_id not in (select department_id
                              from departments
                              where manager_id is null) 
order by A.DEPARTMENT_ID,A.EMPLOYEE_ID
;

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


    
--##셀프조인:동일한 테이블 사용
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