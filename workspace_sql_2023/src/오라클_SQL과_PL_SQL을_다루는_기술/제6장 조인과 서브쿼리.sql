/****************************
 * 1. �������ΰ� �ܺ�����
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
 * 2. ANSI ����
 ****************************/





