/****************************
 * 2. �������ΰ� �ܺ�����
 ****************************/
--#�������� (where�� ��ȣ(=)������ ���, pk�÷� ���)
select a.employee_id
     , a.emp_name
     , a.department_id
     , B.DEPARTMENT_ID
     --, a.DEPARTMENT_ID
from EMPLOYEES a
   , DEPARTMENTS b
where A.DEPARTMENT_ID = B.DEPARTMENT_ID ; ----> null�� ���ܵ�  
										/*������̺� �μ���ȣ�� �ִ°Ǹ� ����� 
                                        (������̺��� ��ü�Ǽ�: 107, �μ���ȣ ���� ���: 1�� ����)
                                        ��, 106�Ǹ� �����
                                        */
                                        
select a.employee_id
     , a.emp_name
     , a.department_id
     --, B.DEPARTMENT_ID
     , a.DEPARTMENT_ID
from EMPLOYEES a
    , DEPARTMENTS b
where A.DEPARTMENT_ID = B.DEPARTMENT_ID(+) --������̺� null �����ؼ� ��ȸ�� 
;

select * from EMPLOYEES where EMPLOYEE_id = '178' ;



-------------------------------------------------------------------------------------------------
--#�������� (�������� ����ؼ� ���������� �����ϴ� �����͸� ������������ ����, IN/EXISTS ���)
--�������� ���̺� A, �������� ���̺� B => B���̺� �����ϴ� A���̺��� �����͸� ����
--!!! ���������� ���� ����Ʈ : ���������� �����ϴ� �������� �����Ͱ� ������ �����ϴ��� ���� ��ȯ�Ǵ� �������������Ϳ��� �ߺ��� ���ٴ����� �Ϲ����ΰ��� �������̴�.  

--1) exists (�������� ������ �ߺ�����)
select A.DEPARTMENT_ID, A.DEPARTMENT_NAME
  from DEPARTMENTS a
 where EXISTS (select 1 
 				 from EMPLOYEES b
                where a.department_id = b.department_id --��������
                  and b.salary > 3000)
;              
--2) in (�������� ������ �ߺ�����)
select department_id, department_name
  from DEPARTMENTS a
 where A.DEPARTMENT_ID in (select B.DEPARTMENT_ID 
                             from employees b
                            where B.SALARY > 3000 ) --�������� ���� 
;  
--���� ������ �Ϲ��������� �ϸ� ����Ǽ��� �ξ� ���� (�ߺ��� �߻�)
select A.DEPARTMENT_ID, A.DEPARTMENT_NAME
  from DEPARTMENTS a 
     , EMPLOYEES b
 where a.department_id = b.department_id --��������
   and b.salary > 3000       
;


--��ȸ
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
--#��Ƽ����
--���������� b ���̺��� ���� �������� a ���̺��� �����͸� ���� (���� ���̺��� �ִ� ������ ����)
--NOT IN / NOT EXISTS ���

--1) NOT IN ��� : 106�� ��ȸ ===> a.department_id �� null�̸�, not in���� �������� false�� �Ǿ� ���ܵ�. null �� in/not in���� �񱳵����ʰ� is null/is not null�� ��ߵ�!!! 
--��, is not null ������ �� ���� �߰�������! �ڡڡ�
select A.EMPLOYEE_ID, A.EMP_NAME, A.DEPARTMENT_ID--, B.DEPARTMENT_NAME
from EMPLOYEES a--, DEPARTMENTS b
where 1=1 --A.DEPARTMENT_ID = B.DEPARTMENT_ID
  and a.department_id not in (select department_id
                              from departments
                              where manager_id is null) 
order by A.DEPARTMENT_ID,A.EMPLOYEE_ID
;
--�μ��ڵ� ���´�� Ȯ�� 
select * from Employees where department_id is null ; --178


--in/exists count Ȯ��
--106 --> null�� IN���� �񱳰� �����ʰ�, IS NULL�� �� �ؾ��ϱ� ����.
--�ڻ�����̺��� department_id ���� null �̸�, not in���� �������� false�� ��.
select distinct department_id --count(*) 
from employees
where department_id not in (select department_id
                              from departments
                              where manager_id is null)
order by department_id desc
;


--107 --null�� ����!
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
                  where c.manager_id is null) --�����������ʼ�!!!
;


select count(*) 
from EMPLOYEES a
where not exists (select 1--department_id
                  from departments c
                  where a.department_id = c.department_id --�����������ʼ�!!!
                    and c.manager_id is null) 
;



-------------------------------------------------------------------------------------------------
--##��������:������ ���̺� ����Ͽ� ����.
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
--##�ܺ�����(OUTER JOIN) :�Ϲ������� Ȯ�尳��. �������ǿ� �����ϴ� ������ �Ӹ� �ƴ϶�, ��� �������̺� �������ǿ� ��õ� �÷��� ���� ���ų�(null) �ش� �ο찡 �ƿ� ������� �����͸� ��� �����Ѵ�. 
select * from job_history 
;
--1) �Ϲ����� 
select a.department_id, a.department_name, b.job_id, b.department_id 
  from departments a
	 , job_history b
where a.department_id = b.department_id 
;

--2) �ܺ����� 
select a.department_id, a.department_name, b.job_id, b.department_id 
  from departments a
	 , job_history b
where a.department_id = b.department_id (+)
;


-------------------------------------------------------------------------------------------------
--##īŸ�þ� ����(CATASIAN PRODUCT): where���� ���������� ���� ������ ����. (����� �� ���̺� �Ǽ��� ��)

-------------------------------------------------------------------------------------------------


/****************************
 * 3. ANSI ����
 ****************************/
--ANSI ������ �������� ������ WHERE���� �ƴ� FROM ���� ���ٴ� ��. 








/****************************
 * 4. �������� 
 ****************************/
--���������� SQL���� �ȿ��� ������ ���Ǵ� �Ǵٸ� select���� �ǹ�. 
/* 
 * 1) select, from, where, insert, update, merge, delete������ ��밡��. 
 * 2) Ư���� ���¿� ���� ���� 
 *    - ������������ �������� ���� : ������ ����(noncorrelated) �������� vs �������ִ� ����
 *    - ���¿� ���� : �Ϲݼ�������(select��), �ζ��� ��(from ��), ��ø����(where��)  
 */
--# ������ ���� ��������
select count(*) from employees
where salary >= (select avg(salary) from employees)
;

select count(*)
from employees
where department_id in (select department_id --10 (1��)
						from departments
						where parent_id is null
						)
;

select employee_id, emp_name, job_id --2�� 
from employees 
where (employee_id, job_id) in (select employee_id, job_id 
								from job_history )
;
--����
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
								

-- update�������� ��� 
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

--# �������� �ִ� ���� ���� 
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
--# update, merge, delete ���� ����ϴ� ���̽� 
--�μ��� ��� �޿� ��ȸ 
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
				 from --�����μ��� 90�� ���� �μ��� �μ��� ���� ��ձݾ� 
					(select b.department_id, avg(c.salary) as sal 
					 from departments b, employees c
					 where b.parent_id = 90 --�����μ� 90
					   and b.department_id = c.department_id
					 group by b.department_id
					) d
				 where a.department_id = d.department_id 
				 )
where a.department_id in (select department_id from departments
						  where parent_id = 90)
;
--������Ʈ �� ��� �Ǽ� Ȯ�� :14�� 
select * from employees a 
where a.department_id in (select department_id from departments
						  where parent_id = 90) 
;
rollback

--���� update���� merge ������ ��ȯ(�ξ� ���!)
MERGE INTO employees a
using (select b.department_id, avg(c.salary) as sal 
		 from departments b, employees c
		 where b.parent_id = 90 --�����μ� 90
		   and b.department_id = c.department_id
		 group by b.department_id ) d
on (a.department_id = d.department_id)
when matched then 
update set a.salary = d.sal;


-------------------------------------------------------------------------------------------------
--## �ζ��� �� : from ���� ����ϴ� ���� (from���� ���������� �����, �ϳ��� ���̺��̳� �� ó�� ��� = �ζ��� ��)
select a.employee_id, a.emp_name, b.department_id, b.department_name
from employees a,
     departments b, 
     (select AVG(c.salary) AS avg_salary
      from departments b, employees c
      where b.parent_id = 90 --��ȹ��  
      and b.department_id = c.department_id ) d
where a.department_id = b.department_id
and a.salary > d.avg_salary 
; 
     
--�� �ٸ� �� 
select * from sales 
;
select a.* , b.*
from 
	(select a.sales_month, round(avg(a.amount_sold)) as month_avg --����� �Ǹŷ� 
	 from sales a, 
		customers b,
		countries c
	 where a.sales_month between '200001' and '200012'
	   and a.cust_id = b.cust_id
	   and b.country_id = c.country_id
	   and c.country_name = 'Italy'
	 group by a.sales_month
	) a, 
	( select round(avg(a.amount_sold)) as year_avg --����� �����  
	  from sales a, 
	  	   customers b, 
	  	   countries c 
	  where a.sales_month between '200001' and '200012'
	    and a.cust_id = b.cust_id
	    and b.country_id = c.country_id
	    and c.country_name = 'Italy'
	) b
where a.month_avg > b.year_avg --����� ����� ���� ���� �� ����� 
;




/* ������ ������ �ۼ��ؾ��Ҷ� ��� �ؾ��ұ�? ---> devide & conquer!(�����ؼ� �����϶�) 
 * 1) ���������� ��ȸ�Ǵ� ����׸��� �����Ѵ�
 * 2) �ʿ��� ���̺�� �÷��� �ľ��Ѵ�
 * 3) ���������� �����ؼ� ������ �ۼ��Ѵ�
 * 4) ������ ������ ������ �ϳ��� ���� ��������� �����Ѵ�
 * 5) ����� �����Ѵ�
 * */

--e.g) �������� ��Ż���� ���� �����͸� ���� ��������� ���� ���� ����� ��ϰ� ������� ���ϴ� ������ �ۼ��غ��� 
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

--������ �ִ�/�ּ� ���� ���ϱ�
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
	,(--������ �ִ�/�ּ� ���� 
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