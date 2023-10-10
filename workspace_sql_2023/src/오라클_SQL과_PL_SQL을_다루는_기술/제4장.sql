--4�� SQL �Լ� ���캸��

--#01 �����Լ� (���Ŀ���)
--�Ű������� ��ȯ���� ��κ� �������� 
--ABS(n) ���밪

--CEIL / FLOOR ���� ū ������ ��ȯ 
SELECT CEIL(10.123), CEIL(10.541), CEIL(11.001),
        FLOOR(10.123), FLOOR(10.541), FLOOR(11.001)
from dual;

--ROUND(n,i)�� TRUNC(n1,n2)
--ROUND : i+1�ڸ������� �ݿø�
--TRUNC : �߶󳻱� 


--#02 �����Լ�
--INITCAP(char), LOWER(cahr), UPPPER(char)

--SBUSTR, SUBSTRB(char, pos, len)

--LTRIM, RTRIM(char, set): set���� ���� (�������ſ�)
select LTRIM('ABCDEFG', 'ABC') from dual;

--LPAD, RPAD(expr1, n, expr2) :ä���ֱ�
select LPAD('111-111',11, '02-') from dual; 

--REPLACE(char, serach_str, replace_str), TRANSLATE(expr, from_str, to_str) :���ڿ� ��ü (���ڿ� �߰� ���鵵 ���� ����)
select REPLACE('���� �ʸ� �𸣴µ� �ʴ� ���� �˰ڴ°�?', '��', '��') from dual;
--TRANCLATE : ���ڿ� ��ü�� �ƴ� ���� �� ���ھ� ������ �ٲ� ����� ��ȯ��
select TRANSLATE('���� �ʸ� �𸣴µ� �ʴ� ���� �˰ڴ°�?', '����', '�ʸ�') from dual;

--INSTR(str,substr,pos,occur): ��ġ�ϴ� ��ġ ��ȯ. occur�� ���° ��ġ�ϴ��� �ڸ��� ��ȯ 
select INSTR('���� ���� �ܷο� ����, ���� ���� ���ο� ����, ���� ���� ��ſ� ����', '����') as instr1,
        INSTR('���� ���� �ܷο� ����, ���� ���� ���ο� ����, ���� ���� ��ſ� ����', '����',5) as instr2,
        INSTR('���� ���� �ܷο� ����, ���� ���� ���ο� ����, ���� ���� ��ſ� ����', '����',5,2) as instr3
from dual;

--LEGHTH, LEGHTB
select LENGTH('���ѹα�'), LENGTHB('���ѹα�') from dual; --4,8



--#03 ��¥�Լ�
--SYSDATE, SYSTIMESTAMP
select SYSDATE, SYSTIMESTAMP from dual;

--ADD_MONTHS(date, integer) :�� ���ϱ� ���
select ADD_MONTHS(SYSDATE, 1), ADD_MONTHS(SYSDATE, -1) 
from dual;

--MONTHS_BETWEEN(date1, date2): ������ ����ϰ� �ʹٸ� date1�� �� ������¥�� �� 
select MONTHS_BETWEEN(SYSDATE, ADD_MONTHS(SYSDATE,1)) --20230118 = -1
        ,MONTHS_BETWEEN(ADD_MONTHS(SYSDATE,1), SYSDATE) --20230118 = 1
from dual;

--LAST_DAY(date): ���� ��������
select LAST_DAY(SYSDATE) from dual;

--ROUND(date, format), TRUNC(date,format): �����Լ� �̸鼭 ��¥�Լ� 
--ROUND: format�� ���� �ݿø��� ��¥�� ��ȯ => 16�� ��������
--TRUNC: �߶� ��¥�� ��ȯ
select ROUND(TO_DATE('2022-12-16','YYYY-MM-DD'), 'month'), TRUNC(TO_DATE('2022-12-16','YYYY-MM-DD'), 'month') from dual;
select ROUND(TO_DATE('2022-12-16','YYYY-MM-DD'), 'day'), TRUNC(TO_DATE('2022-12-16','YYYY-MM-DD'), 'day') from dual;
select ROUND(TO_DATE('2022-12-16','YYYY-MM-DD'), 'year'), TRUNC(TO_DATE('2022-12-16','YYYY-MM-DD'), 'year') from dual;
select TO_DATE('2022-12-16','YYYY-MM-DD') from dual;

--NEXT_DAY(date, char): char���� ����� ��¥�� "���� ���� ����"�� ��ȯ
select NEXT_DAY(SYSDATE, 'ȭ����') from dual;



--#04 ��ȯ�Լ� (=����� ����ȯ)
--TO_CHAR(���� Ȥ�� ��¥, format)
select TO_CHAR(123456789, '999,999,999') from dual;
select TO_CHAR(SYSDATE, 'YYYY-MM-DD') from dual;
--AM/PM
select TO_CHAR(SYSDATE, 'AM') from dual;
--��/��/��
select TO_CHAR(SYSDATE, 'YYYY') from dual;
select TO_CHAR(SYSDATE, 'MM') from dual;
select TO_CHAR(SYSDATE, 'DD') from dual;
--����ǥ�� (1 �Ͽ���, 2 ������)
select TO_CHAR(SYSDATE, 'D') from dual;
select TO_CHAR(SYSDATE, 'DAY') from dual;
--365�� �������� ǥ��
select TO_CHAR(SYSDATE, 'DDD') from dual;
--�������� ���ϱ��� ǥ��
select TO_CHAR(SYSDATE, 'DL') from dual;
--�ð� ǥ��
select TO_CHAR(SYSDATE, 'HH') from dual;
select TO_CHAR(SYSDATE, 'HH12') from dual;
select TO_CHAR(SYSDATE, 'HH24') from dual;
--�� (00~59)
select TO_CHAR(SYSDATE, 'MI') from dual;
--�ָ� 01~53�� ���·� ǥ�� 
select TO_CHAR(SYSDATE, 'WW') from dual;
--��������
select TO_CHAR(123456, '999,999') from dual; --�޸�
select TO_CHAR(123456.4, '999,999.9') from dual; --�Ҽ��� ǥ��
select TO_CHAR(-123, '999PR') from dual; --�����϶�<>�� ǥ��
select TO_CHAR(123, 'RN') from dual; --�θ�����
select TO_CHAR(123456, 'S999999') from dual; --���/���� ��ȣǥ��

--TO_NUMBER(expr, format): ���ڷ� ����ȯ
select TO_NUMBER('123456') from dual;

--TO_DATE(char, format), TO_TIMESTAMP()
select TO_DATE('20221212','YYYY-MM-DD') from dual;
select TO_DATE('20221212 13:44:50','YYYY-MM-DD HH24:MI:SS') from dual;



--#05 NULL ���� �Լ�
--NVL(expr1, expr2), NVL2(expr1, expr2, expr3)
select NVL(manager_id, employee_id) from employees
where manager_id IS NULL ;

--NVL2(expr1, expr2, expr3) : expr1�� null�� �ƴϸ� expr2��, null�̸� expr3�� ��ȯ
select employee_id, NVL2(commission_pct, salary + (salary * commission_pct), salary) 
from employees;
with temp as (
    select 'exp1' as expr1, 'exp2_notNull' as expr2, 'exp3_notNull' as expr3 from dual
    union all
    select '' as expr1, 'exp2_Null' as expr2, 'exp3_Null' as expr3 from dual
)
select nvl2(expr1, expr2, expr3) from temp ;
    

--COALESCE(expr1, expr2) :null�� �ƴ� ù��° ǥ������ ��ȯ
select employee_id, salary, commission_pct
        , COALESCE(salary * commission_pct, salary) AS salary2
        , nvl(salary * commission_pct, salary) AS salary3
from employees
;


--LNNVL(���ǽ�):���ǽ��� ����� false �� unknown�̸� TRUE��, true�̸� FALSE�� ��ȯ�Ѵ�
--�÷��� NULL�� ��� = TRUE
--�Լ� ���� ������ FALSE�� ��� = TRUE
--e.g) Ŀ�̼��� 0.2 ������ ��� ��ȸ(null����) 
/*
LNNVL(comm = 0) �� �Ʒ��� ������ �������� �ؼ��� 
== AND (comm is null OR comm != 0)
����, LNNVL�� ����ϴ� ������ null�� �Բ� ��ȸ�ǵ��� �ϱ������̸�, 
LNNVL �Լ� ������ ������ ��ȸ�Ϸ��� �ϴ� ������ �ݴ� �������� �ο��ϴ� ���� ����ؾ� �Ѵ�. https://gent.tistory.com/387
*/
select employee_id, commission_pct from employees 
where commission_pct < 0.2; --11�� => Ŀ�̼��� null�� ����� ��ȯ�ȵ�
--case1) NVL�� null�� ��� 0�� ó���� ��ȸ 
select count(*) from employees
where NVL(commission_pct, 0) <0.2; --83��
--case2) LNNVL�� �ذ�
select  employee_id, commission_pct --count(*) 
from employees
where LNNVL(commission_pct >= 0.2);--83


--NULLIF(expr1, expr2): expr1, expr2�� ���� ������ NULL��, ���������� expr1�� ��ȯ�Ѵ�
select employee_id
--,start_date
        ,TO_CHAR(start_date, 'YYYY') start_year
        ,TO_CHAR(end_date, 'YYYY') end_year
        ,NULLIF(TO_CHAR(end_date, 'YYYY'), TO_CHAR(start_date, 'YYYY')) null_ifyear
from job_history
;

select  employee_id
        ,TO_CHAR(start_date, 'YYYY') start_year
        ,TO_CHAR(end_date, 'YYYY') end_year
        ,TRUNC(MONTHS_BETWEEN(TO_CHAR(end_date,'YYYYMMDD'), TO_CHAR(start_date, 'YYYYMMDD'))/12)
from job_history
where TRUNC(MONTHS_BETWEEN(TO_CHAR(end_date,'YYYYMMDD'), TO_CHAR(start_date, 'YYYYMMDD'))/12) > 0
;






--##06 ��Ÿ�Լ�
--GREATES(expr1, expr2,...), LEAST(expr1, expr2,...)
--���ں�
select GREATEST(1,2,3,2), LEAST(1,2,3,2) from dual;

--���ں�
select GREATEST('�̼���', '������','�������'), LEAST('�̼���', '������','�������') from dual;

--DECODE(expr, search1, result1, search2, result2, ..., default)
select prod_id, channel_id,
        DECODE(channel_id, 3, 'Direct',
                           9, 'Direct',
                           5, 'Indirect',
                           4, 'Indirect',
                              'Others') decodes
from sales
where rownum < 10 
    and prod_id = 18
;


--SelfCheck
--1) (02) ���̱� 
select phone_number, LPAD(phone_number,16,'(02)') 
from employees;

--2) �ټӳ�� 10���̻� ���� (��������)
select EMPLOYEE_ID, EMP_NAME, HIRE_DATE, trunc(months_between(sysdate,hire_date)/12) as work_year 
from EMPLOYEES
where months_between(sysdate,hire_date)/12 > 10
order by work_year desc
;

--3)��ȭ��ȣ '-' -> '/'�� ��ȯ 
select CUST_MAIN_PHONE_NUMBER, replace(CUST_MAIN_PHONE_NUMBER, '-', '/')
from customers ;

--4) ����ȭ��ȣ ��ȣȭ
select CUST_MAIN_PHONE_NUMBER, translate(CUST_MAIN_PHONE_NUMBER, '12345678900-', 'qwertyuiopa')
from customers
;

--5)cust_year_of_birth �÷����� 30,40,50�� ���ɱ��� (DECODE ���)
WITH T_AGE AS (
select  CUST_ID
        , CUST_NAME
        , trunc(months_between(sysdate, TO_DATE(CUST_YEAR_OF_BIRTH||'0101','YYYYMMDD') )/12)+1 AS K_AGE
from customers
)
select CUST_ID
     , CUST_NAME 
     , K_AGE
     , DECODE (substr(K_AGE,1,1),'3', '30��', '4','40��', '5','50��', '��Ÿ') AS AGE
from T_AGE
order by K_AGE
;



--##6. 5������ CASE�� ���
WITH T_AGE AS (
select  CUST_ID
        , CUST_NAME
        , trunc(months_between(sysdate, TO_DATE(CUST_YEAR_OF_BIRTH||'0101','YYYYMMDD') )/12)+1 AS K_AGE
from customers
)
select --CUST_ID
--     , CUST_NAME 
--     , K_AGE
        distinct K_AGE
     , CASE WHEN substr(K_AGE,1,1) = '3' THEN '30��'
      WHEN substr(K_AGE,1,1) = '4' THEN '40��'
      WHEN substr(K_AGE,1,1) = '5' THEN '50��'
      WHEN substr(K_AGE,1,1) = '6' THEN '60��'
      ELSE '��Ÿ'
      END AS AGE 
from T_AGE
order by K_AGE
;


