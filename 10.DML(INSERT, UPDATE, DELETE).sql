/*
    <DML(Data Manipulation Language)>
        데이터 조작 언어로 테이블의 값을 삽입(INSERT) 하거나 수정(UPDATE), 삭제(DELETE) 하는 구문이다.
    
    <INSERT>
        테이블에 새로운 행을 추가하는 구문이다.
        
        [표현법]
            1) INSERT INTO 테이블명 VALUES(값, 값, 값, ...);
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
-- <테이블명 다음에 컬럼명을 기재하지 않은 경우> 모든 컬럼에 대해서 조회했던 서브쿼리의 값을 테이블 틀 안에다가 넣어주는 것이다.
INSERT INTO EMP_01 (
    SELECT EMP_ID, EMP_NAME, DEPT_TITLE
    FROM EMPLOYEE E
    LEFT OUTER JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
);
-- <테이블명 다음에 구체적인 컬럼을 지정해서 기재한 경우> 기재한 컬럼에 대해서만 넣고 싶다는 뜻이다. 1개부터 N개까지 가능한데, SELECT에 적은 컬럼 갯수와 타입이 일치해야한다.
-- 단, NOT NULL 제약조건이라든지 제약조건이 걸려있으면 삽입이 안되고, 여기에서는 제약 조건은 따로 없기 때문에 지정되지 않은 컬럼값에는 NULL이 값으로 들어가게 된다. (계속 밑에 행 추가)
INSERT INTO EMP_01 (EMP_ID, EMP_NAME) (
    SELECT EMP_ID, EMP_NAME
    FROM EMPLOYEE E
    LEFT OUTER JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
);

SELECT * FROM EMP_01; -- 부서가 없는 애들은 NULL로 해서 25행 조회

DROP TABLE EMP_01;

/*
    <INSERT ALL>
        두 개 이상의 테이블에 INSERT 하는데 '동일한 서브 쿼리가 사용'되는 경우에 INSERT ALL을 사용해서 여러 테이블에 한 번에 데이터 삽입이 가능하다.
        
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

-- 표현법 1)번을 테이블을 만들자 (테이블 구조만 복사) // 서브 쿼리에 사용되는 컬럼의 갯수와 INSERT에서 사용되는 컬럼의 갯수는 일치하지 않아도 된다. (각각 필요한 게 다르니까)
CREATE TABLE EMP_DEPT
AS SELECT EMP_ID, EMP_NAME, DEPT_CODE, HIRE_DATE
   FROM EMPLOYEE
   WHERE 1 = 0;   -- -> WHERE 조건절의 값이 FALSE여서 데이터는 복사되어 들어가지 않고, 테이블의 구조(데이터 타입)만 복사가 된다.

CREATE TABLE EMP_MANAGER
AS SELECT EMP_ID, EMP_NAME, MANAGER_ID
   FROM EMPLOYEE
   WHERE 1 = 0;

-- EMP_DEPT 테이블에 EMPLOYE 테이블의 부서 코드가 D1인 직원의 사번, 이름, 부서 코드, 입사일을 삽입하고
-- EMP_MANAGER 테이블에 EMPLOYEE 테이블의 "부서 코드가 D1인 직원"의 사번, 이름, 관리자 사번을 조회해서 삽입한다.
-- 서브쿼리를 먼저 만들어보자.
SELECT EMP_ID, EMP_NAME, DEPT_CODE, HIRE_DATE, MANAGER_ID -- 우리가 2개의 테이블에 INSERT할 때 필요한 데이터들 모두 조회
FROM EMPLOYEE
WHERE DEPT_CODE = 'D1';

-- 서브쿼리가 먼저 실행 되기 때문에 여러 개 테이블에 하나의 서브쿼리로 데이터를 INSERT 할 수 있다.
INSERT ALL
INTO EMP_DEPT VALUES(EMP_ID, EMP_NAME, DEPT_CODE, HIRE_DATE)
INTO EMP_MANAGER VALUES(EMP_ID, EMP_NAME, MANAGER_ID)
    SELECT EMP_ID, EMP_NAME, DEPT_CODE, HIRE_DATE, MANAGER_ID
    FROM EMPLOYEE
    WHERE DEPT_CODE = 'D1';  -- 8개 행이 삽입된다. 4개의 데이터들이 각각의 컬럼에 맞게 (4개 컬럼, 3개 컬럼) 삽입된다.

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
-- 항상 서브쿼리가 먼저 실행되고 그 값을 가지고 조건에 맞는 컬럼들이 삽입된다.
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

SELECT * FROM EMP_SALARY;

-- 방명수 사원의 급여와 보너스율을 유재석 사원과 동일하게 변경
SELECT SALARY, BONUS
FROM EMP_SALARY
WHERE EMP_NAME = '유재식';

-- 1) 단일행 서브쿼리를 각각의 컬럼에 적용
UPDATE EMP_SALARY
SET SALARY = (
        SELECT SALARY
        FROM EMP_SALARY
        WHERE EMP_NAME = '유재식'
    ),
    BONUS = (
        SELECT BONUS
        FROM EMP_SALARY
        WHERE EMP_NAME = '유재식'
    )
WHERE EMP_NAME = '방명수';

SELECT * 
FROM EMP_SALARY
WHERE EMP_NAME = '방명수';

ROLLBACK;

-- 2) 다중열 서브 쿼리(행은 하나인데 컬럼이 여러 개)를 사용해서 SALARY, BONUS 컬럼을 한 번에 변경 - > 쌍으로 묶기
UPDATE EMP_SALARY
SET (SALARY, BONUS) = (
    SELECT SALARY, BONUS
    FROM EMP_SALARY
    WHERE EMP_NAME = '유재식'
)
WHERE EMP_NAME = '방명수';

SELECT *
FROM EMP_SALARY
WHERE EMP_NAME = '방명수';

ROLLBACK;

-- 노옹철, 전형돈, 정중하, 하동운 사원들의 급여와 보너스를 유재식 사원과 동일하게 변경
UPDATE EMP_SALARY
SET (SALARY, BONUS) = (
    SELECT SALARY, BONUS
    FROM EMP_SALARY
    WHERE EMP_NAME = '유재식'
) -- 여기에서 실행하면 모든 사원 것이 유재식이랑 똑같이 업데이트 되어버림 따라서 WHERE 절에 조건 써야한다.
-- WHERE EMP_NAME = '노옹철' OR EMP_NAME = '전형돈' OR EMP_NAME = '정중하' OR EMP_NAME = '하동운'; 
WHERE EMP_NAME IN ('노옹철', '전형돈', '정중하', '하동운');

SELECT *
FROM EMP_SALARY;

-- EMP_SALARY 테이블에서 아시아 지역에 근무하는 직원의 보너스를 0.3으로 변경
-- 아시아 지역에 있는 직원들의 사번만 조회해보자. (다중 행 서브쿼리)
SELECT EMP_ID
FROM EMPLOYEE E
JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
JOIN LOCATION L ON (D.LOCATION_ID = L.LOCAL_CODE)
WHERE LOCAL_NAME LIKE 'ASIA%'; -- 19명 조회

-- 서브 쿼리를 활용해서 변경해보자
UPDATE EMP_SALARY
SET BONUS = 0.3
WHERE EMP_ID IN (
    SELECT EMP_ID
    FROM EMPLOYEE E
    JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
    JOIN LOCATION L ON (D.LOCATION_ID = L.LOCAL_CODE)
    WHERE LOCAL_NAME LIKE 'ASIA%'
);

SELECT * FROM EMP_SALARY; -- 25개 행 업데이트

/*
    <DELETE>
        테이블에 기록 된 데이터를 삭제하는 구문이다. (행 단위로 삭제한다.)
        
        [표현식]
            DELETE FROM 테이블명
            [WHERE 조건식]; 
        - 생략 가능하지만 WHERE 절을 제시하지 않으면 테이블의 전체 행들이 삭제된다.
        - FOREIGN KEY 제약조건이 설정되어 있는 경우 참조되고 있는 값에 대해서는 삭제가 불가능하다.
*/

COMMIT;

-- 공유와 이산아 사원 행을 삭제해보자.
DELETE FROM EMP_SALARY
WHERE EMP_NAME = '공유';

ROLLBACK; -- 마지막 커밋 시점으로 롤백된다.

DELETE FROM EMP_SALARY
WHERE EMP_NAME = '이산아';

COMMIT;

-- 커밋 되어버리면 커밋 이전에 작업했던 내용은 롤백해도 되돌릴 수 없음. 마지막 커밋 기준 - 커밋 사이에 있던 내용을 실제 데이터베이스에 반영, 저장하기 때문에

-- 제약 조건있으면 DELETE 안되는 것 테스트
-- DEPARTMENT 테이블에서 DEPT_ID가 D1인 부서를 삭제 해보자
DELETE FROM DEPARTMENT
WHERE DEPT_ID = 'D1'; -- child record found 오류 // D1의 값을 참조하는 자식 테이블의 데이터가 있기 때문에 삭제가 되지 않는다.

-- DEPARTMENT 테이블에서 DEPT_ID가 D3인 부서를 삭제 해보자
DELETE FROM DEPARTMENT
WHERE DEPT_ID = 'D3'; -- 정상적으로 행 삭제 완료(부모 테이블이라도 자식 테이블에서 참조하고 있는 행이 없으면 삭제 가능) // D3의 값을 참조하는 자식 테이블 데이터가 없기 때문에 삭제가 된다.

SELECT * FROM DEPARTMENT;

ROLLBACK;

/*
    <TRUNCATE>
        테이블의 전체 행을 삭제할 때 사용하는 구문으로 DELETE보다 수행 속도가 더 빠르다.
        DELETE - 원하는 데이터만 골라서 삭제, 행을 하나하나 삭제, 데이터가 남아있던 공간은 지워지지 않고 남아있는다
        TRUNCATE - 전체 데이터를 한 번에 지운다. 데이터가 있던 물리적인 공간, 데이터, 메모리 까지 다 삭제된다. (** 조심해서 사용할 것 **)
        별도의 조건 제시가 불가능하고 ROLLBACK이 불가능하다. (자동으로 COMMIT 되는 명령어) 모든 데이터를 삭제하고 컬럼만 남겨둔다.
        
        [표현법]
            TRUNCATE TABLE 테이블명;
*/

SELECT * 
FROM EMP_SALARY;

SELECT *
FROM DEPT_COPY;

DELETE FROM EMP_SALARY;
DELETE FROM DEPT_COPY;

ROLLBACK;

TRUNCATE TABLE EMP_SALARY; -- Table EMP_SALARY이(가) 잘렸습니다.
TRUNCATE TABLE DEPT_COPY;

ROLLBACK; -- ROLLBACK이 불가능하다.


