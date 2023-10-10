--3장 SQL 문장 살펴보기
--#01 SELECT 문
SELECT EMPLOYEE_ID, EMP_NAME
FROM EMPLOYEES
WHERE SALARY > 5000;

--#02 INSERT 문
CREATE TABLE ex3_1 (
    col1      VARCHAR2(10),
    col2      NUMBER,
    col3      DATE
); 

--다른 테이블이나 뷰의 조회 결과로 나온 데이터를 또 다른테이블네 넣는 형식 
CREATE TABLE ex3_2 (
    emp_id      NUMBER,
    emp_name    VARCHAR2(100)    
);
INSERT INTO ex3_2(emp_id, emp_name)
SELECT employee_id, emp_name
FROM employees
WHERE salary > 5000;

--묵시적 형변환
desc ex3_1;


--#03 UPDATE 문
--where 절에 빈값 찾을때는 반드시 'IS NULL'로 찾기



--#04 MERGE 문 (insert/update)
MERGE INTO /* [스키마].테이블명 */
    USING ( /* update나 insert 될 데이터 원전*/)
    ON (/* update될 조건*/)
WHEN MATCHED THEN
    UPDATE SET /* 컬럼1 = 값1, 컬럼2 = 값2 ... */
    WHERE /* update 조건 */
    --삭제 필요시 
    DELETE WHERE /* update_delete 조건 */
WHEN NOT MATCHED THEN
    INSERT (/* 컬럼1, 컬럼2 .. */) VALUES ( /* 값1, 값2 ... */ )
    WHERE  (/* insert 조건 */)
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
GROUP BY E.EMPLOYEE_ID --사원번호 중복제거 
;
/*
148	0
153	0
154	0
155	0
160	7.5
161	70 --> 삭제됨 
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

--갱신대상 
select employee_id, manager_id, salary, salary * 0.01
from employees
where employee_id in (select employee_id from ex3_3) 
    and manager_id = '146'
    --and salary < 8000
;
--insert 대상 
select employee_id, manager_id, salary, salary * 0.001
from employees
where employee_id not in (select employee_id from ex3_3) 
    and manager_id = '146'
    and salary < 8000
;

--#05 DELETE 
--특정 파티션의 데이터만 삭제
DELETE FROM /*테이블명*/ PARTITION /*파티션명*/
WHERE /*delete 조건*/
;
--파티션명 조회
select * from user_tab_partitions
where table_name = 'SALES';


--#06 COMMIT과 ROLLBACK, TRUNCATE
CREATE TABLE ex3_4 (
    employee_id NUMBER
);
INSERT INTO ex3_4 VALUES(100);
select * from ex3_4;
--커밋전까진 현재세션에서만 볼수있음. (터미널에서 조회시 레코드 없음) 즉, DB에 반영된 상태가 아님
COMMIT;
--ROLLBACK;

--TRUNCATE (테이블 전체삭제. 주의해서 사용!!)
--1)DELETE(DML)문은 데이터 삭제 후 COMMIT을 실행해야 데이터가 완전히 삭제되고, ROLLBACK을 실행하면 삭제된 데이터가 복귀된다. 
--2)TRUNCATE(DDL)실행시 데이터가 바로 삭제되고 ROLLBACK 실행해도 복귀안됨. 또한 WHERE 조건을 붙일수 없음.   
--TRUNCATE TABLE ex3_4
;



--#07 의사컬럼(psudo-column)
--테이블의 컬럼처럼 동작하지만 실제로 테이블에 저장되지는 않는 컬럼
--SELECT 문에서 사용할수 있지만, 의사컬럼의 값을 INSERT, UPDATE, DELETE 할수는 없다.
--종류1) NEXTVAL, CURRVAL(시퀀스에서 사용하는 의사컬럼)
--종류2) CONNECT_BY_IS_CYCLE, CONNECT_BY_ISLEAF, LEVEL (계층형 쿼리에서 사용하는 의사컬럼)
--종류3) ROWNUM, ROWID 

--ROWNUM : 테이블 데이터를 간략히 보기 편함
SELECT ROWNUM, employee_id
FROM employees where rownum <5;

--ROWID : 테이블에 저장된 각 로우가 저장된 주소값을 가리킴 (각 로우를 식별하는 값이며, 유일한 값임)
SELECT ROWNUM, employee_id, ROWID
FROM employees where rownum <5;


--#08 연산자(Operator)
--수식연산자: +, -, *, /
--문자연산자: ||
--논리연산자: >, <, =, <> 등
--집합연산자: UNION, UNION ALL, INTERSECT, MINUS (5장 참고)
--계층형 쿼리 연산자: PRIOR, CONNECT_BY_ROOT (7장 참고)


--#09 표현식 (한개 이상의 값과 연산자, SQL함수 등이 결합된 식)
--CASE
CASE WHEN 조건1 THEN 값1
     WHEN 조건2 THEN 값2
     ELSE 기타값
END
;

SELECT employee_id, salary, 
    CASE WHEN salary <= 5000 THEN 'C등급'
         WHEN salary > 5000 AND salary <= 15000 THEN 'B등급'
         ELSE 'A등급'
    END AS salary_grade     
FROM employees;



--#10 조건식 (한개 이상의 표현식과 논리 연산자가 결합된 식으로 TRUE, FALSE, UNKNOWN 3가지 타입 반환함)
--비교조건식: ANY, SOME, ALL
--ANY/SOME = OR (ANY는 =, >, < <>, != 등도 사용가능) 
--ALL = AND

--논리조건식: AND, OR, NOT

--NULL 조건식: IS NULL, IS NOT NULL

--BETWEEN, AND 조건식
--BETWEEN = '>=', '<=' 

--IN= OR
--NOT IN = '<>ALL'

--EXISTS : IN과 비슷하지만 후행 조건절로 서브쿼리만 올수있고 서브쿼리 내에서 조인조건이 있어야함 (6장 참고)

--LIKE (문자패턴 조회. 대소문자 구분)
--_ (한글자만 비교)



--==================================================
--Self-Check
;
--1. 다른 테이블의 데이터로 테이블 생성 
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

--3. 추출 쿼리
select employee_id, emp_name 
from employees
where commission_pct is null;

--4. 논리연산자로 변환
--오리지널 쿼리
SELECT employee_id, salary
from employees
where salary BETWEEN 2000 AND 2500
ORDER BY employee_id;
--변환하기
SELECT employee_id, salary
from employees
where salary >= 2000 AND salary <= 2500
ORDER BY employee_id;


--5. ANY, ALL 사용
SELECT employee_id, salary
from employees
where salary IN (2000, 3000, 4000)
ORDER BY employee_id;

SELECT employee_id, salary
FROM employees
WHERE salary NOT IN (2000, 3000, 4000)
ORDER BY employee_id;

--변환하기 
SELECT employee_id, salary
from employees
where salary = ANY (2000, 3000, 4000)
ORDER BY employee_id;

SELECT employee_id, salary
FROM employees
WHERE salary <> ALL (2000, 3000, 4000)
ORDER BY employee_id;


--비교해보기 
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


