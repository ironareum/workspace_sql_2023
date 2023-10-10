--###5�� �׷������� ���� ������ �˾ƺ��� 

--##01 �⺻ �����Լ� : ��� �����͸� Ư�� �׷����� ���� ���� �̱׷쿡 ���� ����, ���, �ִ�, �ּڰ� ���� ���ϴ� �Լ� 
--COUNT(expr): ������� �Ǽ� ��ȯ **null�� �ƴ� �ǿ� ���ؼ��� �ο��� �� ��ȯ 
select count(*) from employees; --107
select count(department_id) from employees; --106(null����)
select count(distinct department_id) from employees; --11��
select distinct department_id from employees; --12�� (���ϰ�, null ����)

--SUM(expr): expr�� �������� ���� 
select SUM(salary) from employees;
select SUM(distinct salary) from employees;


--AVG(expr) : ��հ�
select ROUND(AVG(salary),5)
        , ROUND(AVG(distinct salary),5)
from employees;


--MIN(expr), MAX(expr) : �ּڰ�, �ִ�
select MIN(salary), MAX(salary) from employees;


--VARIANCE(expr): �л� (�־��� ������ ���� ���� ��հ����� ������ ������ ���� �̸� �����ؼ� ����� ��)
--STDDEV(expr) : ǥ������(�л� ���� ������) => ���� ��迡���� ����� �߽����� ������ ������� �����ϴ����� ��Ÿ���� ��ġ�� ǥ�������� ���
select ROUND(VARIANCE(salary),5)
    , ROUND(STDDEV(salary),5) 
from employees;



--##02 GROUP BY��, HAVING ��
--��ü�� �ƴ� Ư�� �׷����� ���� �����͸� �����Ҷ� ��� 
--GROUP BY : WHERE�� ORDER�� ���̿� ��ġ 
select department_id, SUM(salary)
from employees
group by department_id
order by DEPARTMENT_ID
;


select * from KOR_LOAN_STATUS ;
--2013�� ������ ������� �� �ܾ� ���ϱ�
select 
    period
    , region 
    , SUM(loan_Jan_AMT) AS "�����ܾ�(�ʾ�)"
from KOR_LOAN_STATUS
where period like '2013%'
group by period, region
order by period, region 
;

--2013�� 11�� �� �ܾ�
select period
    , region
    , SUM(loan_jan_amt) as �ܾ�
from kor_loan_status
where PERIOD = '201311'
group by period, region  --> ���� ������, select ����Ʈ�� �ִ� �÷����̳� ǥ������ �����Լ��� �����ϰ�� ��� group by ���� ����ؾ���
;

--HAVING : GROUP BY�� ������ ��ġ�� group by�� ����� ������� �ٽ� ���͸� �Ŵ� ���Ҽ���.
--��, HAVING �������� ���·� ��� 
select period
    , region
    , SUM(loan_jan_amt) as �ܾ�
from kor_loan_status
where PERIOD = '201311'
group by period, region
having sum(loan_jan_amt) >= 100000
order by region
;



--ROLLUP���� CUBE��: GROUP BY ������ ���Ǿ� �׷캰 �Ұ踦 �߰��� �����ִ� ����.

--ROLLUP(expr1, expr2, ...): expr�� ����� ǥ������ �������� ������ ���(=�߰����� ��������)�� ������
--ROLLUP���� ����� �� �ִ� ǥ���Ŀ��� �׷��� ���(select ����Ʈ���� �����Լ��� ������ �ø�)�� �ü��ְ�, 
--����� ǥ���� ���� ����(�����ʿ��� ���� ������)�� ���� �������� ������ ����� ��ȯ��
--ǥ���� ������ n���̸�, n+1��������, ������������ �������� ������ �����Ͱ� ����ȴ�.
select period, gubun, round(sum(loan_jan_amt),2) totl_jan
from kor_loan_status
where period like '2013%'
--group by period, gubun
group by rollup(period, gubun) --n+1 �������� �����
order by period;
/*
201310	��Ÿ����	    676078
201310	���ô㺸����	411415.9    -> level 3 (period, gubun)
201310		        1087493.9   -> level 2 (period)
201311	��Ÿ����	    681121.3    
201311	���ô㺸����	414236.9
201311		        1095358.2   -> levle 2 (period)
                    2182852.1   -> level 1 (total)
*/

--����ROLLUP: e.g) GROUP BY expr1, ROLLUP(expr2, expr3)
select period, gubun, sum(loan_jan_amt) totl_jan
from kor_loan_status
where period like '2013%'
GROUP BY period, ROLLUP(gubun); -- n+1 level = 2
/*
201310	��Ÿ����	    676078
201310	���ô㺸����	411415.9    -> level 2 (period, gubun)
201310		        1087493.9   -> level 1 (period)
201311	��Ÿ����	    681121.3
201311	���ô㺸����	414236.9
201311		        1095358.2
*/


select period, gubun, sum(loan_jan_amt) totl_jan
from kor_loan_status
where period like '2013%'
GROUP BY ROLLUP(period), gubun; -- n+1 level = 2
/*
201310	��Ÿ����	    676078
201311	��Ÿ����	    681121.3
        ��Ÿ����	    1357199.3
201310	���ô㺸����	411415.9
201311	���ô㺸����	414236.9
        ���ô㺸����	825652.8
*/


--CUBE(expr1, expr2, ...) :ROLLUP�� ��������� �ٸ� ����
--ROLLUP: �������� ������ ����
--CUBE  : ����� ǥ���� ������ ���� "������ ��� ���պ�"�� ������ ��ȯ (= 2�� expr���� ��ŭ �������� �����)
--        e.g) expr ���� 3�̸� 2^3 = 8���� ������������ ��� ��ȯ 
select period, gubun, sum(loan_jan_amt) totl_jan
from kor_loan_status
where period like '2013%'
group by CUBE(period, gubun); --2^2 = �� 4���� ����
/*
                    2182852.1   -> type 1 (total)
        ��Ÿ����	    1357199.3   -> type 2 (gubun)
        ���ô㺸����	825652.8
201310	    	    1087493.9   -> type 3 (period)
201310	��Ÿ����	    676078      -> type 4 (period, gubun)
201310	���ô㺸����	411415.9
201311		        1095358.2
201311	��Ÿ����	    681121.3
201311	���ô㺸����	414236.9
*/

--���� CUBE
select period, gubun, sum(loan_jan_amt) totl_jan
from kor_loan_status
where period like '2013%'
group by period, CUBE(gubun); -- 2^1 = 2 ���� �����ȯ 
/*
201310		        1087493.9   -> type 1) period
201310	��Ÿ����	    676078      -> type 2) period, gubun 
201310	���ô㺸����	411415.9
201311		        1095358.2
201311	��Ÿ����	    681121.3
201311	���ô㺸����	414236.9
*/



--#04 ���� ������
--UNION, UNION ALL, INTERSECT, MINUS 


--UNION ������
CREATE TABLE exp_goods_asia (
    country VARCHAR2(10)
    , seq   NUMBER
    , goods VARCHAR2(80)
);

select * from exp_goods_asia;

INSERT INTO exp_goods_asia VALUES('�ѱ�', 1, '�������� ������');
INSERT INTO exp_goods_asia VALUES('�ѱ�', 2, '�ڵ���');
INSERT INTO exp_goods_asia VALUES('�ѱ�', 3, '��������ȸ��');
INSERT INTO exp_goods_asia VALUES('�ѱ�', 4, '����');
INSERT INTO exp_goods_asia VALUES('�ѱ�', 5, 'LCD');
INSERT INTO exp_goods_asia VALUES('�ѱ�', 6, '�ڵ�����ǰ');
INSERT INTO exp_goods_asia VALUES('�ѱ�', 7, '�޴���ȭ');
INSERT INTO exp_goods_asia VALUES('�ѱ�', 8, 'ȯ��źȭ����');
INSERT INTO exp_goods_asia VALUES('�ѱ�', 9, '���۽ű� ���÷��� �μ�ǰ');
INSERT INTO exp_goods_asia VALUES('�ѱ�', 10, 'ö �Ǵ� ���ձݰ�');


INSERT INTO exp_goods_asia VALUES('�Ϻ�',1 , '�ڵ���');
INSERT INTO exp_goods_asia VALUES('�Ϻ�',2 , '�ڵ�����ǰ');
INSERT INTO exp_goods_asia VALUES('�Ϻ�',3 , '��������ȸ��');
INSERT INTO exp_goods_asia VALUES('�Ϻ�',4 , '����');
INSERT INTO exp_goods_asia VALUES('�Ϻ�',5 , '�ݵ�ü������');
INSERT INTO exp_goods_asia VALUES('�Ϻ�',6 , 'ȭ����');
INSERT INTO exp_goods_asia VALUES('�Ϻ�',7 , '�������� ������');
INSERT INTO exp_goods_asia VALUES('�Ϻ�',8 , '�Ǽ����');
INSERT INTO exp_goods_asia VALUES('�Ϻ�',9 , '���̿���, Ʈ��������');
INSERT INTO exp_goods_asia VALUES('�Ϻ�',10, '����');

SELECT goods FROM EXP_GOODS_ASIA
where country = '�ѱ�'
UNION 
SELECT goods FROM EXP_GOODS_ASIA
where country = '�Ϻ�'
--order by seq;
;


SELECT goods FROM EXP_GOODS_ASIA
where country = '�ѱ�'
UNION ALL
SELECT goods FROM EXP_GOODS_ASIA
where country = '�Ϻ�'
--order by seq;
;


--INTERSECT  ������
SELECT goods FROM EXP_GOODS_ASIA
where country = '�ѱ�'
INTERSECT
SELECT goods FROM EXP_GOODS_ASIA
where country = '�Ϻ�'
--order by seq;
;

--MINUS
SELECT goods FROM EXP_GOODS_ASIA
where country = '�ѱ�'
MINUS
SELECT goods FROM EXP_GOODS_ASIA
where country = '�Ϻ�'
--order by seq;
;


--##���� �������� ���ѻ��� 
--1) ���� �����ڷ� ����Ǵ� �� SELECT���� SELECT ����Ʈ�� ������ ������ Ÿ���� ��ġ�ؾ� �Ѵ�
SELECT seq, goods 
FROM EXP_GOODS_ASIA
where country = '�ѱ�'
UNION
SELECT seq, goods --�ȵ�  
FROM EXP_GOODS_ASIA
where country = '�Ϻ�'
--order by seq;
;
--���� �������� ���ܵ� �ߺ����� INTERSECT�� Ȯ�� ������
SELECT seq, goods FROM EXP_GOODS_ASIA
where country = '�ѱ�'
INTERSECT
SELECT seq, goods FROM EXP_GOODS_ASIA
where country = '�Ϻ�'
--order by seq;
;

--2)���� �����ڷ� SEELCT���� ������ �� ORDER BY���� �� ������ ���忡���� ����� �� �ִ�
SELECT goods FROM EXP_GOODS_ASIA
where country = '�ѱ�'
UNION
SELECT goods FROM EXP_GOODS_ASIA
where country = '�Ϻ�'
order by goods
;

--3)BLOB, CLOB, BFILE Ÿ���� �÷��� ���ؼ��� ���� �����ڸ� ����� �� ����
--4)UNION, INTERSECT, MINUS �����ڴ� LONG�� �÷����� ����� �� ����



--##GROUPING SETS ��
--ROLLUP�̳� CUBEó�� GROUP BY���� ����ؼ� �׷������� ����ϴ� ��. (�׷������̳� UNION ALL ������ ����������)
--GROUPING SETS(expr1, expr2, expr3)
--���� ����. GROUP BY(expr1) UNION ALL GROUP BY(expr2) UNION ALL GROUP BY(expr3)
SELECT period, gubun, SUM(loan_jan_amt) totl_jan
FROM KOR_LOAN_STATUS
WHERE period LIKE '2013%'
GROUP BY GROUPING SETS(period, gubun)
;

SELECT period, gubun, region, SUM(loan_jan_amt) totl_jan
FROM KOR_LOAN_STATUS
WHERE period LIKE '2013%'
GROUP BY GROUPING SETS(period, (gubun, region))
;


--##Self Check
--1. ��� ���̺��� �Ի�⵵�� ����� ���ϱ�
--select CASE WHEN SUBSTR(HIRE_DATE,1,4) IS NOT NULL THEN SUBSTR(HIRE_DATE,1,4)
--        ELSE '����'
--        END AS HIRE_Y
select    DECODE(GROUPING(SUBSTR(hire_date,1,4)), 1, '����', SUBSTR(HIRE_DATE,1,4)) AS HIRE_Y2
       , count(*)
from EMPLOYEES
group by rollup(SUBSTR(hire_date,1,4))
;
select count (*) from EMPLOYEES
;

--2.kor_loan_status ���̺��� 2012�⵵ ����, ������ ���� �� �ܾ��� ���ϴ� ���� �ۼ��ϱ�
select  PERIOD, REGION, sum(LOAN_JAN_AMT)
from KOR_LOAN_STATUS
where PERIOD like '2012%'
group by GROUPING SETS(PERIOD, REGION)
;

--3. rollup �����ʰ� �Ʒ��� ������ ��� ������ ����¥�� 
select period , gubun, sum(LOAN_JAN_AMT) totl_jan
from KOR_LOAN_STATUS
where period like '2013%'
group by PERIOD, rollup(GUBUN)
;
201310	��Ÿ����	    676078
201310	���ô㺸����	411415.9
201310		        1087493.9
201311	��Ÿ����	    681121.3
201311	���ô㺸����	414236.9
201311		        1095358.2
;
select period , gubun, sum(LOAN_JAN_AMT) totl_jan
from KOR_LOAN_STATUS
where period like '2013%'
group by PERIOD, gubun
UNION ALL
select period , '' AS gubun, sum(LOAN_JAN_AMT) totl_jan
from KOR_LOAN_STATUS
where period like '2013%'
group by PERIOD
;

--4. ���տ����ڷ� �Ʒ� ������ ������ ��� ����� 
select period
     , case when gubun = '���ô㺸����' then sum(loan_jan_amt) else 0 end ���ô㺸�����
     , case when gubun = '��Ÿ����'     then sum(loan_jan_amt) else 0 end ��Ÿ�����   
from kor_loan_status
where period = '201311'
group by period, gubun
;
201311	414236.9	0
201311	0	        681121.3
;
select period--, sum(loan_jan_amt) AS ���ô㺸�����
    , case when gubun = '���ô㺸����' then sum(loan_jan_amt) else 0 end ���ô㺸�����
    , case when gubun = '��Ÿ����'     then sum(loan_jan_amt) else 0 end ��Ÿ�����
from kor_loan_status
where period = '201311' and gubun = '���ô㺸����'
group by period, gubun
union all
select period--, sum(loan_jan_amt) AS ��Ÿ�����
    , case when gubun = '���ô㺸����' then sum(loan_jan_amt) else 0 end ���ô㺸�����
    , case when gubun = '��Ÿ����'     then sum(loan_jan_amt) else 0 end ��Ÿ�����
from kor_loan_status
where period = '201311' and gubun = '��Ÿ����'
group by period, gubun
;


--5. 
