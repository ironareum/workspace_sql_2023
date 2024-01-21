/*
 * 1. ������ ����
 * 2. WITH��
 * 3. �м��Լ��� window �Լ�
 * 4. �������̺� INSERT 
 */

/****************** 
 ## 1. ������ ���� ##
 ******************/

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




/********************
--# ������ ���� ���� #
********************/
--# 1) ���õ����� ����
 
--���� ������ ������ CONNECT BY ������ ���� �����. 
--Ʃ��ȿ���� ���� �ٷ��� ������ ������ ������������ ����Ŭ���� �����ϴ� DBMS_RANDOM�̶� ��Ű��(��������)�� ����ϸ� ����� �����͵� ���� ��������. 
CREATE TABLE ex7_1 AS (
select ROWNUM seq,
	   '2014'||LPAD(CEIL(ROWNUM/1000), 2, '0') month, --��LPAD(��, �ѹ��ڱ���, ä����)
	   ROUND(DBMS_RANDOM.VALUE (100, 1000)) amt 	  --��DBMS_RANDOM.VALUE(low IN NUMBER, high IN NUMBER) ������ ���ڻ���(�ּҹ���,�ִ����) 
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

/* CONNECT BY LEVEL <= ���� : ����� ���ڸ�ŭ�� �ο츦 ��ȯ.  
 * ���������� ���� �������� �ո�ŭ �ο츦 ����. 
 * DUAL ���̺��� �⺻ �ο� ������ 1���ε� "SELECT ... FROM DUAL CONNECT BY LEVEL <= 3"�̶�� ����Ҷ� �̴� ù°��(a=1), ����(r=1), ���� ��(n=3)�� �������� �ش��Ѵ�.*/
SELECT * FROM DUAL 
CONNECT BY LEVEL <= 3 --3 row ���� 
;


--������ ���� ���������� DUAL���̺��� ��ȸ�ϴ� ������ UNION ALL�� �����ϸ�, �� �ٱ� �ִ� ������ �⺻ �ο���� 1�� �ƴ�, 2�� �ȴ�.
SELECT ROWNUM, ROW_NUM, LEVEL--, RN
FROM (SELECT '1_A' ROW_NUM 
	  FROM DUAL 
	  UNION ALL
	  SELECT '1_B' ROW_NUM  
	  FROM DUAL
	  )
CONNECT BY LEVEL <= 4 -- �������� 2 row^4 
;
�׼�^
 a^n
 2^1, 2^2, 2^3, 2^4 
= 2  + 4  + 8 + 16 

/* ������ ��(S)����
 * �������̶� : ù°�׺��� ���ʴ�� ������ ��(=����)�� ���Ͽ� ���� ����
 * ����r = 1�̸�, S = a*n
 * ����r!= 1�̸�, S = a(1-r^n)/(1-r)
      r = 2  , S = 2(1-2^4)/(1-2)
                 = 2(1-16)/-1
                 = 2(-15)/-1
                 = 30  
 **/
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

--# 2) �ο츦 �÷����� ��ȯ�ϱ� (LISTAGG)
--LISTAGG(expr, delimiter) WITHIN GROUP(ORDER BY��) --> expr�� delimiter�� �����ؼ� �ο츦 �÷����� ��ȯ�� ��ȸ�ϴ� �Լ�.
--LISTAGG�� �׷��Լ��̱� ������, GROUP BY �Ǵ� PARTITION BY���� �Բ� ����Ѵ�. 
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


--# 3) �÷��� �ο�� ��ȯ�ϱ� (������ ���� ���)
select REPLACE(SUBSTR(empnames, start_pos, end_pos - start_pos), ',' , '') as emp_name
		--SUBSTR(empnames, start_pos, end_pos)
		--INSTR ���� : INSTR(�÷���, 'ã������', 1:�տ������Ͱ˻�, ���° ã����ġ)
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
 # 02.WITH �� #
********************/
--������ �������� 

/* ������ ������ ���� ���� ������ ���� ���ÿ� �ܾ��� ���϶�. (�հ�) 
 * 1) ������ ������ ���ϱ� (max)
 * 2) ������ �ֵ��� ������ �����հ� ���ϱ�
 * 3)   
 * */
with t1 as 
( --������ ������
  select max(period) as max_year
    from kor_loan_status
  group by substr(period,1,4)
)
, t2 as 
( --������ ������ ���ú� �ܾ� 
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
 201112   ����     334728.3
 201212   ����     331572.3
 201311   ����     334062.7

-----------------------------------
--[å�� �ִ� ����]
 201112 ����     334728.3
 201212 ����     331572.3
 201311 ����     334062.7

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





--## ��ȯ�������� (like ������ ����)
/* Recursive WITH�� ���� : 
 * UNION ALL�� ������ �ʱⰪ�� �����ִ� �ʱ⼭�������� , 
 * ���Ŀ� ������ �ۼ��ϴ� Recursive ���� ������ ������. 
 * ��, �׻� ����Լ����� �׷����� ���ѷ����� �������ʵ��� ���������� �������� ǥ���ؾ���!��
 * */
/*----------[Recursive WITH�� ����] START------------*/
WITH CONTINUOUS(NUM, RESULT) AS(
    SELECT 1,1 FROM DUAL --�ʱⰪ�� �����ִ� �������� 
    UNION ALL
    SELECT --���Ŀ� ������ �ۼ��ϴ� Recursive �������� 
          NUM+1, (NUM+1)+RESULT
    FROM CONTINUOUS
    WHERE NUM < 9 --���ѷ����� �������ʵ��� �ϴ� ������! 
)
SELECT
    NUM
    ,RESULT
FROM CONTINUOUS;
/*----------[Recursive WITH�� ����] E N D------------*/

select * from departments order by parent_id;
--1) ������ ������
select parent_id, department_id, LPAD(' ', 3*(LEVEL-1))||department_name, LEVEL 
from departments
start with parent_id is null
connect by prior department_id = parent_id;

--2) with���� ����� �� ������ ������ ������ ����� �̾Ƴ����ִ�.
with recur(parent_id, department_id, department_name, lvl)
	 as ( select parent_id, department_id, department_name, 1 as lvl  --�ʱⰪ �������� 
	 		from departments
	 	   where parent_id is null --> start with parent_id is null �� ����
	 	   union all 
	 	  select a.parent_id, a.department_id, a.department_name, b.lvl +1
	 	  	from departments a, recur b
	 	   where a.parent_id = b.department_id --> connect by prior department_id = parent_id�� ����
	 	)
select parent_id, department_id, LPAD(' ', 3*(lvl-1)) || department_name as department_name, lvl
from recur; 

--3) recursive with������ order by ����ϱ� 
/* ������ ���������� �ڵ����� ������ ���� �������� ��ȸ�Ǿ�����, 
 * ��ȯ�������������� �ܼ��� ���������θ� ��ȸ�ǹǷ� 
 * order siblings by ���� ���� ����� �ʿ���! ---> SEARCH ���� ����ϱ�!!  
 * 
 * [SEARCH ���� ���]
 *  -DEPTH FITST BY   : ���� ��忡 �ִ� �ο�, �� ����(siblings) row ���� �ڽ� row�� ���� ��ȸ��.
 *  -BREADTH FIRST BY : �ڽķο캸�� �����ο찡 ���� ��ȸ��.
 *  -���� ������ �ִ� �����ο��϶��� BY ������ ����� �÷� ������ ��ȸ��. 
 *  -SET �������� ���� �÷� ���·� ���� SELECT ������ ����� �� �ִ�.
 */
with recur(parent_id, department_id, department_name, lvl)
	 as ( select parent_id, department_id, department_name, 1 as lvl  --�ʱⰪ �������� 
	 		from departments
	 	   where parent_id is null --> start with parent_id is null �� ����
	 	   union all 
	 	  select a.parent_id, a.department_id, a.department_name, b.lvl +1
	 	  	from departments a, recur b
	 	   where a.parent_id = b.department_id --> connect by prior department_id = parent_id�� ����
	 	)
	 	/* order by�� ���� */
	 	SEARCH DEPTH FIRST BY department_id SET order_seq -->�ڽķο� ���� ��ȸ, ���� ���������� department_id������, order_seq �� �����÷����·� ���� select �������� ����Ҽ�����. 	 		
--select * from recur; 
--���� ��ȸ ����
select parent_id, department_id, LPAD(' ', 3*(lvl-1)) || department_name as department_name, lvl, order_seq 
from recur; 


--4) 
with recur(parent_id, department_id, department_name, lvl)
	 as ( select parent_id, department_id, department_name, 1 as lvl  --�ʱⰪ �������� 
	 		from departments
	 	   where parent_id is null --> start with parent_id is null �� ����
	 	   union all 
	 	  select a.parent_id, a.department_id, a.department_name, b.lvl +1
	 	  	from departments a, recur b
	 	   where a.parent_id = b.department_id --> connect by prior department_id = parent_id�� ����
	 	)
	 	/* order by�� ���� */
	 	SEARCH BREADTH FIRST BY parent_id SET order_seq -->�����ο� ���� ��ȸ, ���� ���������� parents_id������, order_seq �� �����÷����·� ���� select �������� ����Ҽ�����. 	 		
--���� ��ȸ ����
select parent_id, department_id, LPAD(' ', 3*(lvl-1)) || department_name as  department_name, lvl, order_seq 
from recur; 





/****************************** 
 ## 2. �м��Լ��� window �Լ� ##
 ******************************/

/* �м��Լ� */
/* �м��Լ��� ���̺� �ִ� �ο쿡 ���� Ư�� �׷캰�� ���� ���� �����Ҷ� ���.
 * ���谪�� ���Ҷ� ������ �׷������� ����ϴµ�, �̶� GROUP BY ���� ���� �������� ����� �׷캰�� �ο���� �پ���. 
 * �̿�����, �����Լ��� ����ϸ� �ο��� �սǾ��̵� �׷캰 ���谪�� ������ �� �� �ִ�.
 * 
 * �м��Լ����� ����ϴ� �ο캰 �׷��� ��������(window)��� �θ��µ�, �̴� ���� �� ����� ���� �ο��� ������ �����ϴ� ���ҡ��� �Ѵ�.   
 * */

