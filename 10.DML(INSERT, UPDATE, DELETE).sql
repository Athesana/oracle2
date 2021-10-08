/*
    <DML(Data Manipulation Language)>
        데이터 조작 언어로 테이블의 값ㅇ르 삽입(INSERT) 하거나 수정(UPDATE), 삭제(DELETE) 하는 구문이다.
    
    <INSERT>
        테이블에 새로운 행을 추가하는 구문이다.
        
        [표현법]
            1) INSERT IN TO 테이블명 VALUES(값, 값, 값, ...);
                테이블에 모든 컬럼에 값을 INSERT 하고자 할 때 사용한다.
                주의점> 컬럼의 순번을 지켜서 VALUES 값을 나열해야 한다.
            2) INSERT INTO 테이블명(컬럼명, 컬럼명, ...) VALUES(값, 값, ...);
                테이블에 내가 선택한 컬럼에 대한 값만 INSERT 하고자 할 때 사용한다.
                선택되지 않은 컬럼들은 기본적으로 NULL 값이 들어간다.(NOT NULL 제약조건이 걸려있는 컬럼은 반드시 선택해서 값을 제시해야 한다.)
                단, 기본 값(DEFAULT)이 지정되어 있으면 NULL이 아닌 기본 값이 들어간다.
            3) INSERT INTO 테이블명 (서브 쿼리);
                VALUES 대신해서 서브 쿼리로 조회한 결과값을 통채로 INSERT한다. (즉, 여러 행을 INSERT 시킬 수 있다.)
                서브 쿼리의 결과값이 INSERT문에 지정된 컬럼의 개수와 데이터 타입이 같아야 한다.
*/
-- 표현법 1)번 사용
INSERT INTO EMPLOYEE
VALUES ('900', '공유', '901008-1080503', 'kong@kh.or.kr', 01055556666, 'D1', 'J7', 4300000, 0.2, '200', SYSDATE, NULL, DEFAULT); -- cannot insert NULL int ("KH"."EMPLOYEE"."EMP_ID")

-- 표현법 2)번 사용 -- EMP_ID만 하려고 했더니 EMP_NAME 에는 NOT NULL 제약조건이 걸려있어서 값을 넣어줘야한다. (안 넣으면 자동으로 NULL 이 들어가게되니까) 이런식으로 제약조건 있는 애들은 다 값을 넣어주면 된다.
INSERT INTO EMPLOYEE(EMP_ID, EMP_NAME, EMP_NO, JOB_CODE)
VALUES(901, '이산아', '991008-2111111', 'J7');

SELECT * 
FROM EMPLOYEE
ORDER BY EMP_ID DESC;

-- 표현법 3)번 사용
-- 새로운 테이블 생성
CREATE TABLE EMP_01 (
    EMP_ID NUMBER,
    EMP_NAME VARCHAR2(30),
    DEPT_TITLE VARCHAR2(35)
);

-- 전체 사원의 사번, 이름, 부서명을 조회하여 결과값을 EMP_01 테이블에 INSERT 한다. -- 서브 쿼리에 SELECT * 로 하면 "too many values" 오류, 위에 새로만든 테이블의 컬럼 3개 넣으면 25개 행이 삽입된다.
INSERT INTO EMP_01 (
    SELECT EMP_ID, EMP_NAME, DEPT_TITLE
    FROM EMPLOYEE E
    LEFT OUTER JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
);

INSERT INTO EMP_01 (EMP_ID, EMP_NAME) (
    SELECT EMP_ID, EMP_NAME
    FROM EMPLOYEE E
    LEFT OUTER JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
);
-- 총 50개의 행이 조회 ***** 여기 다시 복습
SELECT * FROM EMP_01; -- 부서가 없는 애들은 NULL로 해서 25행 조회

DROP TABLE EMP_01;

/*
    <INSERT ALL>
        두 개 이상의 테이블에 INSERT 하는데 동일한 서브 쿼리가 사용되는 경우에 INSERT ALL을 사용해서 여러 테이블에 한 번에 데이터 삽입이 가능하다.
        
        [표현법]
            1) INSERT ALL
               INTO 테이블명1[(컬럼, 컬럼, ...)] VALUES(값, 값, ...)
               INTO 테이블명2[(컬럼, 컬럼, 컬럼, ...)] VALUES(값, 값, 값, ...)
                    서브쿼리;
            2) INSERT ALL
               WHEN 조건 1 THEN
                    INTO 테이블명1[(컬럼, 컬럼, ...)] VALUES(값, 값, ...)
               WHEN 조건 2 THEN
                    INTO 테이블명2[(컬럼, 컬럼, ...)] VALUES(값, 값, ...)
               서브 쿼리;
*/

-- 표현법 1)번을 테이블을 만들자 (테이블 구조만 복사)
CREATE TABLE EMP_DEPT
AS SELECT EMP_ID, EMP_NAME, DEPT_CODE, HIRE_DATE
   FROM EMPLOYEE
   WHERE 1 = 0;

CREATE TABLE EMP_MANAGER
AS SELECT EMP_ID, EMP_NAME, MANAGER_ID
   FROM EMPLOYEE
   WHERE 1 = 0;

-- EMP_DEPT 테이블에 EMPLOYE 테이블의 부서 코드가 D1인 직원의 사번, 이름, 부서 코드, 입사일을 삽입하고
-- EMP_MANAGER 테이블에 EMPLOYEE 테이블의 부서 코드가 D1인 직원의 사번, 이름, 관리자 사번을 조회해서 삽입한다.
-- 서브쿼리를 먼저 만들어보자.
SELECT EMP_ID, EMP_NAME, DEPT_CODE, HIRE_DATE, MANAGER_ID
FROM EMPLOYEE
WHERE DEPT_CODE = 'D1';

-- 서브쿼리가 먼저 실행 되기 때문에 여러 개 테이블에 하나의 서브쿼리로 데이터를 INSERT 할 수 있다.
INSERT ALL
INTO EMP_DEPT VALUES(EMP_ID, EMP_NAME, DEPT_CODE, HIRE_DATE)
INTO EMP_MANAGER VALUES(EMP_ID, EMP_NAME, MANAGER_ID)
    SELECT EMP_ID, EMP_NAME, DEPT_CODE, HIRE_DATE, MANAGER_ID
    FROM EMPLOYEE
    WHERE DEPT_CODE = 'D1';  -- 8개 행이 삽입된다.

SELECT * FROM EMP_DEPT;
SELECT * FROM EMP_MANAGER;

DROP TABLE EMP_DEPT;
DROP TABLE EMP_MANAGER;

-- 표현법 2)번을 테스트할 테이블을 만들자. (테이블 구조만 복사)
CREATE TABLE EMP_OLD
AS SELECT EMP_ID, EMP_NAME, HIRE_DATE, SALARY
   FROM EMPLOYEE
   WHERE 1 = 0;

CREATE TABLE EMP_NEW
AS SELECT EMP_ID, EMP_NAME, HIRE_DATE, SALARY
   FROM EMPLOYEE
   WHERE 1 = 0;

-- EMPLOYEE 테이블의 입사일 기준으로 2000년 1월 1일 이전에 입사한 사원의 정보는 EMP_OLD 테이블로, 2000년 1월 1일 이후에 입사한 사원의 정보는 EMP_NEW 테이블에 삽입한다.
-- 서브쿼리를 작성해보자.
SELECT EMP_ID, EMP_NAME, HIRE_DATE, SALARY 
FROM EMPLOYEE;

INSERT ALL 
WHEN HIRE_DATE < '2000/01/01' THEN
    INTO EMP_OLD VALUES(EMP_ID, EMP_NAME, HIRE_DATE, SALARY)
WHEN HIRE_DATE >= '2000/01/01' THEN
    INTO EMP_NEW VALUES(EMP_ID, EMP_NAME, HIRE_DATE, SALARY)
SELECT EMP_ID, EMP_NAME, HIRE_DATE, SALARY 
FROM EMPLOYEE; -- 24개 행이 삽입되었다.

SELECT * FROM EMP_OLD; -- 8명
SELECT * FROM EMP_NEW; -- 16명

DROP TABLE EMP_OLD;
DROP TABLE EMP_NEW;

-------------------------------------------------------------------------------------------------
/*
    <UPDATE>
        테이블에 기록된 데이터를 수정하는 구문이다.
        
        [표현법]
            UPDATE 테이블명
            SET 컬럼명 = 변경하려는 값, 
                컬럼명 = 변경하려는 값,
                ...
            [WHERE 조건];
            
            UPDATE 테이블명
            SET 컬럼명 = (서브 쿼리), 
                컬럼명 = (서브 쿼리),
                ...
            [WHERE 조건];

        - SET 절에서 여러 개의 컬럼을 콤마(,)로 나열해서 값을 동시에 변경할 수 있다.
        - WHERE 절을 생략하면 모든 행의 데이터가 변경된다.
        - UPDATE 시에 서브 쿼리를 사용해서 서브 쿼리를 수행한 결과값으로 컬럼의 값을 변경할 수 있다. (WHERE 절에도 서브 쿼리를 사용 가능)
        - UPDATE 시에 변경할 값은 해당 컬럼에 대한 제약조건에 위배되면 UPDATE 되지 않는다.
*/
-- 테스트를 진행할 테이블을 만들어보자
CREATE TABLE DEPT_COPY
AS SELECT * FROM DEPARTMENT;

CREATE TABLE EMP_SALARY
AS SELECT EMP_ID, EMP_NAME, SALARY, BONUS
   FROM EMPLOYEE;

SELECT * FROM DEPT_COPY;
SELECT * FROM EMP_SALARY;

-- DEPT_COPY 테이블의 DEPT_ID가 'D9'인 DEPT_TITLE(부서명)을 '총무부' -> '전략기획팀'으로 수정
UPDATE DEPT_COPY
SET DEPT_TITLE = '전략기획팀'
WHERE DEPT_ID = 'D9';

-- 노옹철 사원의 급여를 1000000만원으로 바꿔보자.
UPDATE EMP_SALARY
SET SALARY = 1000000
WHERE EMP_NAME = '노옹철';

-- 선동일 사원의 급여를 7000000원으로, 보너스를 0.2로 변경하시오.
UPDATE EMP_SALARY
SET SALARY = 7000000,
    BONUS = 0.2
WHERE EMP_NAME = '선동일';

-- 모든 사원의 급여를 기존 급여에서 10% 인상한 금액(기존 급여 * 1.1)으로 변경해보자. -- SET 안에 연산식도 가능하다.
UPDATE EMP_SALARY
SET SALARY = SALARY * 1.1; -- 25행이 업데이트 되었다.

-- 사번이 200번인 사원의 사원번호를 NULL로 바꾸어보자. (PK의 NOT NULL 제약조건이 걸려있어서 구조만 가져와도 제약조건은 복사됐기 때문에 EMP_ID는 NULL을 가질 수 없는 상태임)
UPDATE EMP_SALARY
SET EMP_ID = NULL  -- cannot update to NULL 오류 = NOT NULL 제약조건에 위배된다.
WHERE EMP_ID = 200; 

-- EMPLOYEE 테이블에서 노옹철 사원의 부서 코드를 NULL이 아닌 'D0'으로 변경해보자.
UPDATE EMPLOYEE
SET DEPT_CODE = 'D0' -- - parent key not found 오류 = FOREIGN KEY 제약조건에 위배된다.
WHERE EMP_NAME = '노옹철';









