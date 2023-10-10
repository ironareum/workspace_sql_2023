select count(*) from ora_user.syn_channel;

--권한확인
SELECT * FROM DBA_SYS_PRIVS
WHERE GRANTEE = 'hr' ;

--권한확인
select grantee, table_name, grantor, privilege from user_tab_privs;
--권한주기
Grant select on syn_channel TO hr;

--public synonym은 소유자명 안붙여도 됨 (이유: 소유자가 ora_user 가 아닌 public 이기때문)
select count(*) from syn_channel2;
