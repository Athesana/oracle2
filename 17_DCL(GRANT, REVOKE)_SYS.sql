/*
    <DCL(DATA CONTROL LANGUAGE)>
        계정에게 시스템 권한 또는 객체에 대한 접근 권한을 부여(GRANT)하거나 회수(REVOKE)하는 언어이다.
        
        시스템 권한의 종류
            - CREATE SESSION    : 데이터 베이스에 접속할 수 있는 권한
            - CREATE TABLE      : 테이블을 생성할 수 있는 권한
            - CREATE VIEW       : 뷰를 생성할 수 있는 권한
            - CREATE SEQUENCE   : 시퀀스를 생성할 수 있는 권한
            - CREATE PROCEDURE  : 프로시저를 생성할 수 있는 권한
            - CREATE USER       : 계정을 생성할 수 있는 권한
            등등 ...
            
        [표현법]
            GRANT 권한1, 권한2, ... TO 사용자계정명;
            REVOKE 권한1, 권한2, ... FROM 사용자계정명;
*/
-- SYSTEM 계정으로 접속중...
-- 1. 계정 생성
CREATE USER SAMPLE IDENTIFIED BY SAMPLE;

-- 2. 계정에 접속하기 위해 위에서 CREATE SESSION 권한 부여
GRANT CREATE SESSION TO SAMPLE;

-- 3. 계정에서 테이블을 생성할 수 있는 CREATE TABLE 권한을 부여
GRANT CREATE TABLE TO SAMPLE;

-- 4. 테이블 스페이스 할당 : 테이블, 뷰, 인덱스 등 객체들이 저장되는 공간
ALTER USER SAMPLE QUOTA 2M ON SYSTEM;

------------------------------------------------------------------
/*
    <객체 권한>
    특정 객체를 조작할 수 있는 권한
    
    <권한 종류    |  설정 객체>
    SELECT      : TABLE, VIEW, SEQUENCE 
    INSERT      : TABLE, VIEW
    UPDATE      : TABLE, VIEW
    DELETE      : TABLE, VIEW
    ALTER       : TABLE, SEQUENCE
    등등 .. 
    
    [표현법]
        GRANT 권한종류 ON 특정객체 TO 계정;
        REVOKE 권한종류 ON 특정객체 FROM 계정;
*/

-- 5. KH.EMPLOYEE 테이블을 조회할 수 있는 권한 부여 
GRANT SELECT ON KH.EMPLOYEE TO SAMPLE;

-- 6. KH.DEPARTMENT 테이블을 조회할 수 있는 권한 부여
GRANT SELECT ON KH.DEPARTMENT TO SAMPLE;

-- 7. KH.DEPARTMENT 테이블에 데이터를 삽입 할 수 있는 권한 부여
GRANT INSERT ON KH.DEPARTMENT TO SAMPLE;

-- 8. KH.DEPARTMENT 테이블에 데이터를 삽입 할 수 있는 권한 회수
REVOKE INSERT ON KH.DEPARTMENT FROM SAMPLE;

-- 9. 모든 테이블에 대한 조회 권한 설정
-- GRANT SELECT ANY TABLE TO SAMPLE;

-- 10. 모든 테이블에 대한 조회 권한 회수
-- REVOKE SELECT ANY TABLE FROM SMAPLE;
