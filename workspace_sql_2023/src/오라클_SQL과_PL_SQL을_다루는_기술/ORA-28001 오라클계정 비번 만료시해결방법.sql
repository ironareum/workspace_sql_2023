--cmd 창 열고 

--1. 계정 접속 : 
sqlplus "/as sysdba


--2. 계정비번 재설정 :
alter user ora_user identified by ora_user;

--3. 혹시, 비밀번호 만료기간 없애고 싶을때 : 
alter profile default limit password_life_time unlimited; 
