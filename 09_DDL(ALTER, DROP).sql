/*
    <DDL(Data Definition Languagte)>
        데이터 정의 언어로 오라클에서 제공하는 객체를 만들고(CREAT), 변경하고(ALTER), 삭제하는(DROP) 등
        실제 데이터 값이 아닌 데이터의 구조 자체를 정의하는 언어로 DB 관리자, 설계자가 주로 사용
    
    <ALTER>
        오라클에서 제공하는 객체를 수정하는 구문이다.
        
    <테이블 수정>
        [표현법]
            ALTER TABLE 테이블명 수정할 내용;
            
            * 수정할 내용
            1) 컬럼 추가/수정/삭제
            2) 제약 조건 추가/삭제 --> 수정은 불가능(삭제한 후 새로 추가해야 한다.)
            3) 테이블명/컬럼명/제약조건명 변경
*/
-- 실습에 사용할 테이블 생성
CREATE TABLE DEPT_COPY
AS SELECT *
FROM DEPARTMENT;

SELECT * FROM DEPT_COPY;

--1) 컬럼 추가/수정/삭제
-- 1-1) 컬럼 추가(ADD) : ALTER TABLE 테이블명 ADD 컬럼명 데이터타입 [DEFAULT 기본값]
-- CNAME 컬럼을 맨 뒤에 추가한다.
-- 기본값을 지정하지 않으면 새로 추가된 컬럼은 NULL 값으로 채워진다.
ALTER TABLE DEPT_COPY ADD CNAME VARCHAR2(20);

-- LNAME 컬럼을 기본값을 지정한 채로 추가해보자.
ALTER TABLE DEPT_COPY ADD LNAME VARCHAR2(40) DEFAULT '한국';

-- 1-2) 컬럼 수정(MODIFY)
--      데이터 타입 변경 : ALTER TABLE 테이블명 MODIFY 컬럼명 변경할데이터타입 
--      기본값 변경     : ALTER TABLE 테이블명 MODIFY 컬럼명 DEFAULT 변경할 기본값
-- DEPT_ID 컬럼의 데이터 타입을 CHAR(3) 으로 변경
ALTER TABLE DEPT_COPY MODIFY DEPT_ID CHAR(3); -- DEPT_ID를 봐보면 띄어쓰기 공백이 하나씩 추가가 되어있다.
-- ALTER TABLE DEPT_COPY MODIFY DEPT_ID CHAR(2); -- 에러 발생
-- ALTER TABLE DEPT_COPY MODIFY DEPT_TITLE VARCHAR2(10); -- "cannot decrease column length because some value is too big" 가변이라고 해도 내가 바꾸려는 자료형의 크기인 10BYTE보다 이미 큰 공간을 차지하는 애들이 존재해서 오류
-- ALTER TABLE DEPT_COPY MODIFY DEPT_ID NUMBER; -- "column to be modified must be empty to change datatype" 데이터 타입이 불일치
ALTER TABLE DEPT_COPY MODIFY CNAME NUMBER; -- 아직 값이 없으면(NULL상태) 데이터 타입 변경 가능

-- 형변환 불가능 ***** 이해 못햇음 복습할 것 *****
ALTER TABLE DEPT_COPY ADD NUM VARCHAR2(20) DEFAULT '1';
ALTER TABLE DEPT_COPY MODIFY NUM MUMBER;

-- <다중 수정 : 한 번에 여러 개를 동시에 수정하는 것>
-- DEPT_TITLE 컬럼의 데이터 타입을 VARCHAR2(40)으로 바꿔보자.
-- LOCATION_ID 컬럼의 데이터 타입을 VARCHAR2(2)으로 바꿔보자.
-- LNAME 컬럼의 기본값을 '미국'으로 바꿔보자.
ALTER TABLE DEPT_COPY
MODIFY DEPT_TITLE VARCHAR2(40)
MODIFY LOCATION_ID VARCHAR2(2)
MODIFY LNAME DEFAULT '미국';

-- 1-3) 컬럼 삭제(DROP COLUMN) -- DROP 뒤에 뭘 삭제할 것인지 명시 / ALTER TABLE 테이블명 DROP COLUMN 컬럼명
-- 데이터 값이 기록되어 있어도 같이 삭제된다. (단, 삭제된 컬럼 복구는 불가능 = ROLLBACK 불가능)
-- 테이블에는 최소 한 개의 컬럼은 존재해야 한다.
-- 참조되고 있는 컬럼이 있다면 삭제 불가능

-- DEPT_ID 컬럼 지우기
ALTER TABLE DEPT_COPY DROP COLUMN DEPT_ID;

SELECT * FROM DEPT_COPY;

ROLLBACK; -- DDL 구문은 복구가 불가능하다.

ALTER TABLE DEPT_COPY DROP COLUMN DEPT_TITLE;
ALTER TABLE DEPT_COPY DROP COLUMN LOCATION_ID;
ALTER TABLE DEPT_COPY DROP COLUMN CNAME;
ALTER TABLE DEPT_COPY DROP COLUMN LNAME;
ALTER TABLE DEPT_COPY DROP COLUMN NUM; -- "cannot drop all columns in a table" 최소 한 개의 컬럼은 있어야 한다.

ALTER TABLE MEMBER_GRADE DROP COLUMN GRADE_CODE; -- "cannot drop parent key column" 부모 테이블의 컬럼은 참조되고 있는 컬럼이기 때문에 삭제가 불가능하다.
ALTER TABLE MEMBER_GRADE DROP COLUMN GRADE_CODE CASCADE CONSTRAINTS; -- 컬럼에 걸린 제약조건도 삭제한다.

SELECT * FROM MEMBER_GRADE;
SELECT * FROM MEMBER; -- 얘는 그대로, 자식 테이블에 영향을 주지는 않는다.

DROP TABLE MEMBER;
DROP TABLE MEMBER_GRADE;
DROP TABLE DEPT_COPY;

-------------------------------------------------------------------------------
-- 2) 제약조건 추가/삭제
-- 2-1) 제약조건 추가
--      PRIMARY KEY : ALTER TABLE 테이블명 ADD [CONSTRAINT 제약조건명] PRIMARY KEY(컬럼명);
--      FOREIGN KEY : ALTER TABLE 테이블명 ADD [CONSTRAINT 제약조건명] FOREIGN KEY(컬럼명) REFERENCES 테이블명 [(컬럼명)];
--      UNIQUE      : ALTER TABLE 테이블명 ADD [CONSTRAINT 제약조건명] UNIQUE(컬럼명); 
--      CHECK       : ALTER TABLE 테이블명 ADD [CONSTRAINT 제약조건명] CHECK(컬럼에 대한 조건);
--      NOT NULL    : ALTER TABLE 테이블명 MODIFY 컬럼명 [CONSTRAINT 제약조건명] NOT NULL;

-- 실습에 사용할 테이블 생성
CREATE TABLE DEPT_COPY
AS SELECT *
FROM DEPARTMENT;

SELECT * FROM DEPT_COPY;

-- DEPT_COPY 테이블에
-- DEPT_ID 컬럼에는 PK 제약조건을 추가하자.
-- DEPT_TITLE 컬럼에는 UNIQUE, NOT NULL 제약조건을 추가하자.
ALTER TABLE DEPT_COPY
ADD CONSTRAINT DEPT_COPY_DEPT_ID_PK PRIMARY KEY(DEPT_ID)
ADD CONSTRAINT DEPT_COPY_DEPT_TITLE_UQ UNIQUE(DEPT_TITLE)
MODIFY DEPT_TITLE CONSTRAINT DEPT_COPY_DEPT_TITLE_NN NOT NULL;

-- EMPLOYEE 테이블 DEPT_CODE, JOB_CODE에 FOREIGN KEY 제약조건을 적용시켜보자. (FOREIGN KEY는 개수 제한이 없다.)
ALTER TABLE EMPLOYEE
ADD CONSTRAINT EMPLOYEE_DEPT_CODE_FK FOREIGN KEY(DEPT_CODE) REFERENCES DEPARTMENT (DEPT_ID)
ADD CONSTRAINT EMPLOYEE_JOB_CODE_FK FOREIGN KEY(JOB_CODE) REFERENCES JOB (JOB_CODE);

-- 2-2) 제약조건 삭제
--      NOT NULL : MODIFY 컬럼명 NULL
--      나머지    : DROP CONSTRAINT 제약조건명

-- DEPT_COPY_DEPT_ID_PK 제약조건 삭제
ALTER TABLE DEPT_COPY
DROP CONSTRAINT DEPT_COPY_DEPT_ID_PK;

-- DEPT_COPY_DEPT_TITLE_UQ 제약조건 삭제 -> DROP
-- DEPT_COPY_DEPT_TITLE_NN 제약조건 삭제 -> MODIFY
ALTER TABLE DEPT_COPY
DROP CONSTRAINT DEPT_COPY_DEPT_TITLE_UQ
MODIFY DEPT_TITLE NULL;

-- ** 제약조건 수정은 불가능하다. 즉, 삭제 후 다시 제약 조건을 추가해야 한다.

-- 작성한 제약조건 확인
SELECT CONSTRAINT_NAME, 
       CONSTRAINT_TYPE, 
       UC.TABLE_NAME, 
       COLUMN_NAME
FROM USER_CONSTRAINTS UC
JOIN USER_CONS_COLUMNS UCC USING(CONSTRAINT_NAME)
WHERE UC.TABLE_NAME = 'DEPT_COPY';

-- 3) 테이블명 / 컬럼명 / 제약조건명 변경
-- 3-1) 컬럼명 변경      : ALTER TABLE 테이블명 RENAME COLUMN 기존컬럼명 TO 변경할컬럼명
-- DEPT_COPY 테이블에 DEPT_TITLE -> DEPT_NAME으로 변경해보자
ALTER TABLE DEPT_COPY RENAME COLUMN DEPT_TITLE TO DEPT_NAME;

-- 3-2) 제약조건명 변경   : ALTER TABLE 테이블명 RENAME CONSTRAINT 기존제약조건명 TO 변경할제약조건명
-- ALTER TABLE DEPT_COPY MODIFY DEPT_NAME NOT NULL;
ALTER TABLE DEPT_COPY RENAME CONSTRAINT SYS_C007136 TO DEPT_COPY_DEPT_NAME_NN;

-- 3-3) 테이블명 변경 
--      1> ALTER TABLE 테이블명 RANAME TO 변경할테이블명 -> 테이블 객체 이름을 수정할거야
--      2> RENAME 기존테이블명 TO 변경할테이블명 ->DEPT_COPY라는 객체의 이름을 수정할거야
-- DEPT_COPY --> COPY_TEST
ALTER TABLE DEPT_COPY RENAME TO DEPT_TEST;
RENAME DEPT_COPY TO DEPT_TEST;

SELECT * FROM DEPT_TEST;

---------------------------------------------------------------------------------------------
/*
    <DROP>
        데이터베이스 객체를 삭제하는 구문
*/
-- 테이블 삭제
DROP TABLE DEPT_TEST;

-- 단, 참조되고 있는 부모 테이블은 함부로 삭제가 되지 않는다. (참조 무결성 유지가 되지 않기 때문에 삭제되지 않는다.)
-- 따라서 삭제하고자 한다면 
-- 1) 자식 테이블 먼저 삭제한 후 부모 테이블을 삭제한다.
DROP TABLE MEMBER;
DROP TABLE MEMBER_GRADE;
-- 2) 자식 테이블은 삭제하면 데이터가 다 날아가니까 부모 테이블만 삭제하고 싶어 => 부모 테이블을 삭제 할 때 제약 조건도 함께 삭제하는 방법
DROP TABLE MEMBER_GRADE CASCADE CONSTRAINT;

-- 부모 테이블
CREATE TABLE MEMBER_GRADE (
    GRADE_CODE NUMBER PRIMARY KEY,
    GRADE_NAME VARCHAR2(30) NOT NULL  
);

INSERT INTO MEMBER_GRADE VALUES(10, '일반회원');
INSERT INTO MEMBER_GRADE VALUES(20, '우수회원');
INSERT INTO MEMBER_GRADE VALUES(30, '특별회원');

-- 자식 테이블
CREATE TABLE MEMBER (
    MEMBER_NO NUMBER CONSTRAINT MEMBER_MEMBER_NO_PK PRIMARY KEY,
    MEMBER_ID VARCHAR2(20) NOT NULL,
    MEMBER_PWD VARCHAR2(20) NOT NULL,
    MEMBER_NAME VARCHAR2(20) CONSTRAINT MEMBER_MEMBER_NAME_NN NOT NULL,
    GENDER CHAR(3) CHECK(GENDER IN('남','여')),
    AGE NUMBER CHECK(AGE > 0),
    GRADE_ID NUMBER REFERENCES MEMBER_GRADE(GRADE_CODE),
    MEMBER_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT MEMBER_MEMBER_ID_UQ UNIQUE(MEMBER_ID)
);

INSERT INTO MEMBER VALUES(1, 'USER1', '1234', '춘향이', '여', 20, 10, DEFAULT);
INSERT INTO MEMBER VALUES(2, 'USER2', '1234', '홍길동', '남', 25, NULL, DEFAULT);

SELECT * FROM MEMBER_GRADE;
SELECT * FROM MEMBER;
