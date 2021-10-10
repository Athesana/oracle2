/*
    <DDL(Data Definition Languagte)>
        데이터 정의 언어로 오라클에서 제공하는 객체를 만들고(CREAT), 변경하고(ALTER), 삭제하는(DROP) 등
        실제 데이터 값이 아닌 데이터의 구조 자체를 정의하는 언어로 DB 관리자, 설계자가 주로 사용
        
        * 오라클에서의 객체 : 테이블, 뷰, 시퀀스, 인덱스, 트리거, 프로시저, 함수, 동의어, 사용자 등
        
    <CREATE>
        데이터 베이스 객체를 생성하는 구문이다.
    
    <테이블 생성>
        행과 열로 구성되는 가장 기본적인 데이터 베이스 객체로 데이터베이스 내에서 모든 데이터는 테이블에 저장된다.
        
        [표현식]
            CREATE TABLE 테이블명 (
              컬럼명 자료형(크기) [DEFAULT 기본값] [제약조건],
              컬럼명 자료형(크기) [DEFAULT 기본값] [제약조건],
              ...
            );
*/

-- 회원에 대한 데이터를 담을 수 있는 MEMBER 테이블 생성
-- DATE 부분 : 기본값을 지정할 수 있다. (회원가입할 시기의 시스템 시간을 기본값)
CREATE TABLE MEMBER (
    MEMBER_ID VARCHAR2(20),
    MEMBER_PWD VARCHAR2(20),
    MEMBER_NAME VARCHAR2(20),
    MEMBER_DATE DATE DEFAULT SYSDATE
);

DROP TABLE MEMBER;

-- 만든 테이블 확인
DESC MEMBER; -- 테이블의 구조를 표시해 주는 구문이다.
SELECT * FROM MEMBER;

/*
    <컬럼에 주석 달기>
        [표현법]
            COMMENT ON COLUMN 테이블명.컬럼명 IS '주석내용';
*/

COMMENT ON COLUMN MEMBER.MEMBER_ID IS '회원아이디';
COMMENT ON COLUMN MEMBER.MEMBER_PWD IS '비밀번호';
COMMENT ON COLUMN MEMBER.MEMBER_NAME IS '회원이름';
COMMENT ON COLUMN MEMBER.MEMBER_DATE IS '회원가입일';

/*
    <데이터 딕셔너리 (a.k.a 메타 데이터)>
        자원을 효율적으로 관리하기 위한 다양한 객체들의 정보를 저장하는 시스템 테이블이다.
        사용자가 객체를 생성하거나 객체를 변경하는 등의 작업을 할 때 데이터베이스에 의해서 자동으로 갱신되는 테이블이다.
        데이터에 관한 데이터가 저장되어 있다고 해서 메타 데이터라고도 한다.
        
    USER_TABLES : 사용자가 가지고 있는 테이블들의 전반적인 구조를 확인하는 뷰 테이블이다.
    USER_TAB_COLUMNS : 테이블, 뷰의 컬럼과 관련된 정보를 조회하는 뷰 테이블이다.
*/
SELECT * FROM USER_TABLES WHERE TABLE_NAME = 'MEMBER';
SELECT * FROM USER_TAB_COLUMNS WHERE TABLE_NAME = 'MEMBER';

-- 테이블에 샘플 데이터추가 (INSERT)
-- INSERT INTO 테이블명[(컬럼명, ..., 컬럼명)] VALUES (값, 값, ...);
-- [(컬럼명, ..., 컬럼명)] 생략하게 되면 순서에 맞게 차례대로 다 기입해주어야 한다., 기입하면 기입한 순서에 맞게 VALUES 뒤에 값을 넣어준다.
INSERT INTO MEMBER VALUES('USER1', '1234', '홍길동', '2021-10-06');
INSERT INTO MEMBER VALUES('USER2', '1234', '김철수', SYSDATE);
INSERT INTO MEMBER VALUES('USER2', '1234', '김철수', DEFAULT);
INSERT INTO MEMBER(MEMBER_ID, MEMBER_PWD, MEMBER_NAME) VALUES('USER2', '1234', '김철수');

SELECT * FROM MEMBER;

-- 위에서 테이블에 추가한 데이터를 실제 데이터 베이스에 반영한다. (커밋 전에는 메모리 버퍼에 임시저장 된 데이터, 이것을 실제 테이블에 반영하는 명령어)
COMMIT;

SHOW AUTOCOMMIT; 
-- 대부분은 AUTOCOMIIT OFF가 되어있다.
-- SET AUTOCOMMIT ON;
-- SET AUTOCOMMIT OFF;

---------------------------------------------------------------------
/*
    <제약 조건(CONSTRAINTS)>
        사용자가 원하는 조건의 데이터만 유지하기 위해서 테이블 작성 시 각 컬럼에 대해 저장될 값에 제약 조건을 설정할 수 있다.
        제약 조건은 데이터 무결성 보장을 목적으로 한다. (데이터의 정확성과 일관성을 유지시키는 것)
        
        * 종류 : NOT NULL, UNIQUE, CHECK, PRIMARY KEY, FOREIGN KEY
        
        [표현법]
            1) 컬럼 레벨
                CREATE TABLE 테이블명 (
                    컬럼명 자료형(크기) [CONSTRAINT 제약조건명] 제약조건, 
                    ...
                );
            2) 테이블 레벨 
                CREATE TABLE 테이블명 (
                    컬럼명 자료형(크기), 
                     ...
                     [CONSTRAINT 제약조건명] 제약조건 (컬럼명)
                 );
*/

-- 제약 조건 확인
DESC USER_CONSTRAINTS;
SELECT * FROM USER_CONSTRAINTS; -- 사용자가 작성한 제약조건을 확인하는 뷰

DESC USER_CONS_COLUMNS;
SELECT * FROM USER_CONS_COLUMNS; -- 제약조건이 걸려있는 컬럼을 확인하는 뷰

/*
    <NOT NULL 제약 조건>
        해당 컬럼에 반드시 값이 있어야만 하는 경우 사용한다.
        삽입 / 수정 시 NULL 값을 허용하지 않도록 제한한다.
*/
-- 기존 MEMBER 테이블에는 값에 NULL이 있어도 삽입이 가능하다.
INSERT INTO MEMBER VALUES(NULL, NULL, NULL, NULL);
SELECT * FROM MEMBER;

-- NOT NULL 제약조건을 설정한 테이블 만들기
-- NOT NULL 제약조건은 컬럼 레벨에서만 설정이 가능하다.

DROP TABLE MEMBER;

CREATE TABLE MEMBER (
    MEMBER_ID VARCHAR2(20) NOT NULL,
    MEMBER_PWD VARCHAR2(20) NOT NULL,
    MEMBER_NAME VARCHAR2(20) NOT NULL,
    MEMBER_DATE DATE DEFAULT SYSDATE
);
-- NOT NULL 제약 조건에 위배되어 오류 발생
INSERT INTO MEMBER VALUES(NULL, NULL, NULL, NULL);
-- NOT NULL 제약 조건이 걸려있는 컬럼에는 반드시 값이 있어야 한다. 하나라도 빠질 경우 오류 발생하고 행이 삽입되지 않는다.
-- NULL도 값이기 때문에 DEFAULT으로 적지 않으면 NULL로 삽입이 된다.
INSERT INTO MEMBER VALUES('USER1', '1234', '홍길동', NULL);
INSERT INTO MEMBER VALUES('USER2', '1234', '길동이', DEFAULT);

DESC MEMBER;  -- 테이블 구조 확인할 수 있다. NOT NULL로 조건이 잘 적혀있다.
SELECT * FROM MEMBER;

/*
    <UNIQUE 제약조건>
        컬럼의 입력 값에 중복 값을 제한하는 제약 조건이다.
        데이터를 삽입/수정 시 기존에 있는 데이터 값 중에 중복 값이 있을 경우 삽입/수정이 되지 않는다.
        제약조건 지정 방식으로 컬럼 레벨, 테이블 레벨 방식 모두 사용 가능하다.
*/
-- 아이디가 중복됐음에도 성공적으로 데이터가 삽입된다.
INSERT INTO MEMBER VALUES('USER1', '1234', '아무개', DEFAULT);
INSERT INTO MEMBER VALUES('USER1', '1234', '아무개', DEFAULT);

SELECT * FROM MEMBER;

DROP TABLE MEMBER;

CREATE TABLE MEMBER (
    MEMBER_ID VARCHAR2(20) NOT NULL UNIQUE,
    MEMBER_PWD VARCHAR2(20) NOT NULL,
    MEMBER_NAME VARCHAR2(20) NOT NULL,
    MEMBER_DATE DATE DEFAULT SYSDATE
);

INSERT INTO MEMBER VALUES('USER1', '1234', '아무개', DEFAULT);
INSERT INTO MEMBER VALUES('USER1', '1234', '아무개', DEFAULT);

DROP TABLE MEMBER;

/*
실습 중에는 제약조건 이름 설정할 때 RULE --> 테이블명_제약조건이걸려있는컬럼명_제약조건의약자
*/
CREATE TABLE MEMBER (
    MEMBER_ID VARCHAR2(20) NOT NULL,
    MEMBER_PWD VARCHAR2(20) NOT NULL,
    MEMBER_NAME VARCHAR2(20) CONSTRAINT MEMBER_MEMBER_NAME_NN NOT NULL,
    MEMBER_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT MEMBER_MEMBER_ID_UQ UNIQUE(MEMBER_ID)
);

INSERT INTO MEMBER VALUES('USER1', '1234', '아무개', DEFAULT); -- 삽입 가능
INSERT INTO MEMBER VALUES('USER1', '1234', '아무개', DEFAULT); -- 제약조건에 따라 오류 발생

DROP TABLE MEMBER;

-- 여러 개의 컬럼을 묶어서 하나의 UNIQUE 제약 조건을 설정하는 것도 가능하다. (단, 반드시 테이블 레벨로만 설정이 가능하다.)

CREATE TABLE MEMBER (
    MEMBER_NO NUMBER NOT NULL,
    MEMBER_ID VARCHAR2(20) NOT NULL,
    MEMBER_PWD VARCHAR2(20) NOT NULL,
    MEMBER_NAME VARCHAR2(20) CONSTRAINT MEMBER_MEMBER_NAME_NN NOT NULL,
    MEMBER_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT MEMBER_MEMBER_ID_UQ UNIQUE(MEMBER_NO, MEMBER_ID)
);


-- 작성한 제약조건 확인
SELECT CONSTRAINT_NAME, 
       CONSTRAINT_TYPE, 
       UC.TABLE_NAME, 
       COLUMN_NAME
FROM USER_CONSTRAINTS UC
JOIN USER_CONS_COLUMNS UCC USING (CONSTRAINT_NAME)
WHERE UC.TABLE_NAME = 'MEMBER'; 

-- 여러 컬럼을 묶어서 UNIQUE 제약 조건이 설정되어 있으면 제약 조건이 설정되어 있는 컬럼 값이 "모두 중복되는 경우에만" 오류가 발생한다.
INSERT INTO MEMBER VALUES(1, 'USER1', '1234', '아무개', DEFAULT);
INSERT INTO MEMBER VALUES(2, 'USER1', '1234', '아무개', DEFAULT); -- INSERT 가능
INSERT INTO MEMBER VALUES(2, 'USER2', '1234', '아무개', DEFAULT); -- NO는 같지만 ID가 달라서 INSERT 가능
INSERT INTO MEMBER VALUES(1, 'USER1', '1234', '아무개', DEFAULT); -- INSERT 오류

SELECT * FROM MEMBER;


/*
    <CHECK 제약조건>
        컬럼에 기록되는 값에 조건을 설정하고 조건을 만족하는 값만 기록할 수 있다.
        비교 값은 리터럴만 사용 가능하다. (변하는 값이나 함수는 사용하지 못한다.) 왜냐면 테이블 생성시 지정되어야 하는 데 계속 변하면 안되니까.
        
        [표현법]
            CHECK(비교 연산자)
                CHECK(컬럼 [NOT] IN (값, 값, ...))
                CHECK(컬럼 = 특정 값)
                CHECK(컬럼 BETWEEN 값 AND 값)
                CHECK(컬럼 LIKE '_문자' OR 컬럼 LIKE '문자%')
                ...

*/

CREATE TABLE MEMBER (
    MEMBER_NO NUMBER NOT NULL,
    MEMBER_ID VARCHAR2(20) NOT NULL,
    MEMBER_PWD VARCHAR2(20) NOT NULL,
    MEMBER_NAME VARCHAR2(20) CONSTRAINT MEMBER_MEMBER_NAME_NN NOT NULL,
    GENDER CHAR(3),
    AGE NUMBER,
    MEMBER_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT MEMBER_MEMBER_ID_UQ UNIQUE(MEMBER_NO, MEMBER_ID)
);

DESC MEMBER;

-- 성별, 나이에 유효한 값이 아닌 값들도 INSERT가 되어버림 (프로그램 논리적 오류 발생)
INSERT INTO MEMBER VALUES(1, 'USER1', '1234', '아무개', '남', 25, DEFAULT);
INSERT INTO MEMBER VALUES(2, 'USER2', '1234', '춘향이', '여', 101,  DEFAULT);
INSERT INTO MEMBER VALUES(3, 'USER3', '1234', '이산아', '강', 30,  DEFAULT);
INSERT INTO MEMBER VALUES(4, 'USER4', '1234', '홍길동', '남', -30,  DEFAULT);

SELECT * FROM MEMBER;

-- 여기에서 테이블 삭제했음

CREATE TABLE MEMBER (
    MEMBER_NO NUMBER NOT NULL,
    MEMBER_ID VARCHAR2(20) NOT NULL,
    MEMBER_PWD VARCHAR2(20) NOT NULL,
    MEMBER_NAME VARCHAR2(20) CONSTRAINT MEMBER_MEMBER_NAME_NN NOT NULL,
    GENDER CHAR(3) CHECK(GENDER IN('남','여')),
    AGE NUMBER CHECK(AGE > 0),
    MEMBER_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT MEMBER_MEMBER_ID_UQ UNIQUE(MEMBER_NO, MEMBER_ID)
);

INSERT INTO MEMBER VALUES(1, 'USER1', '1234', '아무개', '남', 25, DEFAULT);
-- GENDER 컬럼에 CHECK 제약 조건으로 '남' 또는 '여'만 기록 가능하도록 설정되었기 때문에 에러가 발생
INSERT INTO MEMBER VALUES(3, 'USER3', '1234', '이산아', '강', 30,  DEFAULT); -- 제약조건 위배 (제약 조건에 이름 명시적으로 달아주는게 구분이 쉽다)
-- AGE 컬럼에 CHECK 제약 조건으로 0보다 큰 값만 기록 가능하도록 설정되었기 때문에 에러가 발생
INSERT INTO MEMBER VALUES(4, 'USER4', '1234', '홍길동', '남', -30,  DEFAULT); -- 제약조건 위배

/*
    <PRIMARY KEY>
        테이블에서 "한 행의 정보를 식별"하기 위해 사용할 컬럼에 부여하는 제약조건이다.
        각 행들을 구분할 수 있는 식별자의 역할(회원번호, 부서 코드, 직급 코드, ... 한 행을 구분할 수 있는 식별자 역할)
        따라서, 값이 없어도 안되고 값이 중복되어서도 안된다.
        PRIMARY KEY 제약조건을 설정하면 자동으로 해당 컬럼에 NOT NULL + UNIQUE(중복제거) 제약 조건이 설정된다.
        한 테이블에 한 개만 설정할 수 있다. (단, 한 개 이상의 컬럼을 묶어서 PRIMARY KEY로 제약조건을 설정할 수 있다.)
        컬럼 레벨, 테이블 레벨 방식 모두 설정 가능하다.
*/
DROP TABLE MEMBER;

CREATE TABLE MEMBER (
    MEMBER_NO NUMBER CONSTRAINT MEMBER_MEMBER_NO_PK PRIMARY KEY,
    MEMBER_ID VARCHAR2(20) NOT NULL,
    MEMBER_PWD VARCHAR2(20) NOT NULL,
    MEMBER_NAME VARCHAR2(20) CONSTRAINT MEMBER_MEMBER_NAME_NN NOT NULL,
    GENDER CHAR(3) CHECK(GENDER IN('남','여')),
    AGE NUMBER CHECK(AGE > 0),
    MEMBER_DATE DATE DEFAULT SYSDATE,
    -- CONSTRAINT MEMBER_MEMBER_NO_PK PRIMARY KEY(MEMBER_NO), -- 테이블 레벨에서 설정할 때 
    CONSTRAINT MEMBER_MEMBER_ID_UQ UNIQUE(MEMBER_ID)
);

INSERT INTO MEMBER VALUES(1, 'USER1', '1234', '아무개', '남', 25, DEFAULT);
INSERT INTO MEMBER VALUES(2, 'USER2', '1234', '춘향이', '여', 20,  DEFAULT);
INSERT INTO MEMBER VALUES(3, 'USER3', '1234', '이산아', '남', 30,  DEFAULT);
INSERT INTO MEMBER VALUES(3, 'USER4', '1234', '유관순', '여', 15,  DEFAULT); -- 기본 키 중복으로 오류
INSERT INTO MEMBER VALUES(NULL, 'USER5', '1234', '홍길동', '남', 25,  DEFAULT); -- 기본 키가 NULL 이므로 오류

SELECT * FROM MEMBER;

DROP TABLE MEMBER;

CREATE TABLE MEMBER (
    MEMBER_NO NUMBER, 
    MEMBER_ID VARCHAR2(20) NOT NULL,
    MEMBER_PWD VARCHAR2(20) NOT NULL,
    MEMBER_NAME VARCHAR2(20) CONSTRAINT MEMBER_MEMBER_NAME_NN NOT NULL,
    GENDER CHAR(3) CHECK(GENDER IN('남','여')),
    AGE NUMBER CHECK(AGE > 0),
    MEMBER_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT MEMBER_MEMBER_NO_PK PRIMARY KEY(MEMBER_NO, MEMBER_ID) -- 컬럼을 묶어서 하나의 기본 키를 설정 = 테이블 레벨에서만 가능 -> 복합키라고 한다.
);
-- PRIMARY KEY로 묶은 MEMBER_NO, MEMBER_ID 2개가 동시에 다 같아야 한다.

INSERT INTO MEMBER VALUES(1, 'USER1', '1234', '아무개', '남', 25, DEFAULT);
INSERT INTO MEMBER VALUES(1, 'USER2', '1234', '춘향이', '여', 20,  DEFAULT); -- 복합키로 묶인 것 중에 둘 중 하나라도 다르면 INSERT 가능
INSERT INTO MEMBER VALUES(2, 'USER2', '1234', '이산아', '남', 30,  DEFAULT); -- 복합키로 묶인 것 중에 둘 중 하나라도 다르면 INSERT 가능
-- 회원번호, 아이디가 세트로 동일한 값이 이미 존재하기 때문에 에러가 발생한다.
INSERT INTO MEMBER VALUES(1, 'USER1', '1234', '유관순', '여', 15,  DEFAULT); -- 제약 조건 위배, 기본 키 중복으로 오류
-- 기본 키로 설정된 컬럼은 NULL 값이 있으면 에러가 발생한다.
INSERT INTO MEMBER VALUES(NULL, 'USER5', '1234', '홍길동', '남', 25,  DEFAULT); -- 제약 조건 위배, 기본 키가 NULL 이므로 오류

SELECT * FROM MEMBER;

DROP TABLE MEMBER;

/*
    <FOREIGN KEY(참조키, 외래 키) 제약조건>
        다른 테이블에 존재하는 값만을 가져야 하는 컬럼에 부여하는 제약조건이다. (단, NULL 값도 가질 수 있다.) >> 360행 실습
        즉, 참조된 다른 테이블이 제공하는 값만 기록할 수 있다. (FOREIGN KEY 제약 조건에 의해서 테이블 간에 관계가 형성된다.)
        참조할테이블명 = 부모테이블 (기본키 명시 안해도 부모 테이블의 PRIMARY 키랑 자동으로 연결된다.)
        
        [표현법]
            1) 컬럼 레벨
                컬럼명 자료형(크기) [CONSTRAINT 제약조건명] REFERENCES 참조할테이블명 [(기본 키)] [삭제룰]
            
            2) 테이블 레벨
                [CONSTRAINT 제약조건명] FOREIGN KEY(컬럼명) REFERENCES 참조할테이블명 [(기본 키)] [삭제룰]
                
        [삭제룰]
            부모 테이블의 데이터가 삭제되었을 때 옵션을 지정해 놓을 수 있다.
            1) ON DELETE RESTRICT : 자식 테이블의 참조 키가 부모 테이블의 키 값을 참조하는 경우 상위 행을 삭제할 수 없다. (기본적으로 적용되는 옵션)
            2) ON DELETE SET NULL : 부모 테이블의 데이터가 삭제 시 참조하고 있는 자식 테이블의 컬럼 값이 NULL로 변경된다.
            3) ON DELETE CASCADE : 부모 테이블의 데이터가 삭제 시 참조하고 있는 자식 테이블의 컬럼 값이 존재하는 행 전체가 삭제된다.
            
*/
-- "회원 등급"에 대한 데이터를 보관하는 테이블 (부모 테이블을 만들어보자)
CREATE TABLE MEMBER_GRADE (
    GRADE_CODE NUMBER PRIMARY KEY,
    GRADE_NAME VARCHAR2(30) NOT NULL  
);

-- 부모 테이블에서 만든 데이터, 이 딱 3개만 참조키 영역에 갈 수 있다.
INSERT INTO MEMBER_GRADE VALUES(10, '일반회원');
INSERT INTO MEMBER_GRADE VALUES(20, '우수회원');
INSERT INTO MEMBER_GRADE VALUES(30, '특별회원');

SELECT * FROM MEMBER_GRADE;

DROP TABLE MEMBER;

-- 자식 테이블을 만들어보자
CREATE TABLE MEMBER (
    MEMBER_NO NUMBER CONSTRAINT MEMBER_MEMBER_NO_PK PRIMARY KEY,
    MEMBER_ID VARCHAR2(20) NOT NULL,
    MEMBER_PWD VARCHAR2(20) NOT NULL,
    MEMBER_NAME VARCHAR2(20) CONSTRAINT MEMBER_MEMBER_NAME_NN NOT NULL,
    GENDER CHAR(3) CHECK(GENDER IN('남','여')),
    AGE NUMBER CHECK(AGE > 0),
    GRADE_ID NUMBER REFERENCES MEMBER_GRADE(GRADE_CODE), -- 참조키 부분
    MEMBER_DATE DATE DEFAULT SYSDATE,
    -- CONSTRAINT MEMBER_MEMBER_NO_PK PRIMARY KEY(MEMBER_NO),
    -- FOREIGN KEY(GRADE_ID) REFERENCES MEMBER_GRADE /*(GRADE_CODE)*/, -- 생략 가능(자동으로 부모 테이블의 기본 키로 연결된다.)
    CONSTRAINT MEMBER_MEMBER_ID_UQ UNIQUE(MEMBER_ID)
);

INSERT INTO MEMBER VALUES(1, 'USER1', '1234', '춘향이', '여', 20, 10, DEFAULT); -- INSERT 가능
-- 50이라는 값이 MEMBER_GRADE 테이블 GRADE_CODE 컬럼에서 제공하는 값이 아니기 때문에 외래키 제약 조건에 위배되어 오류 발생
INSERT INTO MEMBER VALUES(2, 'USER2', '1234', '이산아', '남', 30, 50, DEFAULT); -- parent key not found 에러 발생
INSERT INTO MEMBER VALUES(3, 'USER3', '1234', '홍길동', '남', 25, NULL, DEFAULT); -- INSERT 가능 -- GRADE_ID 컬럼에 NULL 사용 가능

SELECT * FROM MEMBER;

-- MEMBER 테이블과 MEMBER_GRADE 테이블을 조인하여 MEMBER_ID, MEMBER_NAME, GRADE_NAME 조회해보자.
-- ANSI 구문
SELECT MEMBER_ID, 
       MEMBER_NAME, 
       GRADE_NAME
FROM MEMBER M
LEFT OUTER JOIN MEMBER_GRADE G ON (M.GRADE_ID = G.GRADE_CODE); -- 자식 테이블의 외래키랑 부모 테이블의 기본 키를 가지고 조인한다.

-- 오라클 구문

-- MEMBER_GRADE 테이블(부모 테이블)에서 GRADE_CODE가 10인 데이터를 지우기
-- 삭제 불가능, 자식 테이블의 행들 중에 10을 사용하고 있기 때문에 삭제할 수 없다.
-- DELETE에서 WHERE에 조건을 명시하지 않으면 데이터 전체를 삭제하기 때문에 반드시 조건을 명시해야 한다.
DELETE FROM MEMBER_GRADE WHERE GRADE_CODE = 10;
-- 삭제 가능, 자식 테이블의 행들 중에 30을 사용하고 있는 행이 없기 때문에 삭제가 가능하다.
DELETE FROM MEMBER_GRADE WHERE GRADE_CODE = 30;

-- 변경 사항 취소, 커밋한 후에는 롤백 불가능, 위에서 데이터 삭제 작업을 취소한다. (메모리 버퍼에 임시 삭제한 데이터를 실제 테이블에 반영하지 않고 작업을 취소한다.)
-- ROLLBACK은 TCL로써, DML에만 적용이 가능하다. DDL(예를 들어 테이블 삭제 후 롤백 가능? 놉!)은 불가능
ROLLBACK;

SELECT * FROM MEMBER_GRADE;

DROP TABLE MEMBER;

-- ON DELETE SET NULL 옵션이 추가된 자식 테이블 생성(참조키 지정하는 부분에 옵션 추가)
CREATE TABLE MEMBER (
    MEMBER_NO NUMBER CONSTRAINT MEMBER_MEMBER_NO_PK PRIMARY KEY,
    MEMBER_ID VARCHAR2(20) NOT NULL,
    MEMBER_PWD VARCHAR2(20) NOT NULL,
    MEMBER_NAME VARCHAR2(20) CONSTRAINT MEMBER_MEMBER_NAME_NN NOT NULL,
    GENDER CHAR(3) CHECK(GENDER IN('남','여')),
    AGE NUMBER CHECK(AGE > 0),
    GRADE_ID NUMBER REFERENCES MEMBER_GRADE(GRADE_CODE) ON DELETE SET NULL,
    MEMBER_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT MEMBER_MEMBER_ID_UQ UNIQUE(MEMBER_ID)
);

INSERT INTO MEMBER VALUES(1, 'USER1', '1234', '춘향이', '여', 20, 10, DEFAULT);
INSERT INTO MEMBER VALUES(2, 'USER2', '1234', '홍길동', '남', 25, NULL, DEFAULT);

-- 문제 없이 행이 삭제되는 것을 확인할 수 있다.
-- 단, 자식 테이블을 조회해 보면 삭제된 행을 참조하고 있던 컬럼의 값이 (여기에서는 GRADE_ID) NULL로 변경된 것을 확인할 수 있다.
DELETE FROM MEMBER_GRADE WHERE GRADE_CODE = 10;

-- 여기서 롤백한 것은 데이터 삽입후에 커밋하지 않았기 때문에 INSERT 했던 것 까지 죄다 롤백되어버려서 SELECT * 해보면 데이터가 하나도 안 보인다.
ROLLBACK;

SELECT * FROM MEMBER_GRADE;
SELECT * FROM MEMBER;

DROP TABLE MEMBER;

-- ON DELETE CASCADE 옵션이 추가된 테이블 생성
CREATE TABLE MEMBER (
    MEMBER_NO NUMBER CONSTRAINT MEMBER_MEMBER_NO_PK PRIMARY KEY,
    MEMBER_ID VARCHAR2(20) NOT NULL,
    MEMBER_PWD VARCHAR2(20) NOT NULL,
    MEMBER_NAME VARCHAR2(20) CONSTRAINT MEMBER_MEMBER_NAME_NN NOT NULL,
    GENDER CHAR(3) CHECK(GENDER IN('남','여')),
    AGE NUMBER CHECK(AGE > 0),
    GRADE_ID NUMBER REFERENCES MEMBER_GRADE(GRADE_CODE) ON DELETE CASCADE,
    MEMBER_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT MEMBER_MEMBER_ID_UQ UNIQUE(MEMBER_ID)
);

INSERT INTO MEMBER VALUES(1, 'USER1', '1234', '춘향이', '여', 20, 10, DEFAULT);
INSERT INTO MEMBER VALUES(2, 'USER2', '1234', '홍길동', '남', 25, NULL, DEFAULT);

COMMIT;

-- 문제없이 행이 삭제되는 것을 확인할 수 있다.
-- 단, 자식 테이블을 조회해 보면 삭제된 행을 참조하고 있던 컬럼의 행들이 모두 삭제된 것을 확인할 수 있다.

DELETE FROM MEMBER_GRADE WHERE GRADE_CODE = 10;

-- 가장 최근 COMMIT 한 다음 작업 내용 까지 롤백 가능하다.
ROLLBACK;

SELECT * FROM MEMBER_GRADE;
SELECT * FROM MEMBER;

-- 작성한 제약조건 확인
SELECT CONSTRAINT_NAME, 
       CONSTRAINT_TYPE, 
       UC.TABLE_NAME, 
       COLUMN_NAME
FROM USER_CONSTRAINTS UC
JOIN USER_CONS_COLUMNS UCC USING (CONSTRAINT_NAME)
WHERE UC.TABLE_NAME = 'MEMBER'; 

-------------------------------------------------------------------------
/*
    <SUBQUERY를 이용한 테이블 생성>
        SUBQUERY를 사용해서 테이블을 생성한다.
        컬럼명, 데이터 타입, 값이 복사되고 제약 조건은 NOT NULL만 복사된다.
        
        [표현법]
            CREATE TABLE 테이블명
            AS 서브쿼리;
            
*/
-- EMPLOYEE 테이블을 복사한 새로운 테이블 생성 (컬럼, 데이터 타입, 값, NOT NULL 제약 조건을 복사)
CREATE TABLE EMPLOYEE_COPY
AS  SELECT *
    FROM EMPLOYEE;

SELECT * FROM EMPLOYEE_COPY;

CREATE TABLE MEMBER_COPY
AS SELECT *
   FROM MEMBER;

-- EMPLOYEE 테이블을 복사한 새로운 테이블 생성 (컬럼, 데이터 타입, 제약 조건만 복사 즉, NOT NULL 제약 조건 포함된 테이블 구조만 복사하고 값들은 복사하지 않는다.)
CREATE TABLE EMPLOYEE_COPY2
AS  SELECT *
    FROM EMPLOYEE
    WHERE 1 = 0; -- 구조만 복사하고 모든 행에 대해서 결과가 FALSE라서 만족하는 행이 하나도 없어서 데이터 값은 복사하지 않는다.

CREATE TABLE MEMBER_COPY2
AS SELECT *
FROM MEMBER
WHERE 2 = 1;

SELECT * FROM EMPLOYEE_COPY2;
SELECT * FROM MEMBER_COPY2;

-- EMPLOYEE 테이블의 사번, 사원명, 급여, 연봉을 저장하는 테이블 서브 쿼리를 사용해서 생성
CREATE TABLE EMPLOYEE_COPY3
AS  SELECT EMP_ID, EMP_NAME, SALARY, SALARY * 12 AS "연봉" -- SELECT 절에 산술연산 또는 함수식이 기술된 경우 별칭을 정해줘야 테이블 생성이 가능하다.
    FROM EMPLOYEE;

SELECT * FROM EMPLOYEE_COPY3;

DROP TABLE EMPLOYEE_COPY;
DROP TABLE EMPLOYEE_COPY2;
DROP TABLE EMPLOYEE_COPY3;
DROP TABLE MEMBER_COPY;
DROP TABLE MEMBER_COPY2;


