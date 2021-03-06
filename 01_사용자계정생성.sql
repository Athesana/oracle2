-- 한 줄짜리 주석
/*
    여러줄 주석
*/
-- 사용자 계정 생성하는 구문(SYSTEM이나 SYS계정만 가능, 관리자 계정만이 할 수 있다.)
-- [표현법] CREATE USER 계정명 IDENTIFIED BY 계정비밀번호;
CREATE USER KH IDENTIFIED BY KH;
--> Ctrl + Enter : SYSTEM 계정으로 실행시킨다.
-- 콘솔 : User KH이(가) 생성되었습니다.

-- 생성 후 , 권한부여를 실행 시켜야 한다.

-- 위에서 만든 사용자 계정에게 초소한의 권한(데이터관리, 접속) 부여
GRANT RESOURCE, CONNECT TO KH;
--> 리소스 = 테이블, 오브젝트, 뷰, 시퀀스, 함수, 프로시저를 생성할 수 있는 권한, 커넥트 = 권한을 주어야 디벨로퍼를 통해서 계정으로 접속이 가능하다.
-- 콘솔 : Grant을(를) 성공했습니다.

-- 작업 후 왼쪽 오라클 접속에서 새로고침 후, 다른 사용자에 보면 KH 계정이 생성되어 있다. 


/*새로 만들기/데이터 베이스 접속

- 시스템으로 접속해서 새로운 계정을 만든다.
- 오라클은 관리자 계정이 2개이다. SYSTEM 계정이 있고 SYS 계정이 있다. 
 
 <SYS>
  : 슈퍼 사용자 계정
    데이터 베이스에서 발생하는 DB생성, 테이블 생성에 대한 권한을 가지고 있다.
    모든 문제를 처리할 수 있는 권한을 가지고 있다.
 <SYSTEM>
  : 유사한 권한을 가지고 있지만 데이터 베이스 생성과 삭제는 불가능하다.
    운영을 위한 필요한 관리자 권한만 가지고 있다.
    
    
- 처음 세팅할 때
1. Enviroment 인코딩 UTF-8로 바꾸기
2. 코드 편집기 -> 표시 -> 표시되는 오른쪽 여백 표시 체크 해제
3. 코드 편집기 -> 행 표시 체크


*/

--------------------------------------------VIEW
-- SYSTEM 계정으로 접속중...
-- RESOURCE에서는 뷰를 만드는 권한은 없다. 따라서 뷰를 만드는 권한을 추가 시켜 줘야 한다.
/*
<GRANT RESOURCE, CONNECT TO ~> 
SELECT *
FROM ROLE_SYS_PRIVS
WHERE ROLE = 'RESOURCE';
를 기본으로 조회해보면
CREATE SEQUENCE
CREATE TRIGGER
CREATE CLUSTER
CREATE PROCEDURE
CREATE TYPE
CREATE OPERATOR
CREATE TABLE
CREATE INDEXTYPE
이 있다.

SELECT *
FROM ROLE_SYS_PRIVS
WHERE ROLE = 'CONNECT';
를 기본으로 조회해보면
CREATE SESSION
이 나온다.
 = 세션을 만들어서 접속할 수 있다.
*/

-- 사용자 계정의 권한을 확인하는 구문
-- ROLE(권한)을 집합으로 묶어놓은 것 = RESOURCE
SELECT *
FROM ROLE_SYS_PRIVS
WHERE ROLE = 'RESOURCE';
-- 아직 VIEW를 CREATE하는 ROLE은 없다.
-- WHERE ROLE = 'CONNECT'; -- 데이터베이스에 접근할 수 있는 권한

GRANT CREATE VIEW TO KH;

