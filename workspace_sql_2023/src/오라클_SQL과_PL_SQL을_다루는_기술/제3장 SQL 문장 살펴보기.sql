--3�� SQL ���� ���캸��
--#01 SELECT ��
SELECT EMPLOYEE_ID, EMP_NAME
FROM EMPLOYEES
WHERE SALARY > 5000;

--#02 INSERT ��
CREATE TABLE ex3_1 (
    col1      VARCHAR2(10),
    col2      NUMBER,
    col3      DATE
); 

--�ٸ� ���̺��̳� ���� ��ȸ ����� ���� �����͸� �� �ٸ����̺�� �ִ� ���� 
CREATE TABLE ex3_2 (
    emp_id      NUMBER,
    emp_name    VARCHAR2(100)    
);
INSERT INTO ex3_2(emp_id, emp_name)
SELECT employee_id, emp_name
FROM employees
WHERE salary > 5000;

--������ ����ȯ
desc ex3_1;


--#03 UPDATE ��
--where ���� �� ã������ �ݵ�� 'IS NULL'�� ã��



--#04 MERGE �� (insert/update)
MERGE INTO /* [��Ű��].���̺�� */
    USING ( /* update�� insert �� ������ ����*/)
    ON (/* update�� ����*/)
WHEN MATCHED THEN
    UPDATE SET /* �÷�1 = ��1, �÷�2 = ��2 ... */
    WHERE /* update ���� */
    --���� �ʿ�� 
    DELETE WHERE /* update_delete ���� */
WHEN NOT MATCHED THEN
    INSERT (/* �÷�1, �÷�2 .. */) VALUES ( /* ��1, ��2 ... */ )
    WHERE  (/* insert ���� */)
;

CREATE TABLE ex3_3 (
    employee_id NUMBER,
    bonus_amt NUMBER DEFAULT 0
);
ALTER TABLE ex3_3 RENAME COLUMN bonums_amt TO bonus_amt;
desc ex3_3;


INSERT INTO ex3_3 (EMPLOYEE_ID)
SELECT e.employee_id
FROM employees e, sales s
WHERE e.employee_id = s.employee_id
    AND s.SALES_MONTH BETWEEN '200010' AND '200012'
GROUP BY E.EMPLOYEE_ID --�����ȣ �ߺ����� 
;
/*
148	0
153	0
154	0
155	0
160	7.5
161	70 --> ������ 
*/
select * from ex3_3 order by employee_id ;
select 7.5+ 7500*0.01 from dual; --82.5

--MERGE
MERGE INTO ex3_3 d
USING (select employee_id, salary, manager_id from employees e where manager_id = '146') e
    ON (d.employee_id = e.employee_id) -- where salary < 8000
WHEN MATCHED THEN 
    UPDATE SET d.bonus_amt = d.bonus_amt + (e.salary * 0.01)
    DELETE WHERE e.employee_id = '161'
WHEN NOT MATCHED THEN 
    INSERT (d.employee_id, d.bonus_amt) 
    VALUES (e.employee_id, (e.salary*0.001)) 
    WHERE (e.salary < 8000)
;

--���Ŵ�� 
select employee_id, manager_id, salary, salary * 0.01
from employees
where employee_id in (select employee_id from ex3_3) 
    and manager_id = '146'
    --and salary < 8000
;
--insert ��� 
select employee_id, manager_id, salary, salary * 0.001
from employees
where employee_id not in (select employee_id from ex3_3) 
    and manager_id = '146'
    and salary < 8000
;

--#05 DELETE 
--Ư�� ��Ƽ���� �����͸� ����
DELETE FROM /*���̺��*/ PARTITION /*��Ƽ�Ǹ�*/
WHERE /*delete ����*/
;
--��Ƽ�Ǹ� ��ȸ
select * from user_tab_partitions
where table_name = 'SALES';


--#06 COMMIT�� ROLLBACK, TRUNCATE
CREATE TABLE ex3_4 (
    employee_id NUMBER
);
INSERT INTO ex3_4 VALUES(100);
select * from ex3_4;
--Ŀ�������� ���缼�ǿ����� ��������. (�͹̳ο��� ��ȸ�� ���ڵ� ����) ��, DB�� �ݿ��� ���°� �ƴ�
COMMIT;
--ROLLBACK;

--TRUNCATE (���̺� ��ü����. �����ؼ� ���!!)
--1)DELETE(DML)���� ������ ���� �� COMMIT�� �����ؾ� �����Ͱ� ������ �����ǰ�, ROLLBACK�� �����ϸ� ������ �����Ͱ� ���͵ȴ�. 
--2)TRUNCATE(DDL)����� �����Ͱ� �ٷ� �����ǰ� ROLLBACK �����ص� ���;ȵ�. ���� WHERE ������ ���ϼ� ����.   
--TRUNCATE TABLE ex3_4
;



--#07 �ǻ��÷�(psudo-column)
--���̺��� �÷�ó�� ���������� ������ ���̺� ��������� �ʴ� �÷�
--SELECT ������ ����Ҽ� ������, �ǻ��÷��� ���� INSERT, UPDATE, DELETE �Ҽ��� ����.
--����1) NEXTVAL, CURRVAL(���������� ����ϴ� �ǻ��÷�)
--����2) CONNECT_BY_IS_CYCLE, CONNECT_BY_ISLEAF, LEVEL (������ �������� ����ϴ� �ǻ��÷�)
--����3) ROWNUM, ROWID 

--ROWNUM : ���̺� �����͸� ������ ���� ����
SELECT ROWNUM, employee_id
FROM employees where rownum <5;

--ROWID : ���̺� ����� �� �ο찡 ����� �ּҰ��� ����Ŵ (�� �ο츦 �ĺ��ϴ� ���̸�, ������ ����)
SELECT ROWNUM, employee_id, ROWID
FROM employees where rownum <5;


--#08 ������(Operator)
--���Ŀ�����: +, -, *, /
--���ڿ�����: ||
--��������: >, <, =, <> ��
--���տ�����: UNION, UNION ALL, INTERSECT, MINUS (5�� ����)
--������ ���� ������: PRIOR, CONNECT_BY_ROOT (7�� ����)


--#09 ǥ���� (�Ѱ� �̻��� ���� ������, SQL�Լ� ���� ���յ� ��)
--CASE
CASE WHEN ����1 THEN ��1
     WHEN ����2 THEN ��2
     ELSE ��Ÿ��
END
;

SELECT employee_id, salary, 
    CASE WHEN salary <= 5000 THEN 'C���'
         WHEN salary > 5000 AND salary <= 15000 THEN 'B���'
         ELSE 'A���'
    END AS salary_grade     
FROM employees;



--#10 ���ǽ� (�Ѱ� �̻��� ǥ���İ� �� �����ڰ� ���յ� ������ TRUE, FALSE, UNKNOWN 3���� Ÿ�� ��ȯ��)
--�����ǽ�: ANY, SOME, ALL
--ANY/SOME = OR (ANY�� =, >, < <>, != � ��밡��) 
--ALL = AND

--�����ǽ�: AND, OR, NOT

--NULL ���ǽ�: IS NULL, IS NOT NULL

--BETWEEN, AND ���ǽ�
--BETWEEN = '>=', '<=' 

--IN= OR
--NOT IN = '<>ALL'

--EXISTS : IN�� ��������� ���� �������� ���������� �ü��ְ� �������� ������ ���������� �־���� (6�� ����)

--LIKE (�������� ��ȸ. ��ҹ��� ����)
--_ (�ѱ��ڸ� ��)



--==================================================
--Self-Check
;
--1. �ٸ� ���̺��� �����ͷ� ���̺� ���� 
desc employees;
CREATE TABLE ex3_6 as 
    select employee_id, emp_name, salary, manager_id
    from employees 
    where manager_id = '124'
        and salary BETWEEN 2000 AND 3000
;

--2
DELETE ex3_3;

INSERT INTO ex3_3 (employee_id)
select e.employee_id
from employees e, sales s
where e.employee_id = s.employee_id
and s.sales_month BETWEEN '200010' and '200012'
group by e.employee_id;
commit;
desc ex3_3;

MERGE INTO ex3_3 d
USING (select employee_id, salary, manager_id from employees where manager_id = '145') e
    ON (d.employee_id = e.employee_id)
WHEN MATCHED THEN 
    UPDATE SET d.bonus_amt = d.bonus_amt + (e.salary * 0.01)
WHEN NOT MATCHED THEN 
    INSERT (d.employee_id, d.bonus_amt) VALUES(e.employee_id, e.salary*0.005)
;    

--3. ���� ����
select employee_id, emp_name 
from employees
where commission_pct is null;

--4. �������ڷ� ��ȯ
--�������� ����
SELECT employee_id, salary
from employees
where salary BETWEEN 2000 AND 2500
ORDER BY employee_id;
--��ȯ�ϱ�
SELECT employee_id, salary
from employees
where salary >= 2000 AND salary <= 2500
ORDER BY employee_id;


--5. ANY, ALL ���
SELECT employee_id, salary
from employees
where salary IN (2000, 3000, 4000)
ORDER BY employee_id;

SELECT employee_id, salary
FROM employees
WHERE salary NOT IN (2000, 3000, 4000)
ORDER BY employee_id;

--��ȯ�ϱ� 
SELECT employee_id, salary
from employees
where salary = ANY (2000, 3000, 4000)
ORDER BY employee_id;

SELECT employee_id, salary
FROM employees
WHERE salary <> ALL (2000, 3000, 4000)
ORDER BY employee_id;


--���غ��� 
select a.*, b.* 
from 
(
    SELECT employee_id, salary
    from employees
    where salary IN (2000, 3000, 4000)
    ORDER BY employee_id
    ) a
, (
    SELECT employee_id, salary
    from employees
    where salary = ANY (2000, 3000, 4000)
    ORDER BY employee_id
    ) b
where a.employee_id = b.employee_id(+)
and a.salary <> b.salary
;


