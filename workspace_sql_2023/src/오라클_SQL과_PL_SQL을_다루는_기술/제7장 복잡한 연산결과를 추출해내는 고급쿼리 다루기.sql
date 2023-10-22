/*
 * 1. 계층형 쿼리
 * 2. WITH절
 * 3. 분석함수와 window 함수
 * 4. 다중테이블 INSERT 
 */

--## 1. 계층형 쿼리
/* 계층형쿼리란, 2차원 형태의 테이블에 저장된 데이터를 계층형 구조로 결과를 반환하는 쿼리를 말한다. (=상하수직관계의 구조) 
 * 
 * 계층쿼리 사용법 : SELECT expr1, expr2 ..
 *          FROM 테이블
 *         WHERE 조건
 *        START WITH [최상위조건] --계층형 구조에서 최상위 계층의 로우를 식별하는 조건을 명시. 
 *        CONNECT BY [NOCYCLE][PRIOR 계층형 구조 조건]  --계층형구조가 어떤식으로 연결되는지를 기술하는 부분 (부서테이블은 parent_id에 상위부서정보를 가지고 있는데 이를 표현하려면 connect by prior department_id = parent_id; 로 기술해야함.
 * 
 * LPAD 사용법 : LPAD(값, 총문자길이, 채움문자) --지정한 길이만큼 왼쪽부터 채움문자로 채운다. (채운문자를 지정하지 않으면 공백으로 해당길이만큼 채움)
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
