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

--기본키(PK)
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

--테이블 복사
CREATE TABLE ex2_9_1 as
select * from ex2_9;

select * from ex2_9_1;


--*******************
--View
--*******************
--사원정보 조회시 부서명 볼수있게 
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
CREATE UNIQUE INDEX EX2_10_IX01 --인덱스명
ON EX2_10(COL11); --인덱스 지정 테이블(컬럼) 

--인덱스 확인
SELECT * FROM USER_INDEXES WHERE TABLE_NAME = 'EX2_10';

--별도의 unique index를 생성하지 않아도, 유니크 제약조건을 설정하면 유니크 인덱스가 생성됨  
select constraint_name, constraint_type, table_name, index_name
from user_constraints
where table_name = 'JOB_HISTORY'
;

select index_name, index_type, table_name, uniqueness
from user_indexes
where table_name = 'JOB_HISTORY'
;

--한개 이상의 컬럼으로 인덱스 생성
CREATE INDEX ex2_10_ix02
ON ex2_10(col11, col2);

select * from user_indexes where table_name = 'EX2_10';

--인덱스 삭제
DROP INDEX ex2_10_ix02;



--*******************
--시노님 (public, private)
--*******************
--public 생략시 private 시노님 생성됨 
CREATE OR REPLACE SYNONYM syn_channel
FOR channels; --For 이하의 객체에는 테이블, 뷰, 프로시저, 함수, 패키지, 시퀀스 등이 올수 있음

select count(*) from syn_channel;

--다른 사용자로 접속해 시노님 참고해보기 ========
-- HR 사용자 접속 전 계정 해제
ALTER USER hr identified by hr Account unlock;
--다른 사용자로 접속해 시노님 참고해보기 ========

--퍼블릭 시소님 생성
CREATE OR REPLACE PUBLIC SYNONYM syn_channel2
For channels;

select count(*) from syn_channel2;

GRANT SELECT ON syn_channel2 TO public;

--시노님 삭제 (권한있어야 삭제가능)
DROP SYNONYM syn_channel;
DROP PUBLIC SYNONYM syn_channel2; --퍼블릭 시노님 삭제시 PUBLIC 명시 필


--*******************
--시퀀스 :자동순번을 반환하는 데이터베이스 객체
--*******************
CREATE SEQUENCE --시퀀스명 
INCREMENT BY --증감숫자 (0이 아닌정수. 양수면 증가, 음수면 감소, 디폴트=1)
START WITH --시작숫자 (디폴트값은 증가일때는 MINVALUE, 감소일때는 MAXVALUE)
NOMINVALUE | MINVALUE --최솟값 
NOMAXVALUE | MAXVALUE --최댓값
NOCYCLE | CYCLE --NoCycle: 최대나 최솟값에 도달하면 생성중지. Cycle: 다시 최대/최솟값부터 시작. 
NOCACHE | CACHE; --NoCache: 디폴트로 메모리에 시퀀스값을 미리 할당해 놓지 않으며 디폴트값은 20.  Cache: 메모리에 시퀀스값을 미리 할당해 놓음
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
--시퀀스 현재값
select my_seq1.CURRVAL FROM dual;
INSERT INTO ex2_8 (col1) VALUES(my_seq1.NEXTVAL);
--**주의사항 : .NEXTVAL을 select 문에서 사용해도 시퀀스 증가함 
DROP SEQUENCE my_seq1;



--*******************
--파티션 테이블 : 테이블에 있는 특정 컬럼값을 기준으로 데이터를 분할해 저장해 놓는것. 
--논리적인 테이블은 1개 지만, 
--물리적으로는 분할한 만큼 파티션이 만들어져 입력되는 컬럼값에 따라 분할된 파티션별로 데이터가 저장된다. 
--목적: 대용량 테이블의 경우 데이터 조회시 효율성과 성능을 높이기 위함
--종류: RANGE, LIST, HASH, 여러 파티션을 조합한 복합 파티션 
--*******************
--e.g) sales 테이블 데이터 91만건 조회시 판매일자(sales_date),판매월(sales_month)컬럼을 이용해 조회할때의 성능을 높여보자.
--=> 판매월(sales_month)별로 데이터를 분할해 놓고 데이터 조회시 특정 월을 조건으로 걸어서 조회.

select count(*) from sales;
--sales 테이블의 테이블생성 SQL 구문중 partion 파트 참고/


--=========================
--Self-Check

--1. 테이블 구조 생성
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

--2. 테이블 구조 생성
CREATE TABLE ORDER_ITEMS (
    ORDER_ID        NUMBER(12,0)
    , LINE_ITEM_ID  NUMBER(3,0)
    , PRODUCT_ID    NUMBER(3,0)
    , UNIT_PRICE    NUMBER(8,2) DEFAULT 0
    , QUANTITY      NUMBER(8,0) DEFAULT 0
    , CONSTRAINTS "ORDER_ITEMS_PK" PRIMARY KEY(ORDER_ID, LINE_ITEM_ID)
);

--3. 테이블 구조 생성
CREATE TABLE PROMOTIONS (
    PROMO_ID        NUMBER(6,0) PRIMARY KEY
    , PROMO_NAME    VARCHAR2(20)
);

--4. FLOAT형은 괄호 안에 지정하는 수는 이진수 기준 자릿수라고 했다. FLOAT(126)의 경우 126*0.30103 = 37.92978이 되어 
--NUMBER 타입의 38자리와 같다. 그런데 왜 0.30103을 곱하는지 설명해보자 
--=> 10진수로 변환하기 위해 ...?

--5. 시퀀스 만들기 
CREATE SEQUENCE ORDERS_SEQ 
    INCREMENT BY 1
    START WITH 1000
    MINVALUE 1
    MAXVALUE 99999999
    NOCYCLE
    NOCACHE
;
--스타트 값 확인 
select ORDERS_SEQ.NEXTVAL from dual; 
--현재 값 찾기
select ORDERS_SEQ.CURRVAL from dual;

