--##�������ΰ� �ܺ����� 
--#�������� (where�� ��ȣ(=)������ ���, pk�÷� ���)
select a.employee_id
     , a.emp_name
     , a.department_id
     , B.DEPARTMENT_ID
     --, a.DEPARTMENT_ID
from EMPLOYEES a
    , DEPARTMENTS b
where A.DEPARTMENT_ID = B.DEPARTMENT_ID ; /*������̺� �μ���ȣ�� �ִ°Ǹ� ����� 
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
--#�������� (�������� ����ؼ� ���������� �����ϴ� �����͸� ������������ ����, IN/EXISTS ���)
--�������� ���̺� A, �������� ���̺� B => B���̺� �����ϴ� A���̺��� �����͸� ���� 
--1) exists
select A.DEPARTMENT_ID, A.DEPARTMENT_NAME
from DEPARTMENTS a
where EXISTS (select * from EMPLOYEES b
              where a.department_id = b.department_id --��������
              and b.salary > 3000              
              )
;              
--2) in 
select department_id, department_name
from DEPARTMENTS a
where A.DEPARTMENT_ID in (select B.DEPARTMENT_ID 
                          from employees b
                          where B.SALARY > 3000 --�������� ���� 
                        )
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


--#��Ƽ����
--���������� b ���̺��� ���� �������� a ���̺��� �����͸� ���� (���� ���̺��� �ִ� ������ ����)
--NOT IN / NOT EXISTS ���
select A.EMPLOYEE_ID, A.EMP_NAME, A.DEPARTMENT_ID, B.DEPARTMENT_NAME
from EMPLOYEES a, DEPARTMENTS b
where A.DEPARTMENT_ID = B.DEPARTMENT_ID
  and a.department_id not in (select department_id
                              from departments
                              where manager_id is null) 
order by A.DEPARTMENT_ID,A.EMPLOYEE_ID
;

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


    
--##��������:������ ���̺� ���
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