/*
 * 1. ������ ����
 * 2. WITH��
 * 3. �м��Լ��� window �Լ�
 * 4. �������̺� INSERT 
 */

--## 1. ������ ����
/* ������������, 2���� ������ ���̺� ����� �����͸� ������ ������ ����� ��ȯ�ϴ� ������ ���Ѵ�. (=���ϼ��������� ����) 
 * 
 * �������� ���� : SELECT expr1, expr2 ..
 *          FROM ���̺�
 *         WHERE ����
 *        START WITH [�ֻ�������] --������ �������� �ֻ��� ������ �ο츦 �ĺ��ϴ� ������ ���. 
 *        CONNECT BY [NOCYCLE][PRIOR ������ ���� ����]  --������������ ������� ����Ǵ����� ����ϴ� �κ� (�μ����̺��� parent_id�� �����μ������� ������ �ִµ� �̸� ǥ���Ϸ��� connect by prior department_id = parent_id; �� ����ؾ���.
 * 
 * LPAD ���� : LPAD(��, �ѹ��ڱ���, ä����) --������ ���̸�ŭ ���ʺ��� ä���ڷ� ä���. (ä��ڸ� �������� ������ �������� �ش���̸�ŭ ä��)
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

--# ������� �������� ����
select a.employee_id, LPAD(' ', 3*(LEVEL-1)) || a.emp_name, LEVEL, a.department_id, b.department_name , a.manager_id
from employees a,
     departments b
where a.department_id = b.department_id
--add condition 
--  and a.department_id = '30' --�ֻ��� �ο� ���ܵ�.
START WITH a.manager_id is null 
CONNECT BY prior a.employee_id = a.manager_id
--add condition 
  and a.department_id = '30' --�ڽ� �ο��� ���� 
;

select * from employees a
where a.manager_id is null 
;

------- ������ ���� ��ȭ�н� --------
--# 1. ������ ���� ���� 
--������ ������ ������ ������ �¼� ������� ��µǴµ� ORDER BY ���� �� ������ ������ �� �ִ�. 
select department_id, LPAD(' >', 3*(LEVEL-1)) || department_name , LEVEL
from departments
START WITH parent_id is null
CONNECT BY prior department_id = parent_id
--ORDER BY department_name --ORDER BY�� ���� ���������� ��������..
ORDER SIBLINGS BY department_name --������ �������� ��������  
;

--# 2. CONNECT_BY_ROOT
--������ �������� �ֻ��� �ο츦 ��ȯ�ϴ� ������. (�������̹Ƿ�, CONNECT_BY_ROOT �������� �Ʒ��� ���� ǥ������ ����)
select department_id, LPAD(' >', 3*(LEVEL-1)) || department_name , LEVEL  
	  ,CONNECT_BY_ROOT department_name AS root_name --�ֻ��� �ο� ��ȯ 
from DEPARTMENTS
START WITH parent_id is null
CONNECT BY prior department_id = parent_id
;

--# 3. CONNECT_BY_ISLEAF
--CONNECT BY ���ǿ� ���ǵ� ���迡 ���� �ش� �ο찡 ������ �ڽķο��̸� 1�� ��ȯ, �׷��� ������ 0�� ��ȯ��.
select department_id, LPAD(' >', 3*(LEVEL-1)) || department_name , LEVEL  
	  , CASE WHEN CONNECT_BY_ISLEAF = 1 THEN '������ �ο�(1)' ELSE ' ' END AS ISLEAF   
from DEPARTMENTS
START WITH parent_id is null
CONNECT BY prior department_id = parent_id
;

--# 4. SYS_CONNECT_BY_PATH(colm,char) --> ù��° param : �÷� , �ι�° param : ������ (�����ڷ� �ش� �÷����� ���Ե� ���ڴ� ����Ҽ� ����) e.g) ����/����� ---> '/' ������. 
--������ ���������� ����Ҽ� �ִ��Լ�.��Ʈ��忡�� ������ �ڽ��� ����� ����� ��� ������ ��ȯ��.
select department_id , LPAD('  >', 3*(LEVEL-1)) || department_name, LEVEL , parent_id
	  --,SYS_CONNECT_BY_PATH(department_name, '|')
from departments
START WITH parent_id is null
CONNECT BY prior department_id = parent_id
;

--# 5. CONNECT_BY_ISCYCLE (���ѷ��� ������ Ȯ���ϱ�)
-- NOCYCLE ������ �ɾ��ְ�, CONNCEC_BY_ISCYCLE�� ���ѷ��� �ο� Ȯ�� (����Ŭ�̸� 1�� ǥ��) 
select * from departments where department_id = 30 --parent_id 10 
;
--���ѷ��� �������� ������Ʈ �ؼ� ���� �߻���Ŵ 
--update departments
--   set parent_id = 170
-- where department_id = 30;
rollback;

select department_id , LPAD('  >', 3*(LEVEL-1)) || department_name, LEVEL 
	  ,parent_id
	  ,CONNECT_BY_ISCYCLE isLoop --����ã�� �ο� (����Ŭ : 1, �ƴϸ� 0) 
from departments
START WITH department_id = 30
CONNECT BY NOCYCLE prior department_id = parent_id
;


--# ������ ���� ����
--1) ���õ����� ���� 
--���� ������ ������ CONNECT BY ������ ���� �����. 
--Ʃ��ȿ���� ���� �ٷ��� ������ ������ ������������ ����Ŭ���� �����ϴ� DBMS_RANDOM�̶� ��Ű��(��������)�� ����ϸ� ����� �����͵� ���� ��������. 
CREATE TABLE ex7_1 AS (
select ROWNUM seq,
	   '2014'||LPAD(CEIL(ROWNUM/1000), 2, '0') month, --LPAD(��, �ѹ��ڱ���, ä����)
	   ROUND(DBMS_RANDOM.VALUE (100, 1000)) amt 	  --DBMS_RANDOM.VALUE(low IN NUMBER, high IN NUMBER) ������ ���ڻ���(�ּҹ���,�ִ����) 
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

/* ������ ��(S)����
 * �������̶� : ù°�׺��� ���ʴ�� ������ ��(=����)�� ���Ͽ� ���� ����
 * ����r = 1�̸�, S = a*n
 * ����r!= 1�̸�, S = a(1-r^n)/(1-r)
 */
--���� r = 1 ��� 
--a=1, r=1, n=3 
--1*3 = 3
select rownum from (
	select rownum
	from dual
	--connect by level <= 3
)
connect by level <= 3
;

--���� r!= 1 ���
--a=2 , r=2, n=4
--2(1-16)/(1-2)  ---> 2*15 = 30 
select ROWNUM
from (
		select 1 AS row_num
		from dual
		UNION ALL
		select 1 AS row_num
		from dual 
		--CONNECT BY LEVEL <= 4
)
CONNECT BY LEVEL <= 4

; 