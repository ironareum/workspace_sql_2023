select count(*) from ora_user.syn_channel;

--����Ȯ��
SELECT * FROM DBA_SYS_PRIVS
WHERE GRANTEE = 'hr' ;

--����Ȯ��
select grantee, table_name, grantor, privilege from user_tab_privs;
--�����ֱ�
Grant select on syn_channel TO hr;

--public synonym�� �����ڸ� �Ⱥٿ��� �� (����: �����ڰ� ora_user �� �ƴ� public �̱⶧��)
select count(*) from syn_channel2;
