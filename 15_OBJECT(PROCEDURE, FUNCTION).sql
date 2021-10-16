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
            IS
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
            IS
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
