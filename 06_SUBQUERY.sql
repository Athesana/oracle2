/*
    <SUBQUERY>
        하나의 SQL문 안에 포함된 또 다른 SQL 문을 뜻한다.
        메인 쿼리(기존 쿼리, 기본 쿼리)를 보조하는 역할을 하는 쿼리문이다.
*/
-- 서브 쿼리 예시
-- 서브 쿼리를 사용하지 않는다면 이렇게 각각 조회해야 한다.
-- 노옹철 사원과 같은 부서원들을 조회하라.
-- 1) 노옹철 사원의 부서 코드를 조회 -- D9임을 확인했음.
SELECT EMP_NAME, DEPT_CODE 
FROM EMPLOYEE
WHERE EMP_NAME = '노옹철';

-- 2) 전체 EMPLOYEE 테이블에서 부서 코드가 노옹철 사원의 부서 코드와 동일 사원들을 조회
SELECT EMP_NAME, DEPT_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = 'D9';

-- 3) 위의 2단계를 하나의 쿼리를 작성해보자.
-- 서브 쿼리 안에 구문을 실행시켜서 D9를 가지고 와서 WHERE절에서 DEPT CODE = 'D9'로 인식해서 결과적으로 2) 의 쿼리랑 같은 결과가 나오게 된다.
SELECT EMP_NAME, DEPT_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = (
    SELECT DEPT_CODE -- 원래대로 EMP_NAME까지 SELECT 절에 적으면 비교 값보다 값이 많아서 에러가 발생한다.
    FROM EMPLOYEE
    WHERE EMP_NAME = '노옹철'
);

-----------------------------------------------------------------------------------------------
/*
    <서브 쿼리의 구분>
        서브 쿼리를 수행한 결과 값에 행과 열의 갯수에 따라서 분류를 할 수 있다.
        
        1. 단일행 서브 쿼리          : 서브 쿼리의 조회 결과 값의 행의 개수가 오로지 1개 일 때
        2. 다중행 서브 쿼리          : 서브 쿼리의 조회 결과 값의 행의 개수가 여러 행 일 때
        3. 다중열 서브 쿼리          : 서브 쿼리의 조회 결과 값이 한 행이지만 컬럼이 여러 개 일 때
        4. 다중행, 다중열 서브 쿼리   : 서브 쿼리의 조회 결과 값이 여러행, 여러열 일 때
        
        * 서브 쿼리의 유형에 따라 서브 쿼리 앞에 붙는 연산자가 달라진다.
        
     <단일행 서브 쿼리>
        서브 쿼리의 조회 결과 값의 행의 개수가 오로지 1개 일 때 (단일행이면서 단일열이다.)
        비교 연산자(a.k.a 단일행 연산자) 사용 가능 (=, !=/<>/^=, >, <, >=, <=, ...)
*/
-- 1) 전 직원의 평균 급여보다 급여를 적게 받는 직원들의 이름, 직급 코드, 급여 조회
-- 전 직원 평균 급여
SELECT AVG(SALARY)
FROM EMPLOYEE; -- 1행 1열 = 서브 쿼리로 사용할 것이다.

-- 위 쿼리를 서브 쿼리로 사용하는 메인 쿼리를 작성해보자.
SELECT EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY < (
    SELECT ROUND(AVG(SALARY))
    FROM EMPLOYEE
)
ORDER BY SALARY; -- ORDER BY는 서브 쿼리 바깥에서 쓰세요!

-- 2) 최저 급여를 받는 직원의 사번, 이름, 직급 코드, 급여, 입사일 조회
-- 최저값 가져오는 그룹 함수 -> 서브쿼리
SELECT MIN(SALARY)
FROM EMPLOYEE;

SELECT EMP_ID, EMP_NAME, JOB_CODE,SALARY, HIRE_DATE
FROM EMPLOYEE
WHERE SALARY = (
    SELECT MIN(SALARY)
    FROM EMPLOYEE
);

-- 3) 노옹철 사원의 급여보다 더 많이 받는 사원의 사번, 사원명, 부서명, 직급 코드, 급여 조회 
-- 노옹철 사원 급여 -> 서브쿼리
SELECT SALARY
FROM EMPLOYEE
WHERE EMP_NAME = '노옹철';

SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_CODE, SALARY
FROM EMPLOYEE E
JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
WHERE SALARY > (
    SELECT SALARY
    FROM EMPLOYEE
    WHERE EMP_NAME = '노옹철'
);

-- 4) 부서별 급여의 합이 가장 큰 부서의 부서 코드, 급여의 합 조회 *****
SELECT MAX(SUM(SALARY))
FROM EMPLOYEE
GROUP BY DEPT_CODE;

SELECT DEPT_TITLE, SUM(SALARY)
FROM EMPLOYEE E
LEFT JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
GROUP BY DEPT_TITLE
HAVING SUM(SALARY) = 17700000;

SELECT DEPT_TITLE, SUM(SALARY)
FROM EMPLOYEE E
LEFT JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
GROUP BY DEPT_TITLE
HAVING SUM(SALARY) = (
    SELECT MAX(SUM(SALARY))
    FROM EMPLOYEE
    GROUP BY DEPT_CODE
);

-- 5) 전지연 사원이 속해있는 부서원들을 조회 (단, 전지연 사원은 제외)
-- 사번, 사원명, 전화번호, (직급명, 부서명) JOIN , 입사일

SELECT DEPT_CODE
FROM EMPLOYEE
WHERE EMP_NAME = '전지연';

SELECT EMP_ID, EMP_NAME, PHONE, JOB_NAME, DEPT_TITLE, HIRE_DATE
FROM EMPLOYEE E
LEFT JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
LEFT JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
WHERE DEPT_CODE = (
    SELECT DEPT_CODE
    FROM EMPLOYEE
    WHERE EMP_NAME = '전지연'   
)
 AND EMP_NAME != '전지연';











