/*
    <GROUP BY>
      그룹 기준을 제시할 수 있는 구문
      여러 개의 값들을 하나의 그룹으로 묶어서 처리할 목적으로 사용한다.
      순번, 별칭 사용 불가능 -> 정확한 컬럼명, 함수식 기재
*/
-- 전체 사원을 하나의 그룹으로 묶어서 급여의 총합을 구한 결과 조회
SELECT SUM(SALARY)
FROM EMPLOYEE;

-- 각 부서별 그룹으로 묶어서 부서별 총합을 구한 결과 조회
SELECT DEPT_CODE, SUM(SALARY)
FROM EMPLOYEE
GROUP BY DEPT_CODE
ORDER BY DEPT_CODE NULLS FIRST;

-- 전체 사원수
SELECT COUNT(*)
FROM EMPLOYEE;

-- 각 부서별 사원수
SELECT DEPT_CODE, COUNT(*)
FROM EMPLOYEE
GROUP BY DEPT_CODE
ORDER BY DEPT_CODE NULLS FIRST;

-- 각 직급별 보너스를 받는 사원수 조회
SELECT JOB_CODE, COUNT(BONUS)
FROM EMPLOYEE
GROUP BY JOB_CODE
ORDER BY 1;

-- 각 직급별 급여 평균 조회
SELECT JOB_CODE "직급코드", 
       TO_CHAR(FLOOR(AVG(NVL(SALARY, 0))), '99,999,999') AS "직급별 급여 평균"
FROM EMPLOYEE
GROUP BY JOB_CODE
ORDER BY JOB_CODE;

-- 부서별 사원수, 보너스를 받는 사원수, 급여의 합계, 평균 급여, 최고 급여, 최저 급여를 부서별 내림차순으로 조회하기
SELECT DEPT_CODE AS "부서",
       COUNT(*) AS "부서별 사원수",
       COUNT(BONUS) AS "보너스를 받는 사원수", 
       TO_CHAR(SUM(SALARY),'L99,999,999') AS "급여의 합계", 
       TO_CHAR(FLOOR(AVG(NVL(SALARY,0))), 'L99,999,999') AS "평균 급여", 
       TO_CHAR(MAX(SALARY),'L99,999,999') AS "최고 급여", 
       TO_CHAR(MIN(SALARY),'L99,999,999') AS "최저 급여"
FROM EMPLOYEE
GROUP BY DEPT_CODE
ORDER BY DEPT_CODE DESC NULLS LAST;

-- 성별 별 사원수
SELECT SUBSTR(EMP_NO, 8, 1) AS "성별"
FROM EMPLOYEE
GROUP BY SUBSTR(EMP_NO, 8, 1) -- GROUP BY 절에는 컬럼명, 계산식, 연산(함수호출) 구문이 올 수 있다. (단, 컬럼 순번, 별칭은 사용할 수 없다.)
ORDER BY "성별";

-- 여러 컬럼을 제시해서 그룹 기준을 선정 (~부서의 ~직급인 사람들끼리 묶는다는 뜻)
SELECT DEPT_CODE AS "부서 코드", 
       JOB_CODE AS "직급 코드", 
       COUNT(*) AS "직원수", 
       SUM(SALARY) AS "급여의 합"
FROM EMPLOYEE
GROUP BY DEPT_CODE, JOB_CODE
ORDER BY DEPT_CODE;

/*
    <HAVING>
      그룹에서 대한 조건을 제시할 떄 사용하는 구문, 그룹 중에서도 조건을 만족한는 그룹만 출력(주로 그룹 함수의 결과를 가지고 비교를 수행할 때 사용한다.)
      WHERE절은 그룹 함수보다 우선하기 때문에 사용할 수 없다.
      
      - 실행순서
       SELECT    -- 5 : 조회하고자 하는 컬럼명 AS "별칭" | 계산식 | 함수식, 여러 조건들을 처리한 후 남은 데이터에서 어떤 컬럼을 출력해줄지 선택한다.
       FROM      -- 1 : 조회하고자 하는 테이블명, 전체 테이블의 결과를 가져온다.
       WHERE     -- 2 : 조건식, 조건에 맞는 결과만 갖도록 데이터를 추린다.
       GROUP BY  -- 3 : 그룹 기준에 해당하는 컬럼명 | 계산식 | 함수식 (별칭 지정 불가), 선택한 컬럼으로 GROUPING 작업한 결과를 갖는다. 이제부터 그룹 함수 사용 가능
       HAVING    -- 4 : 그룹에 대한 조건식
       ORDER BY  -- 6 : 컬럼명 | 별칭 | 컬럼 순번 [ASC|DESC][NULLS FIRST|NULLS LAST], 행의 순서를 어떻게 보여줄지 정렬해준다.
*/
-- 각 부서별 급여가 300만원 이상인 직원의 평균 급여 조회 (그룹 함수 사용하기 전에 WHERE 절을 통해 급여가 300만원 이상인 직원들 데이터를 가져오고 그 데이터로 그룹핑을 한다. 그리고 SALARY를 평균을 내본다.)
SELECT DEPT_CODE, AVG(NVL(SALARY,0))
FROM EMPLOYEE 
WHERE SALARY >= 3000000
GROUP BY DEPT_CODE
ORDER BY DEPT_CODE;
 
-- 긱 부서별 평균 급여가 300만원 이상인 부서들만 조회 (각 부서별 평균 SALARY를 구하고 그 평균이 300만원 이상인 부서들만 조회하겠다.)
SELECT DEPT_CODE, FLOOR(AVG(NVL(SALARY,0)))
FROM EMPLOYEE
--- WHERE FLOOR(AVG(NVL(SALARY, 0))) >= 3000000 -- 에러 발생!
GROUP BY DEPT_CODE
HAVING FLOOR(AVG(NVL(SALARY, 0))) >= 3000000
ORDER BY DEPT_CODE;

-- 직급별 총 급여의 합이 10,000,000 이상인 직급들만 조회
SELECT JOB_CODE, TO_CHAR(SUM(SALARY), '99,999,999') AS "총 급여 합"
FROM EMPLOYEE
GROUP BY JOB_CODE
HAVING SUM(SALARY) >= 10000000
ORDER BY JOB_CODE;

-- 부서별 보너스를 받는 사원이 없는 부서들만 조회 (부서에 속한 사람이 다 보너스를 못 받는 경우)
SELECT DEPT_CODE, COUNT(BONUS) -- COUNT(BONUS)는 보너스를 받는 사람의 숫자가 나온다.
FROM EMPLOYEE
GROUP BY DEPT_CODE
HAVING COUNT(BONUS) = 0 -- NULL이면 카운팅을 하지 않으니까 COUNT(BONUS) 했을 때 0이라는거는 부서별로 묶인 사원들이 보너스를 받는지 카운팅 해봤더니 0이다, 즉, 죄다 NULL 값이라는 뜻
-- HAVING COUNT(BONUS) != 0 보너스를 받는 사람이 있는 부서 조회
ORDER BY DEPT_CODE;

/*
    <집계 함수>
      그룹별 산출한 결과 값의 중간 집계를 계산해주는 함수
      
      ROLLUP, CUBE
*/
-- 각 직급별 급여의 합계를 조회
SELECT JOB_CODE, SUM(SALARY)
FROM EMPLOYEE
GROUP BY JOB_CODE
ORDER BY JOB_CODE;

-- 마지막 행에 전체 총 급여의 합계까지 조회
SELECT JOB_CODE, SUM(SALARY)
FROM EMPLOYEE
GROUP BY ROLLUP(JOB_CODE)
ORDER BY JOB_CODE;

SELECT JOB_CODE, SUM(SALARY)
FROM EMPLOYEE
GROUP BY CUBE(JOB_CODE)
ORDER BY JOB_CODE;

-- 부서 코드도 같고 직급 코드도 같은 사원들을 그룹 지어서 해당 급여의 합계를 조회
SELECT DEPT_CODE, JOB_CODE, SUM(SALARY)
FROM EMPLOYEE
GROUP BY DEPT_CODE, JOB_CODE
ORDER BY DEPT_CODE;

-- 1. ROLLUP(컬럼1, 컬럼2, ...) -> 컬럼 1을 가지고 중간 집계를 내는 함수
SELECT DEPT_CODE, JOB_CODE, SUM(SALARY)
FROM EMPLOYEE
GROUP BY ROLLUP(DEPT_CODE, JOB_CODE)
ORDER BY DEPT_CODE;

-- 2. CUBE(컬럼1, 컬럼2, ...) -> 컬럼 1을 가지고 중간 집계를 내고, 컬럼 2를 가지고도 중간집계를 내고, 전달되는 컬럼 모두를 집계한다.
SELECT DEPT_CODE, JOB_CODE, SUM(SALARY)
FROM EMPLOYEE
GROUP BY CUBE(DEPT_CODE, JOB_CODE)
ORDER BY DEPT_CODE;

/*
    <GROUPING>
      ROULLUP이나 CUBE에 의해 산출된 값이 해당 컬럼의 집합에 산출물이면 0을 반환, 아니면 1을 반환하는 함수
*/
SELECT DEPT_CODE, 
       JOB_CODE, 
       SUM(SALARY),
       GROUPING(DEPT_CODE),
       GROUPING(JOB_CODE)
FROM EMPLOYEE
GROUP BY ROLLUP(DEPT_CODE, JOB_CODE)
ORDER BY DEPT_CODE;

SELECT DEPT_CODE, 
       JOB_CODE, 
       SUM(SALARY),
       GROUPING(DEPT_CODE),
       GROUPING(JOB_CODE)
FROM EMPLOYEE
GROUP BY CUBE(DEPT_CODE, JOB_CODE)
ORDER BY DEPT_CODE;

/*
    <집합 연산자>
      여러 개의 쿼리문을 가지고 하나의 쿼리문으로 만드는 연산자이다.
      
      UNION      : 두 쿼리문을 수행한 결과값을 더한 후 중복되는 행은 제거한다. (합집합)
      UNION ALL  : UNION과 동일하게 두 쿼리문을 수행한 결과값을 더하고 중복은 허용한다. (합집합)
      INTERSSECT : 두 쿼리문을 수행한  결과값에 중복된 결과값만 추출한다.(교집합)
      MINUS      : 선행 결과값에서 후행 결과값을 뺀 나머지 결과값만 추출한다.(차집합)
*/

-- EMPLOYEE 테이블에서 부서 코드가 D5인 사원들만 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5'; -- 6명 조회

-- EMPLOYEE 테이블에서 급여가 300만원 초과인 사원들만 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY > 3000000; -- 8명 조회

-- 1. UNION (반드시 컬럼 개수를 맞춰줘야한다.)
-- EMPLOYEE 테이블에서 부서 코드가 D5인 사원 '또는' 급여가 300만원 초과인 사원 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5'

UNION

SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY > 3000000;  -- 12명 조회

-- 위 쿼리문 대신에 WHERE 절에 OR를 사용해서 처리 가능
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5' OR SALARY > 3000000;

-- 2. UNION ALL
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5'

UNION ALL

SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY > 3000000;  -- 14명 조회

-- 3. INTERSECT 
-- EMPLOYEE 테이블에서 부서 코드가 D5 '이면서' 급여가 300만원 초과인 사원 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5'

INTERSECT

SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY > 3000000;  --  2명 조회

-- 위 쿼리문 대신에 WHERE 절에 AND를 사용해서 처리 가능
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5' AND SALARY > 3000000;

-- 4. MINUS
-- 부서 코드가 D5인 사원들 중에서 급여가 300만원 초과인 사원들을 제외해서 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5'

MINUS

SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY > 3000000;  -- 4명 조회

-- 위 쿼리문 대신에 WHERE 절에 AND를 사용해서 처리 가능
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5' AND SALARY <= 3000000;

/*
    <GROUPING SET>
      그룹 별로 처리된 여러 개의 SELECT 문을 하나로 합친 결과를 원할 때 사용한다.
      - 컬럼의 타입이 같기 때문에 UNION ALL이 가능하다. 대신에 컬럼명은 처음에 해당하는 쿼리문의 컬럼명으로 고정이 된다.
*/

-- 부서별 사원수
SELECT DEPT_CODE, COUNT(*)
FROM EMPLOYEE
GROUP BY DEPT_CODE

UNION ALL

-- 직급별 사원수
SELECT JOB_CODE, COUNT(*)
FROM EMPLOYEE
GROUP BY JOB_CODE;

-- GROUPING SETS을 이용해보자.
SELECT DEPT_CODE, JOB_CODE, COUNT(*)
FROM EMPLOYEE
GROUP BY GROUPING SETS(DEPT_CODE, JOB_CODE);


-----------------------
-- DEPT_CODE, JOB_CODE, MANAGER_ID가 동일한 사원들의 급여 평균을 구해보자.
SELECT DEPT_CODE, JOB_CODE, MANAGER_ID, FLOOR(AVG(NVL(SALARY,0)))
FROM EMPLOYEE
GROUP BY DEPT_CODE, JOB_CODE, MANAGER_ID;

SELECT DEPT_CODE, MANAGER_ID, FLOOR(AVG(NVL(SALARY,0)))
FROM EMPLOYEE
GROUP BY DEPT_CODE, MANAGER_ID;

SELECT JOB_CODE, MANAGER_ID, FLOOR(AVG(NVL(SALARY,0)))
FROM EMPLOYEE
GROUP BY JOB_CODE, MANAGER_ID;

-- 위의 쿼리를 각각 실행해서 합친 것과 동일한 결과를 갖는다.
SELECT DEPT_CODE, JOB_CODE, MANAGER_ID, FLOOR(AVG(NVL(SALARY, 0)))
FROM EMPLOYEE
GROUP BY GROUPING SETS((DEPT_CODE, JOB_CODE, MANAGER_ID),(DEPT_CODE, MANAGER_ID),(JOB_CODE, MANAGER_ID));




