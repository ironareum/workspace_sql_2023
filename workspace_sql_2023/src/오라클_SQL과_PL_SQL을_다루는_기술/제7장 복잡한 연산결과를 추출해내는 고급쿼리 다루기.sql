/*
 * 1. ������ ����
 * 2. WITH��
 * 3. �м��Լ��� window �Լ�
 * 4. �������̺� INSERT 
 */

--## 1. ������ ����
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
