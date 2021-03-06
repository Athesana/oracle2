/*
    <PL/SQL>
        오라클 자체에 내장되어 있는 절차적 언어로 SQL 문장 내에서 변수의 정의 , 조건 처리(IF), 반복 처리(LOOP, FOR, WHILE) 등을 지원한다.
        다수의 SQL문을 한 번에 실행할 수 있다.
        
        [PL/SQL의 구조]
            1) 선언부(DECLARE SECTION)         : DECLARE 로 시작, 변수나 상수를 선언 및 초기화 하는 부분이다.
            2) 실행부(EXECUTABLE SECTION)      : BIGIN 으로 시작, SQL문이나 제어문이나(조건, 반복문) 등의 로직을 기술하는 부분이다.
            3) 예외 처리부(EXCEPTION SECTION)   : EXCEPTION 으로 시작, 예외가 발생 시 해결하기 위한 구문을 기술하는 부분이다.
        - 선언부, 예외처리부는 생략 가능, 실행부는 반드시 작성해야 한다.
        - BEGIN 절 안에는 여러 쿼리문을 작성해도 된다. (JOIN 가능) : 코드가 실행되는 부분 (not like 조건문)
*/
SET SERVEROUTPUT ON; 
-- 출력기능 활성화, 1번만 실행 시키면 된다.

BEGIN
    DBMS_OUTPUT.PUT_LINE('HELLO ORACLE!');
END;
/

/*
    1) 선언부(DECLARE SECTION)
        변수 및 상수를 선언해 놓는 공간 (선언과 동시에 초기화도 가능하다.)
        변수 및 상수는 일반 타입 변수, 레퍼런스 타입 변수, ROW 타입 변수로 선언해서 사용할 수 있다.
        
     1-1) 일반 타입 변수 선언 및 초기화
        [표현법]
            변수명 [CONSTANT] 자료형(크기) [:= 값];       // CONSTANT : 상수 만들 때 사용하는 키워드
*/

DECLARE
    EID NUMBER;
    ENAME VARCHAR2(30);
    PI CONSTANT NUMBER := 3.14;
BEGIN
    EID := 888;
    ENAME := '배장남';
--  PI := 3.15; -- 에러 발생
    
    DBMS_OUTPUT.PUT_LINE('EID : ' || EID);
    DBMS_OUTPUT.PUT_LINE('ENAME : ' || ENAME);
END;
/

/*
     1-2) 레퍼런스 타입 변수 선언 및 초기화
        [표현법]
            변수명 테이블명.컬럼명%TYPE;
            
        - 해당하는 테이블의 컬럼에 데이터 타입을 참조해서 그 타입으로 변수를 지정한다.
        - 조회되는 컬럼과 대입하려는 컬럼의 데이터 갯수, 타입이 동일해야 담아진다. 순서는 상관없다.
*/

DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
BEGIN
    -- 사원명을 입력받아서 사원의 사번, 사원명, 급여 정보를 각각 EID, ENAME, SAL 변수에 대입 후 출력한다.
    SELECT EMP_ID, EMP_NAME, SALARY
    INTO EID, ENAME, SAL
    FROM EMPLOYEE
    WHERE EMP_NAME = '&NAME';
    -- &(앰퍼샌드) 기호는 대체 변수(값을 입력)를 입력하기 위한 창을 띄어주는 구문이다. 그 결과값을 NAME에 담아줘서 서치해준다.
    
    DBMS_OUTPUT.PUT_LINE('EID : ' || EID);
    DBMS_OUTPUT.PUT_LINE('ENAME : ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('SAL : ' || SAL);
END;
/

--------------------- 실습 문제 --------------------------
-- 레퍼런스 타입 변수로 EID, ENAME, JCODE, DTITLE, SAL 5개를 선언하고
-- 각 자료형은 EMPLOYEE 테이블의 EMP_ID, EMP_NAME, JOB_CODE, SALARY 컬럼 타입과 DEPARTMENT 테이블의 DEPT_TITLE 컬럼의 타입을 참조한다.
-- 사용자가 입력한 사번과 일치하는 사원을 조회(사번, 사원명, 직급 코드, 부서명, 급여)한 후 조회 결과를 각 변수에 대입 후 출력한다.
DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    JCODE EMPLOYEE.JOB_CODE%TYPE;
    DTITLE DEPARTMENT.DEPT_TITLE%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
BEGIN
    SELECT E.EMP_ID, 
           E.EMP_NAME, 
           E.JOB_CODE, 
           D.DEPT_TITLE, 
           E.SALARY
    INTO EID, ENAME, JCODE, DTITLE, SAL
    FROM EMPLOYEE E
    JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
    WHERE EMP_ID = '&사번';
    
    DBMS_OUTPUT.PUT_LINE('사번 : ' || EID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('직급 코드 : ' || JCODE);
    DBMS_OUTPUT.PUT_LINE('부서명 : ' || DTITLE);    
    DBMS_OUTPUT.PUT_LINE('급여 : ' || SAL);
END;
/

/*
     1-3) ROW 타입 변수 선언 및 초기화
        [표현법]
            변수명 테이블명%ROWTYPE;
            
        - 하나의 테이블의 여러 컬럼의 값을 한꺼번에 저장할 수 있는 변수를 의미한다.
        - 모든 컬럼의 조회하는 경우에 사용하기 편리하다.
*/

DECLARE
    EMP EMPLOYEE%ROWTYPE;    
BEGIN
    SELECT *
    INTO EMP
    FROM EMPLOYEE
    WHERE EMP_NAME = '&사원명';
    
    DBMS_OUTPUT.PUT_LINE('사번 : ' || EMP.EMP_ID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || EMP.EMP_NAME);
    DBMS_OUTPUT.PUT_LINE('주민번호 : ' || EMP.EMP_NO);  
    DBMS_OUTPUT.PUT_LINE('이메일 : ' || EMP.EMAIL);  
    DBMS_OUTPUT.PUT_LINE('전화번호 : ' || EMP.PHONE);  
    DBMS_OUTPUT.PUT_LINE('부서 코드 : ' || EMP.DEPT_CODE);  
    DBMS_OUTPUT.PUT_LINE('직급 코드 : ' || EMP.JOB_CODE);  
    DBMS_OUTPUT.PUT_LINE('급여 : ' || EMP.SALARY);
END;
/

------------------------------------------------------------------------------
/*    2) 실행부(EXECUTABLE SECTION)
        2-1) 선택문
          1) 단일 IF 구문
            [표현법]
                IF 조건식 THEN
                    실행 문장
                END IF;
            -- BEGIN 구문안에서 함수 호출 가능, 변수 선언에서도 함수 사용 가능
*/
-- 사번을 입력받은 후 해당 사원의 사번, 이름, 급여, 보너스를 출력
-- 단, 보너스를 받지 않는 사원은 보너스율 출력 전에 '보너스를 지급받지 않는 사원입니다.' 라는 문구를 출력한다.
-- 서브 쿼리로 사용할 쿼리를 작성해보자.

SELECT EMP_ID, EMP_NAME, SALARY, NVL(BONUS,0)
FROM EMPLOYEE
WHERE EMP_ID = '&사번';


DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
    BONUS EMPLOYEE.BONUS%TYPE;
BEGIN
    SELECT EMP_ID, EMP_NAME, SALARY, NVL(BONUS,0)
    INTO EID, ENAME, SAL, BONUS
    FROM EMPLOYEE
    WHERE EMP_ID = '&사번';

    DBMS_OUTPUT.PUT_LINE('사번 : ' || EID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || TO_CHAR(SAL, 'FM99,999,999') || '원');
    
    IF(BONUS = 0) THEN 
        DBMS_OUTPUT.PUT_LINE ('보너스를 지급받지 않는 사원입니다.');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('보너스율 : ' || BONUS * 100 || '%');
END;
/

/*
          2) IF ~ ELSE 구문
            [표현법]
                IF 조건식 THEN
                  실행 문장
                ELSE
                  실행 문장
                END IF;
*/
-- 위의 PL/SQL 구문을 IF ~ ELSE 구문으로 바꿔보자.
DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
    BONUS EMPLOYEE.BONUS%TYPE;
BEGIN
    SELECT EMP_ID, EMP_NAME, SALARY, BONUS
    INTO EID, ENAME, SAL, BONUS
    FROM EMPLOYEE
    WHERE EMP_ID = '&사번';

    DBMS_OUTPUT.PUT_LINE('사번 : ' || EID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || TO_CHAR(SAL, 'FM99,999,999') || '원');
    
    IF(BONUS IS NULL) THEN 
        DBMS_OUTPUT.PUT_LINE ('보너스를 지급받지 않는 사원입니다.');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('보너스율 : ' || BONUS * 100 || '%');
    END IF;
    
END;
/
-- 사번을 입력받아 해당 사원의 사번, 이름, 부서명, 국가코드를 조회한 후 출력한다. 
-- 단, 국가 코드가 'KO'이면 국내팀 그 외는 해외팀으로 출력한다.
DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    DTITLE DEPARTMENT.DEPT_TITLE%TYPE;
    NCODE LOCATION.NATIONAL_CODE%TYPE;
    TEAM VARCHAR2(10);
BEGIN
    SELECT E.EMP_ID, E.EMP_NAME, D.DEPT_TITLE, L.NATIONAL_CODE
    INTO EID, ENAME, DTITLE, NCODE
    FROM EMPLOYEE E
    JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
    JOIN LOCATION L ON (D.LOCATION_ID = L.LOCAL_CODE)
    WHERE E.EMP_ID = '&사번';
    
    IF (NCODE = 'KO') THEN
        TEAM := '국내팀';
    ELSE
        TEAM := '해외팀';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('사번 : ' || EID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('부서 : ' || DTITLE);
    DBMS_OUTPUT.PUT_LINE('국가코드 : ' || NCODE);
    DBMS_OUTPUT.PUT_LINE('소속 : ' || TEAM);
    
END;
/

/*
          3) IF ~ ELSIF ~ ELS 구문
            [표현법]
                IF 조건식 THEN
                  실행 문장
                ELSIF 조건식 THEN
                  실행 문장
                ...
                [ELSE
                  실행 문장]
                END IF;
*/
-- 점수를 입력받아 SCORE 변수에 저장한 후 학점은 입력된 점수에 따라 GRADE 변수에 저장한다.
-- 90점 이상은 'A'
-- 80점 이상은 'B'
-- 70점 이상은 'C'
-- 60점 이상은 'D'
-- 60점 미만은 'F'
-- 출력은 '당신의 점수는 95점이고, 학점은 A학점입니다.' 와 같이 출력하세요.

DECLARE
    SCORE NUMBER;
    GRADE CHAR(1);
BEGIN
    SCORE := '&점수';
    
    IF(SCORE >= 90) THEN
        GRADE := 'A';
    ELSIF(SCORE >= 80) THEN
        GRADE := 'B';
    ELSIF(SCORE >= 70) THEN
        GRADE := 'C';
    ELSIF(SCORE >= 60) THEN
        GRADE := 'D';
    ELSE 
        GRADE := 'F';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('당신의 점수는 ' || SCORE || '점이고, 학점은 ' || GRADE || '학점 입니다.');  
END;
/

-- 사용자에게 입력받은 사번과 일치하는 사원의 급여 조회 후 급여 등급을 출력한다.
-- 500 만원 이상이면 '고급'
-- 300 만원 이상이면 '중급'
-- 300 만원 미만이면 '초급'
-- 출력은 '해당 사원의 급여 등급은 고급입니다.' 와 같이 출력한다.

DECLARE
  --EID EMPLOYEE.EMP_ID%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
    GRADE VARCHAR2(10);
BEGIN 

    SELECT /*E.EMP_ID,*/ E.SALARY
    INTO /*EID,*/ SAL
    FROM EMPLOYEE E
    WHERE E.EMP_ID = '&사번';
    
    IF (SAL >= 5000000) THEN
        GRADE := '고급';
    ELSIF (SAL >= 3000000) THEN
        GRADE := '중급';
    -- ELSIF (SAL < 3000000) THEN
    ELSE
        GRADE := '초급';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('해당 사원의 급여 등급은 ' || GRADE || '입니다.');
END;
/
-- SAL_GRADE 테이블을 활용해보자.
-- 변수 만들어 놓은 것을 특정 SELECT 절 안에서 사용할 수 있다.
-- 첫 번째 SELECT 절에서 담아놓은 변수를 가지고 다른 SELECT 절에서도 이용해서도 사용할 수 있다.
-- BEGIN 구문 안에서 여러 개의 SELECT 사용이 가능하다.
-- BEGIN SELECT로 값을 조회해서 DECLARE 변수에 담아준다.
DECLARE
    SAL EMPLOYEE.SALARY%TYPE;
    GRADE SAL_GRADE.SAL_LEVEL%TYPE;
BEGIN 
    SELECT SALARY
    INTO SAL
    FROM EMPLOYEE E
    WHERE EMP_ID = '&사번';
    
    SELECT SAL_LEVEL
    INTO GRADE
    FROM SAL_GRADE
    WHERE SAL BETWEEN MIN_SAL AND MAX_SAL;
    
    DBMS_OUTPUT.PUT_LINE('해당 사원의 급여 등급은 ' || GRADE || '입니다.');
END;
/

/*
          4) CASE 구문 (선택문, JAVA의 SWITCH문과 비슷하다.)
            [표현법]
               CASE 비교대상
                    WHEN 비교값1 THEN 결과값1
                    WHEN 비교값2 THEN 결과값2
                    ...
                    [ELSE 결과값]
               END;
*/
-- 사번을 입력받은 후에 사원의 모든 컬럼 데이터를 EMP에 대입하고 (ROWTYPE변수) DEPT_CODE에 따라 알맞는 부서를 출력한다.
DECLARE
    EMP EMPLOYEE%ROWTYPE;
    DNAME VARCHAR2(30);
BEGIN
    SELECT *
    INTO EMP
    FROM EMPLOYEE
    WHERE EMP_ID = '&사번';
    
    DNAME := CASE EMP.DEPT_CODE
                WHEN 'D1' THEN '인사관리부'
                WHEN 'D2' THEN '회계관리부'
                WHEN 'D3' THEN '마케팅부'
                WHEN 'D4' THEN '국내영업부'
                WHEN 'D5' THEN '해외영업1부'
                WHEN 'D6' THEN '해외영업2부'
                WHEN 'D7' THEN '해외영업3부'
                WHEN 'D8' THEN '기술지원부'
                WHEN 'D9' THEN '총무부'        
             END;
    
    DBMS_OUTPUT.PUT_LINE('사번 : ' || EMP.EMP_ID);
    DBMS_OUTPUT.PUT_LINE('이름 : ' || EMP.EMP_NAME);
    DBMS_OUTPUT.PUT_LINE('부서 코드 : ' || EMP.DEPT_CODE);
    DBMS_OUTPUT.PUT_LINE('부서명 : ' || DNAME);
END;
/
/*
        2-2) 반복문
          1) BASIC LOOP
            [표현법]
                LOOP
                    반복적으로 실행시킬 구문
                    
                    [반복문을 빠져나갈 조건문 작성]
                     1) IF 조건식 THEN EXIT; END IF;
                     2) EXIT WHEN 조건식;
                END LOOP;
                
            - 조건문은 생략이 가능하지만, 생략할 경우 무한루프를 돌게된다.
*/
-- 1 ~ 5까지 순차적으로 1씩 증가하는 값을 출력
DECLARE
    NUM NUMBER := 1;

BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE(NUM);
        
        NUM := NUM + 1;
        
--      IF NUM > 5 THEN
--          EXIT;
--      END IF;
        
        EXIT WHEN NUM > 6;
        
    END LOOP;
END;
/

SET SERVEROUTPUT ON;

/*
          2) BASIC LOOP
            [표현법]
                WHILE 조건식
                LOOP
                    반복적으로 실행할 구문;
                END LOOP;
*/

-- 1 ~ 5 까지 순차적으로 1씩 증가하는 값을 출력
DECLARE
    NUM NUMBER := 1;
BEGIN
    WHILE (NUM <= 5)
    LOOP
     DBMS_OUTPUT.PUT_LINE(NUM);
     
     NUM := NUM + 1;
    END LOOP;
END;
/
    
-- 구구단 (2 ~ 9단) 출력 (반복문을 중첩해서 사용한다.)
-- 변수 2개를 선언해도 되고, 연산 값이 들어갈 변수 1개를 더 선언해도 되고 OR 출력하면서 연산시키기해도 되고
DECLARE
    DAN NUMBER := 2;
    SU NUMBER;
BEGIN
    WHILE DAN <= 9
    LOOP
        SU := 1;
        WHILE SU <= 9
        LOOP
            DBMS_OUTPUT.PUT_LINE(DAN || ' X ' || SU || ' = ' || DAN * SU);
            
            SU := SU + 1;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
        DAN := DAN + 1;
    END LOOP;
END;
/

/*
          3) FOR LOOP
            [표현법]
                FOR 변수 IN (REVERSE) 초기값..최종값
                LOOP
                    반복적으로 실행할 구문;
                END LOOP;
                
            -- 반복할 횟수를 알고 있는 경우에 사용
*/
-- 1~ 5까지 순차적으로 1씩 증가하는 값을 출력 (like JAVA for:each)
BEGIN
    FOR NUM IN 1..5
    LOOP
        DBMS_OUTPUT.PUT_LINE(NUM);
    END LOOP;
END;
/
-- 역순으로 출력
BEGIN
    FOR NUM IN REVERSE 1..5
    LOOP
        DBMS_OUTPUT.PUT_LINE(NUM);
    END LOOP;
END;
/

-- 구구단(2 ~ 9단) 출력 (단, 짝수단만 출력한다.)
BEGIN
    FOR DAN IN 2..9
    LOOP
        IF (MOD(DAN, 2) = 0) THEN 
            FOR SU IN 1..9
            LOOP
                DBMS_OUTPUT.PUT_LINE(DAN || ' X ' || SU || ' = ' || DAN * SU);
            END LOOP;
            
            DBMS_OUTPUT.PUT_LINE('');
        END IF;
    END LOOP;
END;
/

-- 반복문(FOR 구문)을 이용한 데이터 삽입
CREATE TABLE TEST(
    NUM NUMBER,
    CREATE_DATE DATE
);

TRUNCATE TABLE TEST;
SELECT * FROM TEST;

-- DML, TCL 들도 PL/SQL 문에서 사용이 가능합니다.
-- TEST 테이블에서 10개의 행을 INSERT하는 PL/SQL 작성
-- 갯수를 정했기 때문에 FOR문 사용 가능
-- 홀수 번호의 행만 커밋, 짝수면 롤백
-- 일단 INSERT해보고 인서트 한 NUM 값이 IF~~ 해당하면 COMMIT, 아니면 ROLLBACK;
-- IF(MOD(NUM, 2) != 0) THEN
BEGIN
    FOR NUM IN 1..10
    LOOP
        INSERT INTO TEST VALUES(NUM, SYSDATE);
        
        IF(MOD(NUM, 2) = 1) THEN 
            COMMIT;
        ELSE 
            ROLLBACK;
        END IF;
    END LOOP;
    
END;
/
/*
    3) 예외처리부(EXCEPTION SECTION)
        예외란 실행 중 발생하는 오류를 뜻하고 PL/SQL 문에서 발생한 예외를 예외처리부에서 코드적으로 처리가 가능하다.
        
        [표현법]
            DECLARE
            ...
            BEGIN
            ...
            EXCEPTION
                WHEN 예외명 1 THEN 예외처리구문 1;
                WHEN 예외명 2 THEN 예외처리구문 2;
                ...
                WHEN OTHERS THEN 예외처리구문;
                
        * 지정된 예외 말고 모르는 예외가 발생할 경우에는 OTHERS 넣어주면 된다. OTHERS 하나만 넣으면 모든 오류에 대해서 퉁쳐서 다 처리된다.
        * 오라클에서 미리 정의되어 있는 예외(시스템 예외)를 가지고 수행함
            - NO_DATA_FOUND    : SELECT 문의 수행 결과가 한 행도 없을 경우 발생한다.
            - TOO_MANY_ROWS    : 한 행이 리턴되어야하는데 SELECT 문에서 여러 개의 행을 반환할 때 발생한다.
            - ZERO_DIVIDE      : 숫자를 0으로 나눌 때 발생한다.
            - DUP_VAL_ON_INDEX : UNIQUE 제약 조건을 가진 컬럼에 중복된 데이터가 INSERT 될 때 발생한다.
*/
-- 사용자가 입력한 수로 나눗셈 연산을 해보자. 0으로 입력할 때 ZERO_DIVIDE 발생하는지, 어떻게 처리하는지 실습
DECLARE
    RESULT NUMBER;
BEGIN
    RESULT := 10 / '&숫자';
    DBMS_OUTPUT.PUT_LINE('결과 : ' || RESULT);
EXCEPTION
    WHEN ZERO_DIVIDE THEN DBMS_OUTPUT.PUT_LINE('나누기 연산시 0으로 나눌 수 없습니다.');
END;
/
-- 0을 사용자가 입력하면 "divisor is equal to zero" 발생 -> EXCEPTION WHEN ZERO_DIVIDE THEN ~ 입력하면 지정한 출력구문으로 나온다.

-- UNIQUE 제약조건을 위배시켜보자.
-- 방명수 -> "unique constraint (%s.%s) violated" 발생 -> EXCEPTION WHEN DUP_VAL_ON_INDEX THEN ~ 입력하면 지정한 출력구문으로 나온다.
BEGIN
    UPDATE EMPLOYEE
    SET EMP_ID = 200
    WHERE EMP_NAME = '&이름';
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN DBMS_OUTPUT.PUT_LINE('이미 존재하는 사번입니다.');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LIN('오류가 발생했습니다. 관리자에게 문의해주세요.');
END;
/

-- 너무 많은 행이 조회가 되었을 때
-- "exact fetch returns more than requested number of rows" 발생
-- 조회되는 데이터가 없을 때
-- "no data found" 발생
DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
BEGIN
    SELECT EMP_ID, EMP_NAME
    INTO EID, ENAME
    FROM EMPLOYEE
    WHERE MANAGER_ID = '&사수번호';
    
    DBMS_OUTPUT.PUT_LINE('사번: ' || EID);
    DBMS_OUTPUT.PUT_LINE('사원명 : ' || ENAME);
    
EXCEPTION
    WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('너무 많은 행이 조회되었습니다.');
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('조회 결과가 없습니다.');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다.');
END;
/
-- 사용자가 입력한 사수번호를 사수로 가지고 있는 직원 데이터를 조회할 건데, 1개의 행이 조회되면 INTO~ 에 담길 수 있지만, 
-- 한 개의 결과가 아니라 여러 개의 결과(내가 입력한 사수번호를 사수로 가지고 있는 사원이 여러 명인 것)를 INTO ~ 한 행에 담을 수 없기 때문에 에러가 발생한다.

