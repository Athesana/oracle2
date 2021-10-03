/*
    <JOIN>
       두 개 이상의 테이블에서 데이터를 조회하고자 할 때 사용되는 구문이다.
       무작정 데이터를 가져오는게 아니라 각 테이블 간에 공통된 컬럼으로 데이터를 합쳐서 하나의 결과(RESULT SET)로 조회한다.
       
       1. 등가 조인(EQUAL JOIN) / 내부 조인(INNER JOIN)
        연결시키는 컬럼의 값이 일치하는 행들만 조인되서 조회한다. (일치하는 값이 없는 행은 조회되지 않는다.)
        1) 오라클 전용 구문
            [표현법]
                SELECT 컬럼, 컬럼, 컬럼, .. 컬럼
                FROM 테이블1, 테이블2(조인될 테이블을 , 로 구문해서 나열)
                WHERE 테이블1.컬럼명 = 테이블2.컬럼명;
                
            - FROM 절에 조회하고자 하는 테이블들을 콤마로(,) 구분해서 나열한다.
            - WHERE 절에 매칠 시킬 컬럼명에 대한 조건을 제시한다.
            
        2) ANSI 표준 구문
            [표현법]
                SELECT 컬럼, 컬럼, 컬럼, .. 컬럼
                FROM 테이블1
                [INNER] JOIN 테이블2 ON (테이블1.컬럼명 = 테이블2.컬럼명);
                 
            - FROM 절에 기준이 되는 테이블을 기술한다.
            - JOIN 절에 같이 조회하고자 하는 테이블을 기술 후 매칠 시킬 컬럼에 대한 조건을 기술한다.
            - 연결에 사용하려는 컬럼명이 같은 경우 ON 구문 대신에 USING(컬럼명) 구문을 사용한다.
*/ 

-- 각 사원들의 사번, 사원명, 부서 코드, 부서명 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE
FROM EMPLOYEE;

SELECT DEPT_ID, DEPT_TITLE
FROM DEPARTMENT;

-- 각 사원들의 사번, 사원명, 부서 코드, 직급명을 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE
FROM EMPLOYEE;

SELECT JOB_CODE, JOB_NAME
FROM JOB;

--<오라클 구문>
-- 1-1) 연결할 두 컬럼이 다른 경우
-- <EUQAL JOIN> EMPLOYEE 테이블과 DEPARTMENT 테이블을 JOIN 하여 사번, 사원명, 부서 코드 ,부서명을 조회
-- 일치하는 값이 없는 행은 조회에서 제외된다. (DEPT_CODE가 NULL인 사원, DEPT_ID가 D3, D4, D7인 사원)
SELECT EMP_ID, EMP_NAME, DEPT_CODE, /*DDEPT_ID 가능*/ DEPT_TITLE
FROM EMPLOYEE, DEPARTMENT
WHERE DEPT_CODE = DEPT_ID;

-- 1-2) 연결할 두 컬럼명이 같은 경우
-- EMPLOYEE 테이블과 JOB 테이블을 조인하여 사번, 사원명, 직급 코드, 직급명을 조회
-- 방법 1) 테이블명을 이용하는 방법
SELECT EMP_ID, EMP_NAME, EMPLOYEE.JOB_CODE, JOB_NAME
FROM EMPLOYEE, JOB
WHERE EMPLOYEE.JOB_CODE = JOB.JOB_CODE;

-- 방법 2) 테이블의의 별칭을 이용하는 방법
SELECT E.EMP_ID, E.EMP_NAME, E.JOB_CODE, J.JOB_NAME
FROM EMPLOYEE E, JOB J
WHERE E.JOB_CODE = J.JOB_CODE;

--<ANSI 구문>
-- 2-1) 연결한 두 컬럼이 다른 경우
-- EMPLOYEE 테이블과 DEPARTMENT 테이블을 JOIN 하여 사번, 사원명, 부서 코드 ,부서명을 조회
SELECT E.EMP_ID, E.EMP_NAME, E.DEPT_CODE, /*DDEPT_ID 가능*/ D.DEPT_TITLE
FROM EMPLOYEE E
INNER JOIN DEPARTMENT D ON E.DEPT_CODE = D.DEPT_ID; -- 앞에 INNER 생략 가능, ON 뒤에 () 생략 가능


-- 2-2) 연결할 두 컬럼명이 같은 경우
-- EMPLOYEE 테이블과 DEPARTMENT 테이블을 JOIN 하여 사번, 사원명, 부서 코드 ,부서명을 조회
-- 방법 1) USING 구문을 이용하는 방법
SELECT E.EMP_ID, E.EMP_NAME, JOB_CODE, J.JOB_NAME -- 여기에서 JOB_CODE에 별칭 붙이면 에러난다.
FROM EMPLOYEE E
JOIN JOB J USING(JOB_CODE); -- USING은 같은 칼럼이라고 인식해서 ambiguously 발생하지 않는다. 따라서 () 안에 별칭을 붙인 컬럼을 넣으면 에러가 난다. 공통된 컬럼명만 넣으면된다.

-- 방법 2) 테이블의 별칭을 이용하는 방법
SELECT E.EMP_ID, E.EMP_NAME, E.JOB_CODE, J.JOB_NAME
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE);

-- 방법 3) NATURAL JOIN을 이용하는 방법
SELECT EMP_ID, EMP_NAME, JOB_CODE, JOB_NAME
FROM EMPLOYEE
NATURAL JOIN JOB;

-- EMPLOYEE 테이블에서 JOB 테이블을 조인하여 직급이 대리인 사원의 사번, 사원명, 직급명, 급여를 조회
-- 오라클 구문
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY
FROM EMPLOYEE E, JOB J
WHERE E.JOB_CODE = J.JOB_CODE AND J.JOB_NAME = '대리';

-- ANSI 구문
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE) -- 테이블 조인 조건은 조인에
WHERE J.JOB_NAME = '대리'; -- 데이터 조건은 WHERE에

---------------------- 실습 문제 ----------------------------
-- 1. DEPARTMENT 테이블과 LOCATION 테이블을 조인하여 부서 코드, 부서명, 지역 코드, 지역명 조회
-- 오라클 구문
SELECT D.DEPT_ID, D.DEPT_TITLE, D.LOCATION_ID, L.NATIONAL_CODE
FROM DEPARTMENT D, LOCATION L
WHERE D.LOCATION_ID = L.LOCAL_CODE;

-- ANSI 구문
SELECT D.DEPT_ID, D.DEPT_TITLE, D.LOCATION_ID, L.NATIONAL_CODE
FROM DEPARTMENT D
JOIN LOCATION L ON (D.LOCATION_ID = L.LOCAL_CODE);

-- 2. EMPLOYEE 테이블과 DEPARTMENT 테이블을 조인해서 보너스를 받는 사원들의 사번, 사원명, 보너스, 부서명을 조회
-- 오라클 구문
SELECT E.EMP_ID, E.EMP_NAME, E.BONUS, D.DEPT_TITLE
FROM EMPLOYEE E, DEPARTMENT D
WHERE E.DEPT_CODE = D.DEPT_ID AND BONUS IS NOT NULL; /* AND NVL(BONUS, 0) > 0; 으로 적어도 된다.*/

-- ANSI 구문
SELECT E.EMP_ID, E.EMP_NAME, BONUS, D.DEPT_TITLE
FROM EMPLOYEE E
JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID) 
WHERE BONUS IS NOT NULL;

-- 3. EMPLOYEE 테이블과 DEPARTMENT 테이블을 조인해서 인사관리부가 아닌 사원들의 사원명, 부서명, 급여를 조회
-- 오라클 구문
SELECT E.EMP_NAME, D.DEPT_TITLE, E.SALARY
FROM EMPLOYEE E, DEPARTMENT D
WHERE E.DEPT_CODE = D.DEPT_ID AND D.DEPT_TITLE != '인사관리부';

-- ANSI 구문
SELECT E.EMP_NAME, D.DEPT_TITLE, E.SALARY
FROM EMPLOYEE E
JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
WHERE D.DEPT_ID != 'D1';

-- SELECT * FROM EMPLOYEE;     -- DEP_TCODE
-- SELECT * FROM DEPARTMENT;   -- DEPT_ID     LOCATION_ID
-- SELECT * FROM LOCATION;     --             LOCAL_CODE
-- SELECT * FROM NATIONAL;     --                          NATIONAL_CODE

-- 4. EMPLOYEE 테이블, DEPARTMENT 테이블, LOCATION 테이블을 조인해서 사번, 사원명, 부서명, 지역명 조회
-- 오라클 구문 (순서에 영향을 받지 않는다.)
SELECT E.EMP_ID, E.EMP_NAME, D.DEPT_TITLE, L.LOCAL_NAME
FROM EMPLOYEE E, DEPARTMENT D, LOCATION L
WHERE E.DEPT_CODE = D.DEPT_ID AND D.LOCATION_ID = L.LOCAL_CODE /*AND LOCAL_NAME = 'ASIA1' */;  -- 조건 추가 가능

-- ANSI 구문 (다중 JOIN은 순서가 매우 중요하다.) (조인되는 개수만큼 조인절을 추가해서 사용, 콤마(,)로 나열 불가)
SELECT E.EMP_ID, E.EMP_NAME, D.DEPT_TITLE, L.LOCAL_NAME
FROM EMPLOYEE E
JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
JOIN LOCATION L ON (D.LOCATION_ID = L.LOCAL_CODE);
/*WHERE LOCAL_NAME ='ASIA1';*/

-- 5. 사번, 사원명, 부서명, 지역명, 국가명 조회
-- 오라클 구문
SELECT E.EMP_ID, E.EMP_NAME, D.DEPT_TITLE, L.LOCAL_NAME, L.NATIONAL_CODE
FROM EMPLOYEE E, DEPARTMENT D, LOCATION L, NATIONAL N
WHERE E.DEPT_CODE = D.DEPT_ID AND D.LOCATION_ID = L.LOCAL_CODE AND L.NATIONAL_CODE = N.NATIONAL_CODE;

-- ANSI 구문



-- 6. 사번, 사원명, 부서명, 지역명, 급여 등급 조회(NON EQUAL JOIN 후에 실습 진행)
-- 오라클 구문

-- ANSI 구문

--------------------------------------------------
/*
      2. 외부 조인(OUTER JOIN)
        테이블 간의 JOIN 시 일치하지 않는 행도 포함시켜서 조회가 가능하다.
        단, 반드시 기준이 되는 테이블(컬럼)을 지정해야 한다. (LEFT / RIGHT / (+))
*/
-- OUTER JOIN과 비교할 INNER JOIN 구해놓기
-- 부서가 지정되지 않는 사원 2명에 대한 정보가 조회되지 않는다.
-- 부서가 지정되어 있어서 DEPARTMENT에 부서에 대한 정보가 없으면 조회되지 않는다.
SELECT E.EMP_NAME, D.DEPT_TITLE, E.SALARY, E.SALARY * 12
FROM EMPLOYEE E
INNER JOIN DEPARTMENT D ON E.DEPT_CODE = D.DEPT_ID;

-- 1) LEFT [OUTER] JOIN : 두 테이블 중 왼편에 기술된 테이블의 컬럼을 기준으로 JOIN 을 진행한다.
-- ANSI 구문
-- 부서코드가 없던 사원 (이오리, 하동운) 정보가 나오게 된다.
SELECT E.EMP_NAME, D.DEPT_TITLE, E.SALARY, E.SALARY * 12
FROM EMPLOYEE E
LEFT /*OUTER*/ JOIN DEPARTMENT D ON E.DEPT_CODE = D.DEPT_ID;

-- 오라클 구문
SELECT E.EMP_NAME, D.DEPT_TITLE, E.SALARY, E.SALARY * 12
FROM EMPLOYEE E, DEPARTMENT D
WHERE E.DEPT_CODE = D.DEPT_ID(+);

-- 2) RIGHT [OUTER] JOIN : 두 테이블 중 오른편에 기술된 테이블의 컬럼을 기준으로 JOIN을 진행한다.
-- ANSI 구문
SELECT E.EMP_NAME, D.DEPT_TITLE, E.SALARY, E.SALARY * 12
FROM EMPLOYEE E
RIGHT /*OUTER*/ JOIN DEPARTMENT D ON E.DEPT_CODE = D.DEPT_ID;

-- 오라클 구문
SELECT E.EMP_NAME, D.DEPT_TITLE, E.SALARY, E.SALARY * 12
FROM EMPLOYEE E, DEPARTMENT D
WHERE E.DEPT_CODE(+) = D.DEPT_ID;

-- 3) FULL [OUTER] JOIN : 두 테이블이 가진 모든 행을 조회할 수 있다. (단, 오라클 구문은 지원하지 않는다.)
SELECT E.EMP_NAME, D.DEPT_TITLE, E.SALARY, E.SALARY * 12
FROM EMPLOYEE E
FULL /*OUTER*/ JOIN DEPARTMENT D ON E.DEPT_CODE = D.DEPT_ID;

-- 6. GROUP BY HAVING 사요하고 테이블은 2개만 조인
-- 8. JOB테이블 조인
-- 9. JOIN 4개 테이블
-- 10. 3개 테이블 조인
-- 11. 임플로이 잡테이블 두개만, 조건문으로 '형'








