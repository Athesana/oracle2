/*
    <SUBQUERY>
        하나의 SQL문 안에 포함된 또 다른 SQL 문을 뜻한다.
        메인 쿼리(기존 쿼리, 기본 쿼리)를 보조하는 역할을 하는 쿼리문이다.
        순서 : 먼저 서브쿼리를 실행시키고 그 결과값을 가지고 메인 쿼리를 수행하게 된다.
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
FROM EMPLOYEE; -- 결과 값은 1행 1열(1,380,000)

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

-- 위 쿼리를 서브쿼리로 작성하는 메인 쿼리 작성(ANSI)
SELECT E.EMP_ID, E.EMP_NAME, D.DEPT_TITLE, E.JOB_CODE, E.SALARY
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
GROUP BY DEPT_CODE; -- 결과 값은 1행 1열(17,700,000)

SELECT DEPT_TITLE, SUM(SALARY)
FROM EMPLOYEE E -- 여기에서 먼저 실행시켜보려고 하면 에러가 난다. SUM은 그룹함수이기 때문에 1개의 결과 값만 나오는데 DEPT_TITLE은 결과값이 많기 때문에 에러!
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

/* 서브 쿼리는 WEHRE 절 뿐 아니라 SELECT / FROM / HAVING 절에서도 사용이 가능하다.*/
SELECT DEPT_CODE, SUM(SALARY)
FROM EMPLOYEE
GROUP BY DEPT_CODE
--WHERE SUM(SALARY) = 17700000; -- 그룹에 대한 조건은 HAVING으로 적어야 하기 때문에 에러 발생
HAVING SUM(SALARY) = (
    SELECT MAX(SUM(SALARY))
    FROM EMPLOYEE
    GROUP BY DEPT_CODE
);


-- 5) 전지연 사원이 속해있는 부서원들을 조회 (단, 전지연 사원은 제외)
-- 사번, 사원명, 전화번호, (직급명, 부서명) JOIN , 입사일
-- ANSI 구문

SELECT DEPT_CODE
FROM EMPLOYEE
WHERE EMP_NAME = '전지연';

SELECT E.EMP_ID, E.EMP_NAME, E.PHONE, J.JOB_NAME, D.DEPT_TITLE, E.HIRE_DATE
FROM EMPLOYEE E
LEFT JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
LEFT JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
WHERE E.DEPT_CODE = (
    SELECT DEPT_CODE
    FROM EMPLOYEE
    WHERE EMP_NAME = '전지연'   
)
 AND EMP_NAME != '전지연';
-- WHERE E.DEPT_CODE = 'D1' AND EMP_NAME != '전지연'; 이 형태에서 'D1'인 데다가 지우고 ()를 넣고 서브쿼리를 넣어서 최종적으로 모양이 저렇게 나온다.

-----------------------------------------------------------------------------------------------
/*       
     <다중행 서브 쿼리>
        서브 쿼리의 조회 결과 값의 행의 개수가 여러 행일 때 (열은 1개)
        
        IN / NOT IN (서브쿼리) : 여러 개의 결과값 중에서 한 개라도 일치하는 값이 있다면(IN) 혹은 없다면(NOT IN) TRUE를 리턴
        ANY : 여러 개의 값들 중에서 한 개라도 만족하면 TRUE, IN과 다른 점은 비교 연산자를 사용한다는 점이다.
                SALARY = ANY(...) : IN과 같은 결과
                SALARY != ANY(...) : NOT IN과 같은 결과 = 하나라도 만족하지 않으면 TRUE를 리턴
                SALARY > ANY(...) : 목록들 중에 하나라도 큰 값이 있으면 TRUE, 즉 최소값 보다 크면 TURE를 리턴
                SALARY < ANY(...) : 목록들 중에 하나라도 작은 값이 있으면 TRUE, 즉 최대값 보다 작으면 TRUE를 리턴
        ALL : 여러 개의 값들 모두와 비교하여 만족해야만 TRUE
                SALARY > ALL(...) : 최대값 보다 크면 TURE를 리턴 (최대값보다 커야 목록값 모두보다 큰 조건을 만족하기 때문에)
                SALARY < ALL(...) : 최소값 보다 작으면 TRUE를 리턴
*/
-- 1) 각 부서별 최고 급여를 받는 직원의 이름, 직급코드, 부서 코드, 급여 조회
-- 부서별 최고 급여 조회
SELECT MAX(SALARY)
FROM EMPLOYEE
GROUP BY DEPT_CODE; -- (2890000, 3660000, 8000000, 3760000, 3900000, 2490000, 2550000)

-- 위 급여를 받는 사원들 조회
SELECT EMP_NAME, JOB_CODE, NVL(DEPT_CODE,'부서없음'), SALARY
FROM EMPLOYEE
WHERE SALARY IN (2890000, 3660000, 8000000, 3760000, 3900000, 2490000, 2550000)
ORDER BY DEPT_CODE;

-- 위의 쿼리문을 합쳐서 하나의 쿼리문으로 작성
SELECT EMP_NAME, JOB_CODE, NVL(DEPT_CODE,'부서없음'), SALARY
FROM EMPLOYEE
WHERE SALARY IN (       -- 여기에서 IN 대신에 일반 비교 연산자 = 같은 것들은 사용 불가능
    SELECT MAX(SALARY)
    FROM EMPLOYEE
    GROUP BY DEPT_CODE
)
ORDER BY DEPT_CODE;

-- 2) 직원에 대해 사번, 이름, 부서 코드, 구분(사수인지 사원인지) 조회
-- 사수에 해당하는 사번을 조회
SELECT DISTINCT MANAGER_ID
FROM EMPLOYEE
WHERE MANAGER_ID IS NOT NULL; -- (201,204,100,200,211,207,214)

-- 사번이 위와 같은 직원들의 사번, 이름, 부서 코드, 구분(사수) 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE, '사수' AS "구분"
FROM EMPLOYEE
WHERE EMP_ID IN (201,204,100,200,211,207,214);

-- 하나의 쿼리문으로 작성
SELECT EMP_ID, EMP_NAME, DEPT_CODE, '사수' AS "구분"
FROM EMPLOYEE
WHERE EMP_ID IN (
    SELECT DISTINCT MANAGER_ID
    FROM EMPLOYEE
    WHERE MANAGER_ID IS NOT NULL
)

UNION

-- 일반 사원에 해당하는 정보 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE, '사원' AS "구분"
FROM EMPLOYEE
WHERE EMP_ID NOT IN (
    SELECT DISTINCT MANAGER_ID
    FROM EMPLOYEE
    WHERE MANAGER_ID IS NOT NULL
);

-- 위의 결과들을 하나의 결과로 확인 (위에 UNION방식)

-- SELECT 절에 서브 쿼리를 사용하는 방법
SELECT EMP_ID, EMP_NAME, DEPT_CODE,
       CASE 
            WHEN EMP_ID IN (201,204,100,200,211,207,214) THEN '사수'
            ELSE '사원'
       END AS "구분"
FROM EMPLOYEE;

-- 여기까지 하고 IN ()안에 서브쿼리를 작성한다.

SELECT EMP_ID, EMP_NAME, DEPT_CODE,
       CASE 
            WHEN EMP_ID IN (
                SELECT DISTINCT MANAGER_ID
                FROM EMPLOYEE
                WHERE MANAGER_ID IS NOT NULL
            ) THEN '사수'
            ELSE '사원'
       END AS "구분"
FROM EMPLOYEE;

-- 3) 대리 직급임에도 과장 직급들의 최소 급여보다 많이 받는 직원의 사번, 이름, 직급, 급여 조회
SELECT MIN(SALARY)
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE JOB_NAME = '과장'; -- (2200000, 2500000, 3760000)

-- 직급이 대리인 직원들 중에서 위 목록들 값 중에 하나라도 큰 경우
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE J.JOB_NAME = '대리' AND SALARY > ANY(2200000, 2500000, 3760000); 
-- SALARY > 220만 라는 뜻 => 최소값보다 크다 OR SALARY > 250만보다 크다 => 최소값보다 크다 OR SALARY > 376만 => 최소값보다 크다라는 뜻

-- 하나의 쿼리문으로 합쳐보기
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE J.JOB_NAME = '대리' AND SALARY > ANY(
    SELECT MIN(SALARY)
    FROM EMPLOYEE E
    JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
    WHERE JOB_NAME = '과장'
);

-- 4) 과장 직급임에도 차장 직급의 최대 급여보다 더 많이 받는 직원들의 사번, 이름, 직급, 급여 조회
-- 차장 직급들의 급여 조회
SELECT SALARY
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE JOB_NAME = '차장'; -- (2800000, 1550000, 2490000, 2480000)

-- 과장 직급에도 차장 직급의 최대 급여보다 더 많이 받는 직원
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY
FROM EMPLOYEE E
JOIN JOB J USING (JOB_CODE)
WHERE J.JOB_NAME = '과장' AND SALARY > ALL(2800000, 1550000, 2490000, 2480000); 

-- SALARY > 280만원 AND SALARY > 155만 AND SALARY > 249만 AND SALARY > 248만 이 모든 조건을 충족해야 한다.

SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY
FROM EMPLOYEE E
JOIN JOB J USING (JOB_CODE)
WHERE J.JOB_NAME = '과장' AND SALARY > ALL(
    SELECT SALARY
    FROM EMPLOYEE E
    JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
    WHERE JOB_NAME = '차장'
);

-----------------------------------------------------------------------------------------------
/*       
     <다중열 서브 쿼리>
        서브 쿼리의 조회 결과 값이 한 행이지만 컬럼이 여러 개 일 때
        일반 연산자 같이 사용 가능하다.
*/
-- 1) 하이유 사원과 같은 부서 코드, 같은 직급 코드에 해당하는 사원들 조회
-- 하이유 사원의 부서 코드과 직급 코드 조회
SELECT DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE EMP_NAME = '하이유'; -- D5, J5

-- 부서 코드가 D5이면서 직급 코드가 J6인 사원들 조회
SELECT EMP_NAME, DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = 'D5' AND JOB_CODE = 'J5';

-- 각각 단일행 서브 쿼리로 작성
SELECT EMP_NAME, DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = (
    SELECT DEPT_CODE        -- 단일행 서브 쿼리
    FROM EMPLOYEE
    WHERE EMP_NAME = '하이유'
)
AND JOB_CODE = (
    SELECT JOB_CODE     -- 단일행 서브 쿼리
    FROM EMPLOYEE
    WHERE EMP_NAME = '하이유'
);

-- 다중열 서브 쿼리를 사용해서 하나의 쿼리로 작성
SELECT EMP_NAME, DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE (DEPT_CODE, JOB_CODE) = (  -- = 가 IN보다 더 효율적
    SELECT DEPT_CODE, JOB_CODE
    FROM EMPLOYEE
    WHERE EMP_NAME = '하이유' -- 서브 쿼리만 작동시켜보면 하나의 행이지만 WHERE 절에서 두 개의 목록을 쌍으로 묶어서 조회한다.
);

SELECT EMP_NAME, DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE (DEPT_CODE, JOB_CODE) IN ( -- IN 도 가능한데, IN (('D5','J5'))의 형태라고 봐야한다. 쌍으로 묶인 값 1개만 존재하는 것이다.  != ('D5', 'J5') 두 개가 나열된게 아니다.
    SELECT DEPT_CODE, JOB_CODE
    FROM EMPLOYEE
    WHERE EMP_NAME = '하이유' 
);

-- 2) 박나라 사원과 직급 코드가 일치하면서 같은 사수를 가지고 있는 사원의 사번, 이름, 직급 코드, 사수 사번 조회
-- 박나라 사원의 직급 코드와 사수의 사번을 조회 --> 결과값 1행의 여러 열
SELECT JOB_CODE, MANAGER_ID
FROM EMPLOYEE
WHERE EMP_NAME = '박나라'; -- J7, 207

SELECT EMP_ID, EMP_NAME, DEPT_CODE, MANAGER_ID
FROM EMPLOYEE
WHERE JOB_CODE = 'J7' AND MANAGER_ID = 207;

-- 위 쿼리문을 다중열 서브 쿼리로 사용하는 메인 쿼리문 작성
SELECT EMP_ID, EMP_NAME, DEPT_CODE, MANAGER_ID
FROM EMPLOYEE
WHERE (JOB_CODE, MANAGER_ID) = (   -- WHERE(JOB_CODE, MANAGER_ID) IN (('J7', 207))
    SELECT JOB_CODE, MANAGER_ID
    FROM EMPLOYEE
    WHERE EMP_NAME = '박나라'
);

SELECT EMP_ID, EMP_NAME, DEPT_CODE, MANAGER_ID
FROM EMPLOYEE
WHERE (JOB_CODE, MANAGER_ID) IN (
    SELECT JOB_CODE, MANAGER_ID
    FROM EMPLOYEE
    WHERE EMP_NAME = '박나라'
);

-----------------------------------------------------------------------------------------------
/*       
     <다중행 다중열 서브 쿼리>
        서브 쿼리의 조회 결과 값이 여러 행, 여러 열일 경우
        등호 사용 불가능 / IN 사용 가능
*/
-- 1) 각 직급별로 최소 급여를 받는 사원들의 사번, 이름, 직급 코드, 급여 조회
-- 각 직급별 최소 급여 조회 (다중행 다중열의 형태)
SELECT JOB_CODE, MIN(SALARY)
FROM EMPLOYEE
GROUP BY JOB_CODE;

-- 각 직급별 최소 급여를 받는 사원들의 사번, 이름, 직급 코드, 급여 조회
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE JOB_CODE = 'J2' AND SALARY = 3700000 --  노옹철
   OR JOB_CODE = 'J7' AND SALARY = 1380000 -- 방명수
   OR JOB_CODE = 'J3' AND SALARY = 3400000; -- 유재식
   -- 이렇게 직급 코드 별로 일일히 나열하는 것은 비효율적

SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE (JOB_CODE, SALARY) IN (('J2',3700000), ('J3', 3400000), ('J7', 1380000));
    -- 이렇게 쌍으로 묶는것도 간단해졌지만 여전히 비효율적

-- 다중행 다중열 서브 쿼리 사용해서 각 직급별로 최소 급여를 받는 사원의 사번, 이름, 직급 코드, 급여 조회
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE (JOB_CODE, SALARY) IN (
    SELECT JOB_CODE, MIN(SALARY)
    FROM EMPLOYEE
    GROUP BY JOB_CODE
)
ORDER BY JOB_CODE;

-- 2) 각 부서별 최소 급여를 받는 사원들의 사번, 이름, 부서 코드, 급여 조회
SELECT NVL(DEPT_CODE,'부서없음'), MIN(SALARY)
FROM EMPLOYEE
GROUP BY DEPT_CODE;

SELECT EMP_ID, EMP_NAME, NVL(DEPT_CODE,'부서없음'), SALARY
FROM EMPLOYEE
WHERE (NVL(DEPT_CODE,'부서없음'), SALARY) IN (
    SELECT NVL(DEPT_CODE,'부서없음'), MIN(SALARY)
    FROM EMPLOYEE
    GROUP BY DEPT_CODE
)
ORDER BY DEPT_CODE;

-----------------------------------------------------------------------------------------------
/*       
     <인라인 뷰>
        FROM 절에 (테이블명을 제시하는게 아니라) 서브쿼리를 제시하고, 서브 쿼리를 수행한 결과를 테이블 대신에 사용한다.
*/
-- 1) 인라인 뷰를 활용한 TOP-N 분석
-- 전 직원 중 급여가 가장 높은 상위 5명의 순위, 이름, 급여 조회
-- * ROWNUM : 오라클에서 제공하는 컬럼, 조회된 순서대로 1부터 순번을 부여하는 컬럼이다.
--            ORDER BY 하기 전에 이미 순번이 정해진 다음에 정렬이 실행되기 때문에 뒤에 ORDER BY DESC; 같은 것을 붙일 수 없다.
SELECT ROWNUM, EMP_NAME, SALARY
FROM EMPLOYEE;
-- 순서 : FROM -> SELECT(순번이 정해진다.) -> ORDER BY
-- 순위를 메길 때 이미 SELECT 때 결과가 만들어지기 때문에 결과값을 테이블대신 사용하고 SELECT 을 수행시키면서 내림차순으로 정렬된 행들에 ROWNUM을 사용해서 순번을 붙여서 원하는 결과로 만들어준다.

-- 해결 방법 <서브쿼리만들기>
-- ORDER BY 한 결과값을 가지고 ROWNUM을 부여한다. (인라인 뷰 사용)
-- 급여가 높은 순서대로 내림차순으로 정렬된 결과가 나온다.
SELECT EMP_NAME, SALARY
FROM EMPLOYEE
ORDER BY SALARY DESC;
-- 이미 정렬된 이 서브쿼리를 FROM 절 뒤에 사용해서 테이블 대신해서 사용하겠다.

SELECT ROWNUM AS "순위",
       EMP_NAME AS "사원명", 
       SALARY "급여"   -- 서브 쿼리에서 2개의 컬럼만 가지고 조회했기 때문에 *로 해도 2개의 컬럼 값만 보이게 된다.
FROM (
    SELECT EMP_NAME, SALARY
    FROM EMPLOYEE
    ORDER BY SALARY DESC
)
WHERE ROWNUM <= 5;

-- 2) 부서별 평균 급여가 높은 3개 부서의 부서 코드, 평균 급여 조회
-- 테이블 대신에 사용할 인라인 뷰를 만들자. 부서별 평균 급여를 구하자.
SELECT NVL(DEPT_CODE, '부서없음'), AVG(NVL(SALARY,0))
FROM EMPLOYEE
GROUP BY DEPT_CODE
ORDER BY 2 DESC;

SELECT ROWNUM, DEPT_CODE, ROUND(평균급여)
FROM (
    SELECT NVL(DEPT_CODE, '부서없음') AS "DEPT_CODE",   -- 인라인 뷰에서 NVL 함수 쓰고 싶으면 별칭을 붙이고 SELECT에 적어줘야 출력이 가능하다.
           AVG(NVL(SALARY,0)) AS "평균급여" 
    FROM EMPLOYEE
    GROUP BY DEPT_CODE
    ORDER BY 2 DESC
)
WHERE ROWNUM <= 3;

-- SELECT에 AVG(NVL(SALARY,0) 이라고 적으면 여기에서 컬럼은 SALARY만 있지 이 자체를 컬럼명으로 인식하지 못한다. 따라서 이렇게 적으면 에러가 나는 것

-- 2-1) WITH를 이용한 방법 -- 서브쿼리에 TOPN_SAL라고 별칭을 붙여준 것
WITH TOPN_SAL AS (
   SELECT NVL(DEPT_CODE, '부서없음') AS "DEPT_CODE", 
           AVG(NVL(SALARY,0)) AS "평균급여" 
    FROM EMPLOYEE
    GROUP BY DEPT_CODE
    ORDER BY 2 DESC
)

SELECT DEPT_CODE, ROUND(평균급여)
FROM TOPN_SAL
WHERE ROWNUM <= 3;

-----------------------------------------------------------------------------------------------
/*       
     <RANK 함수>
        [표현법]
            RANK() OVER(정렬 기준) / DENSE_RANK() OVER(정렬 기준)
            
        RANK() OVER(정렬 기준) : 동일한 순위 이후의 등수를 동일한 인원수만큼 건너뛰고 순위를 계산한다. (ex. 공동 1위가 2명이면 그 다음 순위는 3위)
        DENSE_RANK() OVER(정렬 기준) : 동일한 순위 이후의 등수를 무조건 1씩 증가한다. (ex. 공동 1위가 2명이면 그 다음 순위는 2위)
        
        - WHERE절에서 조건으로써 사용불가! 무조건 SELECT절에서만 사용 -> 인라인뷰를 활용
*/
-- 사원별 급여가 높은 순서대로 순위를 매겨서, 사원명, 급여 조회
-- 공동 19위 2명 뒤에 순위는 21위
SELECT RANK() OVER(ORDER BY SALARY DESC) AS "RANK", EMP_NAME, SALARY
FROM EMPLOYEE;

-- 공동 19위 2명 뒤에 순위는 20위
SELECT DENSE_RANK() OVER(ORDER BY SALARY DESC) AS "RANK", EMP_NAME, SALARY
FROM EMPLOYEE;

-- 상위 5명만 조회
SELECT RANK, EMP_NAME, SALARY
FROM (
    SELECT RANK() OVER(ORDER BY SALARY DESC) AS "RANK", EMP_NAME, SALARY
    FROM EMPLOYEE
)
WHERE RANK <= 5;


