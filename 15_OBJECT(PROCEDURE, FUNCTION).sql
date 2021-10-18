/*
    <PROCEDURE>
        PL/SQL 문을 저장하는 객체
        필요할 때마다 복잡한 구문을 다시 입력할 필요없이 간단하게 호출해서 실행 결과를 얻을 수 있다.
        특정 로직을 처리하기만 하고 결과값을 반환하지 않는다.
        CREATE 프로시저 ~ 에서는 쿼리문을 담고만 있는 것이고, 실행문을 작성해야 실행된다.
        
        [표현법]
            CREATE OR REPLACE PROCEDURE 프로시저명
            {
                매개변수 1 [IN|OUT] 데이터타입 [ := DEFAULT 값],
                매개변수 2 [IN|OUT] 데이터타입 [ := DEFAULT 값],
                ...
            )
            IS [AS]
                선언부
            BEGIN
                실행부
            EXCEPTION
                예외처리부
            END [프로시저명];
            /
        
        [실행방법]
            EXECUTE(EXEC) 프로시저명(매개값1, 매개값2, ...);
*/
-- 테스트용 테이블 생성
CREATE TABLE EMP_DUP
AS SELECT * FROM EMPLOYEE;

SELECT * FROM EMP_DUP;

-- 테스트 테이블의 데이터를 모두 삭제하는 프로시저 생성 (매개변수 없음)
-- PL/SQL문에서는 TCL, DML, SELECT 모두 사용가능
CREATE OR REPLACE PROCEDURE DEL_ALL_EMP
IS 
BEGIN
    DELETE FROM EMP_DUP;
    
    COMMIT;
END;
/
-- 실행하면 Procedure DEL_ALL_EMP이(가) 컴파일되었습니다. 출력됨. 실행부에 있는 문장은 아직 실행은 되지 않은 상태
-- DEL_ALL_EMP 프로시저 호출
EXECUTE DEL_ALL_EMP;  -- PL/SQL 프로시저가 성공적으로 완료되었습니다.

SELECT * FROM EMP_DUP;  -- 테이블 구조만 남고 데이터는 삭제되었다.

-- 프로시저를 관리하는 데이터 딕셔너리
SELECT * FROM USER_SOURCE;

DROP TABLE EMP_DUP;  -- Table EMP_DUP이(가) 삭제되었습니다.
DROP PROCEDURE DEL_ALL_EMP; -- Procedure DEL_ALL_EMP이(가) 삭제되었습니다.

------------------------------------------------------------------
/*
    1) 매개변수가 있는 프로시저
        프로시저 실행 시 매개변수로 인자값을 전달해야 한다.
*/
CREATE OR REPLACE PROCEDURE DEL_EMP_ID
(
    P_EMP_ID EMPLOYEE.EMP_ID%TYPE
)
IS
BEGIN
    DELETE FROM EMPLOYEE
    WHERE EMP_ID = P_EMP_ID;
END;
/

SELECT * FROM EMPLOYEE;

-- 프로시저 실행 
-- EXEC DEL_EMP_ID; -- 매개값이 없어서 에러가 발생
EXEC DEL_EMP_ID('204');

-- 사용자가 입력한 값도 전달이 가능하다.
EXEC DEL_EMP_ID('&사번');

SELECT * FROM EMPLOYEE;

ROLLBACK;

/*
    2) IN/OUT 매개변수가 있는 프로시저
        IN 매개변수  : 프로시저 내부에서 사용될 매개변수
        OUT 매개변수 : 프로시저를 호출하는 부분(외부)에서 사용될 값을 담아줄 변수
*/
-- EMP_ID를 통해서 사원 정보를 조회하는 프로시저

CREATE OR REPLACE PROCEDURE SELECT_EMP_ID 
(
    V_EMP_ID IN EMPLOYEE.EMP_ID%TYPE,
    V_EMP_NAME OUT EMPLOYEE.EMP_NAME%TYPE,
    V_SALARY OUT EMPLOYEE.SALARY%TYPE,
    V_BONUS OUT EMPLOYEE.BONUS%TYPE
)
IS
BEGIN
    SELECT EMP_NAME, SALARY, NVL(BONUS, 0)
    INTO V_EMP_NAME, V_SALARY, V_BONUS
    FROM EMPLOYEE
    WHERE EMP_ID = V_EMP_ID;  -- V_EMP_ID는 사용자가 매개값으로 전달해주는 매개변수, 하나의 사원의 결과 값만 나오게 된다.
END;
/

-- 바인드 변수(VARIABLE | VAR) 선언,  프로시저 호출 전에 선언
-- 프로시저를 실행할 때 조회 결과를 받아오려면 바인드 변수를 같이 생성해줘야 한다. INTO~ 에 있는 값 받아오기. 값을 전달해서 프로시저에서 바인드 변수 값을 받아오는 변수
VAR VAR_EMP_NAME VARCHAR2(30);
VAR VAR_SALARY NUMBER;
VAR VAR_BONUS NUMBER;

-- 바인드 변수는 ':변수명' 형태로 전달해줘야 참조할 수 있다. 순서를 동일하게 작성해야된다. INTO~ 에 있는 결과 값을 받아와서 여기 각각 변수에 저장해준다.
EXEC SELECT_EMP_ID('200', :VAR_EMP_NAME, :VAR_SALARY, :VAR_BONUS);

-- 프로시저 바깥에서 찍어보고 있는 중. 출력 잘 됨
PRINT VAR_EMP_NAME;
PRINT VAR_SALARY;
PRINT VAR_BONUS;

SET AUTOPRINT ON;

EXEC SELECT_EMP_ID('&사번', :VAR_EMP_NAME, :VAR_SALARY, :VAR_BONUS);
-- 프린트 구문 안 찍어도 프로시저 호출이 끝나면 바인드 변수의 값을 자동으로 출력해주는 설정 이후에 실행해 본 것.

---------------------------------------------------------------------------------------
/*
    <FUNCTION>
        프로시저와 사용 용도가 거의 비슷하지만
        프로시저와 다르게 OUT 변수를 사용하지 않아도 실행 결과를 되돌려 받을 수 있다. (RETURN)
        
        [표현법]
            CREATE OR REPLACE FUNCTION 함수명
            (
                매개변수 1 타입,
                매개변수 2 타입,
                ...
            }
            RETURN 데이터타입
            IS [AS]
                선언부
            BEGIN
                실행부
                
                RETURN 반환값; -- 프로시저랑 다르게 RETURN 구문이 추가된다.
            EXCEPTION
                예외처리부
            END [함수명];
            /
*/
-- 사번을 입력받아 해당 사원의 보너스를 포함하는 연봉을 계산하고 리턴하는 함수 생성
-- V_EMP_ID EMPLOYEE.EMP_ID%TYPE  -- 사용자에게 하나의 매개값을 입력 받을 것
-- RETURN NUMBER  -- 반환되는 데이터의 데이터 타입을 지정
CREATE OR REPLACE FUNCTION BONUS_CALC
(
    V_EMP_ID EMPLOYEE.EMP_ID%TYPE
)
RETURN NUMBER 
IS
    V_SAL EMPLOYEE.SALARY%TYPE;
    V_BONUS EMPLOYEE.BONUS%TYPE;
BEGIN
    SELECT SALARY, NVL(BONUS, 0)
    INTO V_SAL, V_BONUS
    FROM EMPLOYEE
    WHERE EMP_ID = V_EMP_ID;
    
    RETURN (V_SAL + (V_SAL * V_BONUS)) * 12;
END;
/
-- Function BONUS_CALC이(가) 컴파일되었습니다.

SELECT * FROM USER_SOURCE;

-- 함수 결과를 반환받아 저장할 바인드 변수 선언
VAR VAR_CALC_SALARY NUMBER;

-- 함수 호출
-- EXEC BONUS_CALC('&사번'); -- 반환하는 값이 있기 때문에 반환값을 받아줘야 한다.
EXEC :VAR_CALC_SALARY := BONUS_CALC('&사번');
EXEC :VAR_CALC_SALARY := BONUS_CALC('200');

PRINT VAR_CALC_SALARY;

-- 함수를 SELECT 문에서 사용하기 (함수는 RETURN 값이 있어서 SELECT 문에서 사용 가능(EXEC 생략 가능)), 함수(컬럼) -> 행들마다 함수를 호출한다. = 단일행 함수
-- 연봉이 4천만원 이상인 사원 조회 (WHERE 절에는 별칭을 적을 수 없다. 실행순서 문제), 10명 출력, ORDER BY는 별칭이랑 컬럼 위치 숫자 적기 가능(SELECT 절에서 가장 마지막에 실행되기 때문에)
SELECT EMP_ID, EMP_NAME, SALARY, BONUS, BONUS_CALC(EMP_ID) AS "연봉"
FROM EMPLOYEE
WHERE BONUS_CALC(EMP_ID) > 40000000
ORDER BY BONUS_CALC(EMP_ID) DESC;

SET SERVEROUTPUT ON;

-------------------------------------------------------------------------------------------
/*
    <CURSOR>
        SQL 문의 처리결과 (처리 결과가 여러 행 (ROW))를 담고 있는 객체이다.
        커서 사용 시 여러 행으로 나타난 처리 결과에 순차적으로 접근이 가능하다.
        
        * 커서의 종류
        묵시적 커서 / 명시적 커서 두 종류가 존재한다.
        
        * 커서 속성 (묵시적 커서의 경우 커서명은 SQL로 사용된다.)
         - 커서명%NOTFOUND : 커서 영역에 남아있는 ROW 수가 없으면 TRUE, 있으면 FALSE
         - 커서명%FOUND    : 커서 영역에 남아있는 ROW 수가 1개 이상 있으면 TRUE, 아니면 FALSE
         - 커서명%ISOPEN   : 커서가 OPEN 상태인 경우 TRUE 아니면 FALSE (묵시적 커서는 항상 FALSE)
         - 커서명%ROWCOUNT : SQL 처리 결과로 얻어온 행(ROW) 수
         
         1) 묵시적 커서
          - 오라클에서 자동으로 생성되어 사용하는 커서이다.
          - PL/SQL 블록에서 SQL문을 실행 시마다 자동으로 만들어져서 사용된다.
          - 사용자는 생성 유무를 알 수 없지만, 커서 속성을 활용하여 커서의 정보를 얻어올 수 있다.
*/

SET SERVEROUTPUT ON;

-- BONUS가 NULL인 사원의 BONUS를 0으로 수정
-- 몇 행이 수정되었는지 ROWCOUNT로 가져와보자
SELECT * FROM EMPLOYEE;
COMMIT;

BEGIN
    UPDATE EMPLOYEE
    SET BONUS = 0
    WHERE BONUS IS NULL;
    
    -- 묵시적 커서 사용(ROWCOUNT)
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || '행 수정됨');
END;
/

ROLLBACK;

/*
         2) 묵시적 커서
           - 사용자가 직접 선언해서 사용할 수 있는 커서이다.
           
         [사용방법]
          1) CURSOR 커서명 IS ..        : 커서 선언
          2) OPEN 커서명;               : 커서 오픈
          3) FETCH 커서명 INTO 변수 ...  : 커서에서 데이터 추출(한 행씩 데이터를 가져온다.)
          4) CLOSE 커서명               : 커서 닫기(메모리 정리도 된다.)
          
         [표현법]
            CURSOR 커서명 IS [SELECT문 서브쿼리로 작성]
            
            OPEN 커서명;
            FETCH 커서명 INTO 변수;
            ...
            CLOSE 커서명;
*/
-- 급여가 30000000 이상인 사원의 사번, 이름, 급여 출력(PL/SQL 구문으로)
DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
    
    CURSOR C1 IS -- 커서 선언(서브 쿼리를 갖고만 있는다. 실행은 아직 NOPE!)
        SELECT EMP_ID, EMP_NAME, SALARY
        FROM EMPLOYEE
        WHERE SALARY > 3000000;
BEGIN
    OPEN C1; -- 커서 오픈
    
    LOOP
        -- 서브 쿼리의 결과에서 한 행씩 차례대로 데이터를 가져와서 순서대로 변수에 담아준다.
        FETCH C1 INTO EID, ENAME, SAL;
        
        EXIT WHEN C1%NOTFOUND; -- LOOP를 빠져나올 조건문 TRUE가 반환되면 종료
        
        DBMS_OUTPUT.PUT_LINE(EID || ' ' || ENAME || ' ' || SAL);
    END LOOP;
    
    CLOSE C1; -- 커서 종료
END;
/

-- 전체 부서에 대해 부서 코드, 부서명, 지역 조회(PROCEDURE)
CREATE OR REPLACE PROCEDURE CURSOR_DEPT
IS
    V_DEPT DEPARTMENT%ROWTYPE; -- 타입 변수 만들기
    
    CURSOR C1 IS
        SELECT * FROM DEPARTMENT;
BEGIN
    OPEN C1;
    
    LOOP
        FETCH C1 INTO V_DEPT.DEPT_ID, V_DEPT.DEPT_TITLE, V_DEPT.LOCATION_ID;
        
        EXIT WHEN C1%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('부서 코드 : ' || V_DEPT.DEPT_ID || ', 부서명 : ' || V_DEPT.DEPT_TITLE || ', 지역 : ' || V_DEPT.LOCATION_ID);
    END LOOP;
    
    CLOSE C1;
END;
/

SELECT * FROM DEPARTMENT; -- 서브쿼리 만들기

-- Procedure CURSOR_DEPT이(가) 컴파일되었습니다.
-- 실행 구문 만들기
EXEC CURSOR_DEPT;

--FOR IN LOOP를 이용한 커서 사용 (같은 이름으로 만들어도 에러 안나고 REPLACE가 될 것) (OPEN, FETCH, CLOSE 생략)
CREATE OR REPLACE PROCEDURE CURSOR_DEPT
IS
    V_DEPT DEPARTMENT%ROWTYPE; -- 변수 선언, 해당하는 값을 저장할수도, 읽어올수도 있다.

--   CURSOR C1 IS
--      SELECT * FROM DEPARTMENT;
BEGIN
-- LOOP 시작 시 자동으로 커서를 생성(선언)하고 커서를 OPEN한다.
-- 반복할 때마다 FETCH도 자동으로 실행된다.
-- LOOP 종료 시 자동으로 커서가 CLOSE 된다.
--    FOR V_DEPT IN C1
    FOR V_DEPT IN (SELECT * FROM DEPARTMENT)
    LOOP
        DBMS_OUTPUT.PUT_LINE('부서 코드 : ' || V_DEPT.DEPT_ID || ', 부서명 : ' || V_DEPT.DEPT_TITLE || ', 지역 : ' || V_DEPT.LOCATION_ID);
    END LOOP;
END;
/

EXEC CURSOR_DEPT; 
-- 위의 예제랑 동일한 출력 결과물이 나온다. (EXEC 랑 같은 행에 주석 달면 에러남)

------------------------------------------------------------------------------------------
/*
    <PAKCAGE>
        프로시저와 함수를 효율적으로 관리하기 위해 묶는 단위로 패키지는 선언부, 본문(BODY)으로 나눠진다.
*/
-- 1) 패키지 선언부에 변수, 상수 선언 및 사용법
CREATE OR REPLACE PACKAGE TEST_PACKAGE
IS
    NAME VARCHAR2(20); -- 변수
    PI CONSTANT NUMBER := 3.14; -- 상수
END;
/

-- 패키지에 선언된 변수, 상수 사용
BEGIN
    TEST_PACKAGE.NAME := '홍길동';
    
    DBMS_OUTPUT.PUT_LINE('이름 : ' || TEST_PACKAGE.NAME);
    DBMS_OUTPUT.PUT_LINE('PI : ' || TEST_PACKAGE.PI);
END;
/
-- 2) 패키지 선언부에 프로시저, 함수, 커서 및 사용 방법
CREATE OR REPLACE PACKAGE TEST_PACKAGE
IS
    NAME VARCHAR2(20); -- 변수
    PI CONSTANT NUMBER := 3.14; -- 상수
    PROCEDURE SHOW_EMP;
END;
/
EXEC TEST_PACKAGE.SHOW_EMP;
-- not executed, package body "KH.TEST_PACKAGE" does not exist 에러 발생 (실제 구현 부분인 BODY가 없어서, 따라서 패키지 BODY 부분을 생성해야 한다.)

-- 패키지 본문 생성
CREATE OR REPLACE PACKAGE BODY TEST_PACKAGE
IS
    PROCEDURE SHOW_EMP
    IS
        V_EMP EMPLOYEE%ROWTYPE;
    BEGIN
        FOR V_EMP IN (SELECT EMP_ID, EMP_NAME, EMP_NO FROM EMPLOYEE)
        LOOP
            DBMS_OUTPUT.PUT_LINE('사번 : ' || V_EMP.EMP_ID || ', 이름 : ' || V_EMP.EMP_NAME ||  ', 주민번호: ' || V_EMP.EMP_NO);
        END LOOP;
    END;
END;
/












