select table_name
from user_tables;

select * from KOR_LOAN_STATUS;

desc jobs;
--=========================================
CREATE TABLE ex2_5(
    COL_DATE DATE,
    COL_TIMESTAMP TIMESTAMP
);
INSERT INTO EX2_5 VALUES(SYSDATE, SYSTIMESTAMP);
SELECT * FROM EX2_5;
;

--�⺻Ű(PK)
CREATE TABLE ex2_8 (
    COL1 VARCHAR2(10) PRIMARY KEY
    , COL2 VARCHAR2(10)
);

CREATE TABLE ex2_9 (
    num1 NUMBER 
    CONSTRAINTS check1 CHECK (num1 BETWEEN 1 AND 9),
    gender VARCHAR2(10)
    CONSTRAINTS check2 CHECK (gender IN ('MALE', 'FEMALE'))
); 

select constraint_name, constraint_type, table_name, search_condition
from user_constraints
where table_name = 'EX2_9'
;

insert into EX2_9 VALUES(10, 'MAN');
insert into EX2_9 VALUES(5, 'FEMALE');


CREATE TABLE ex2_10 (
    Col1 VARCHAR2(10) NOT NULL
    ,Col2 VARCHAR2(10) NULL
    , CREATE_DATE DATE DEFAULT SYSDATE
);

--INSERT INTO ex2_10 (col1, col2)VALUES('AA','BB');
--INSERT INTO ex2_10 (col1, col2)VALUES('AA','AA');
select * from ex2_10;
desc ex2_10;
select constraint_name, constraint_type,table_name,search_condition  from user_constraints
where table_name = 'EX2_10';

--DROP TABLE ex2_10;
ALTER TABLE ex2_10 RENAME COLUMN Col1 to Col11;
ALTER TABLE ex2_10 MODIFY col2 VARCHAR(30);
ALTER TABLE ex2_10 ADD col3 NUMBER;
ALTER TABLE ex2_10 DROP column col3;
ALTER TABLE ex2_10 ADD CONSTRAINTS pk_ex2_10 PRIMARY KEY (col11);
ALTER TABLE ex2_10 DROP CONSTRAINTS pk_ex2_10;

--���̺� ����
CREATE TABLE ex2_9_1 as
select * from ex2_9;

select * from ex2_9_1;


--*******************
--View
--*******************
--������� ��ȸ�� �μ��� �����ְ� 
CREATE OR REPLACE VIEW emp_dept_v1 as
SELECT A.EMPLOYEE_ID, A.EMP_NAME, A.department_id
    , B.DEPARTMENT_NAME
FROM EMPLOYEES A, DEPARTMENTS B
WHERE A.DEPARTMENT_ID = B.DEPARTMENT_ID
;
select * from emp_DEPT_V1;
desc employees;
--DROP VEIW EMP_DEPT_V1;



--*******************
--INDEX
--*******************
CREATE UNIQUE INDEX EX2_10_IX01 --�ε�����
ON EX2_10(COL11); --�ε��� ���� ���̺�(�÷�) 

--�ε��� Ȯ��
SELECT * FROM USER_INDEXES WHERE TABLE_NAME = 'EX2_10';

--������ unique index�� �������� �ʾƵ�, ����ũ ���������� �����ϸ� ����ũ �ε����� ������  
select constraint_name, constraint_type, table_name, index_name
from user_constraints
where table_name = 'JOB_HISTORY'
;

select index_name, index_type, table_name, uniqueness
from user_indexes
where table_name = 'JOB_HISTORY'
;

--�Ѱ� �̻��� �÷����� �ε��� ����
CREATE INDEX ex2_10_ix02
ON ex2_10(col11, col2);

select * from user_indexes where table_name = 'EX2_10';

--�ε��� ����
DROP INDEX ex2_10_ix02;



--*******************
--�ó�� (public, private)
--*******************
--public ������ private �ó�� ������ 
CREATE OR REPLACE SYNONYM syn_channel
FOR channels; --For ������ ��ü���� ���̺�, ��, ���ν���, �Լ�, ��Ű��, ������ ���� �ü� ����

select count(*) from syn_channel;

--�ٸ� ����ڷ� ������ �ó�� �����غ��� ========
-- HR ����� ���� �� ���� ����
ALTER USER hr identified by hr Account unlock;
--�ٸ� ����ڷ� ������ �ó�� �����غ��� ========

--�ۺ� �üҴ� ����
CREATE OR REPLACE PUBLIC SYNONYM syn_channel2
For channels;

select count(*) from syn_channel2;

GRANT SELECT ON syn_channel2 TO public;

--�ó�� ���� (�����־�� ��������)
DROP SYNONYM syn_channel;
DROP PUBLIC SYNONYM syn_channel2; --�ۺ� �ó�� ������ PUBLIC ��� ��


--*******************
--������ :�ڵ������� ��ȯ�ϴ� �����ͺ��̽� ��ü
--*******************
CREATE SEQUENCE --�������� 
INCREMENT BY --�������� (0�� �ƴ�����. ����� ����, ������ ����, ����Ʈ=1)
START WITH --���ۼ��� (����Ʈ���� �����϶��� MINVALUE, �����϶��� MAXVALUE)
NOMINVALUE | MINVALUE --�ּڰ� 
NOMAXVALUE | MAXVALUE --�ִ�
NOCYCLE | CYCLE --NoCycle: �ִ볪 �ּڰ��� �����ϸ� ��������. Cycle: �ٽ� �ִ�/�ּڰ����� ����. 
NOCACHE | CACHE; --NoCache: ����Ʈ�� �޸𸮿� ���������� �̸� �Ҵ��� ���� ������ ����Ʈ���� 20.  Cache: �޸𸮿� ���������� �̸� �Ҵ��� ����
;


CREATE SEQUENCE my_seq1
INCREMENT BY 1
START WITH 1
MINVALUE 1
MAXVALUE 1000
NOCYCLE
NOCACHE;

DELETE ex2_8;
INSERT INTO ex2_8 (col1) VALUES(my_seq1.NEXTVAL);
INSERT INTO ex2_8 (col1) VALUES(my_seq1.NEXTVAL);
select * from ex2_8;
--������ ���簪
select my_seq1.CURRVAL FROM dual;
INSERT INTO ex2_8 (col1) VALUES(my_seq1.NEXTVAL);
--**���ǻ��� : .NEXTVAL�� select ������ ����ص� ������ ������ 
DROP SEQUENCE my_seq1;



--*******************
--��Ƽ�� ���̺� : ���̺� �ִ� Ư�� �÷����� �������� �����͸� ������ ������ ���°�. 
--������ ���̺��� 1�� ����, 
--���������δ� ������ ��ŭ ��Ƽ���� ������� �ԷµǴ� �÷����� ���� ���ҵ� ��Ƽ�Ǻ��� �����Ͱ� ����ȴ�. 
--����: ��뷮 ���̺��� ��� ������ ��ȸ�� ȿ������ ������ ���̱� ����
--����: RANGE, LIST, HASH, ���� ��Ƽ���� ������ ���� ��Ƽ�� 
--*******************
--e.g) sales ���̺� ������ 91���� ��ȸ�� �Ǹ�����(sales_date),�Ǹſ�(sales_month)�÷��� �̿��� ��ȸ�Ҷ��� ������ ��������.
--=> �Ǹſ�(sales_month)���� �����͸� ������ ���� ������ ��ȸ�� Ư�� ���� �������� �ɾ ��ȸ.

select count(*) from sales;
--sales ���̺��� ���̺���� SQL ������ partion ��Ʈ ����/


--=========================
--Self-Check

--1. ���̺� ���� ����
CREATE TABLE ORDERS (
    ORDER_ID        NUMBER(12,0)PRIMARY KEY
    , ORDER_DATE    DATE
    , ORDER_MODE    VARCHAR2(8 BYTE) constraints orders_check1 CHECK (order_mode in ('direct', 'online')) 
    , CUSTOMER_ID   NUMBER(6,0)
    , ORDER_STATUS  NUMBER(2,0)
    , ORDER_TOTAL   NUMBER(8,2) DEFAULT 0
    , SALES_REP_ID  NUMBER(6,0)
    , PROMOTION_ID  NUMBER(6,0)
);

--2. ���̺� ���� ����
CREATE TABLE ORDER_ITEMS (
    ORDER_ID        NUMBER(12,0)
    , LINE_ITEM_ID  NUMBER(3,0)
    , PRODUCT_ID    NUMBER(3,0)
    , UNIT_PRICE    NUMBER(8,2) DEFAULT 0
    , QUANTITY      NUMBER(8,0) DEFAULT 0
    , CONSTRAINTS "ORDER_ITEMS_PK" PRIMARY KEY(ORDER_ID, LINE_ITEM_ID)
);

--3. ���̺� ���� ����
CREATE TABLE PROMOTIONS (
    PROMO_ID        NUMBER(6,0) PRIMARY KEY
    , PROMO_NAME    VARCHAR2(20)
);

--4. FLOAT���� ��ȣ �ȿ� �����ϴ� ���� ������ ���� �ڸ������ �ߴ�. FLOAT(126)�� ��� 126*0.30103 = 37.92978�� �Ǿ� 
--NUMBER Ÿ���� 38�ڸ��� ����. �׷��� �� 0.30103�� ���ϴ��� �����غ��� 
--=> 10������ ��ȯ�ϱ� ���� ...?

--5. ������ ����� 
CREATE SEQUENCE ORDERS_SEQ 
    INCREMENT BY 1
    START WITH 1000
    MINVALUE 1
    MAXVALUE 99999999
    NOCYCLE
    NOCACHE
;
--��ŸƮ �� Ȯ�� 
select ORDERS_SEQ.NEXTVAL from dual; 
--���� �� ã��
select ORDERS_SEQ.CURRVAL from dual;

