/*
    <VIEW(뷰)>
        SELECT 문을 저장할 수 있는 객체이다. (논리적인 가상 테이블)
        데이터를 저장하고 있지 않으며 테이블에 대한 SQL만 저장되어 있어 VIEW에 접근할 때 SQL문을 수행하면서 결과 값을 가져온다.
        OR PLEACE -> 기존 중복되는 뷰가 있으면 쿼리만 바꿔주고 없으면 새로 생성한다.
        
        [표현법]
            CREATE [OR REPLACE] VIEW 뷰명
            AS 서브 쿼리;
*/
-- '한국'에서 근무하는 사원의 사번, 이름, 부서명, 급여, 근무 국가명을 조회하시오.
SELECT E.EMP_ID, E.EMP_NAME, D.DEPT_TITLE, E.SALARY, N.NATIONAL_NAME
FROM EMPLOYEE E
JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID) -- 부서가 없는 사원 3명은 조회되지 않는다.
JOIN LOCATION L ON (D.LOCATION_ID = L.LOCAL_CODE)
JOIN NATIONAL N ON (L.NATIONAL_CODE = N.NATIONAL_CODE) -- 여기까지 22명 조회
WHERE N.NATIONAL_NAME = '한국'; -- 10명 조회

-- '러시아'에서 근무하는 사원의 사번, 이름, 부서명, 급여, 근무 국가명을 조회하시오. (복잡하지만 자주사용하는 쿼리를 매번 작성,복붙하면 귀찮아 -> VIEW 사용)
-- VIEW를 만들어보자.
CREATE OR REPLACE VIEW V_EMPLOYEE
AS  SELECT E.EMP_ID, E.EMP_NAME, D.DEPT_TITLE, E.SALARY, N.NATIONAL_NAME
    FROM EMPLOYEE E
    JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID) -- 부서가 없는 사원 3명은 조회되지 않는다.
    JOIN LOCATION L ON (D.LOCATION_ID = L.LOCAL_CODE)
    JOIN NATIONAL N ON (L.NATIONAL_CODE = N.NATIONAL_CODE);
    
SELECT * FROM V_EMPLOYEE; -- 22행 출력, 가상 테이블로 실제 데이터가 담겨있는 것은 아니다.    

-- 한국에서 근무하는 사원의 사번, 이름, 부서명, 급여, 근무 국가명을 조회하시오.
SELECT * 
FROM V_EMPLOYEE
WHERE NATIONAL_NAME = '한국';
    
-- 총무부에 근무하는 사원들 사원명, 급여
SELECT EMP_NAME, SALARY
FROM V_EMPLOYEE
WHERE DEPT_TITLE = '총무부';
    
SELECT * FROM USER_TABLES;
SELECT * FROM USER_VIEWS; -- 해당 계정이 가지고 있는 VIEW들에 대한 내용을 조회하는 데이터 딕셔너리이다.

/*
    <뷰 컬럼의 별칭 부여>
        서브 쿼리의 SELECT 절에 함수나 산술 연산이 기술되어 있는 경우 반드시 별칭을 지정해야 한다.
*/
-- 사원의 사번, 사원명, 성별, 근무년수를 조회할 수 있는 뷰를 생성
-- 서브 쿼리를 만들어 보자. (성별 코드를 가지고 남여를 출력하고, 현재 년도 - 입사일 년도 = 근무년수)
SELECT EMP_ID,
       EMP_NAME,
       DECODE(SUBSTR(EMP_NO, 8, 1), '1', '남', '2', '여'),
       EXTRACT(YEAR FROM SYSDATE) /*DATE -> NUMBER 타입으로 추출된다.*/ - EXTRACT(YEAR FROM HIRE_DATE)
FROM EMPLOYEE;

-- 별칭 안 붙이고 그냥 서브 쿼리를 붙이면 "must name this expression with a column alias" 오류 발생
CREATE OR REPLACE VIEW V_EMP_01
AS SELECT EMP_ID,
          EMP_NAME,
          DECODE(SUBSTR(EMP_NO, 8, 1), '1', '남', '2', '여') 성별,
          EXTRACT(YEAR FROM SYSDATE) /*DATE -> NUMBER 타입으로 추출된다.*/ - EXTRACT(YEAR FROM HIRE_DATE) 근무년수 -- 이건 그냥 함수 연산한 거를 호출하는거라서 별칭을 붙여야 한다.
   FROM EMPLOYEE;

SELECT * FROM V_EMP_01;

CREATE OR REPLACE VIEW V_EMP02 (사번, 이름, 성별, 근무년수) -- 서브 쿼리 안에 갯수와 별칭 갯수 맞춰야 한다. 별칭에 "" 붙여서 해도 된다.
AS SELECT EMP_ID,
          EMP_NAME,
          DECODE(SUBSTR(EMP_NO, 8, 1), '1', '남', '2', '여'),
          EXTRACT(YEAR FROM SYSDATE) /*DATE -> NUMBER 타입으로 추출된다.*/ - EXTRACT(YEAR FROM HIRE_DATE)
   FROM EMPLOYEE;
   
SELECT * FROM V_EMP02;

SELECT 사번, "이름", 성별, 근무년수 FROM V_EMP02; -- 별칭이 컬럼명이 되기 때문에 별칭으로도 조회가 가능하다. 나열 순서는 바뀌어도 되고, 출력 될 때는 적은 순서대로 출력된다.

-- VIEW를 삭제할 때도 DROP 구문을 통해서 삭제한다.
DROP VIEW V_EMP_01;
DROP VIEW V_EMP02;

------------------------------------------------------------------------------------------------------
/*
    <VIEW를 이용해서 DML(INSERT, UPDATE, DELETE) 사용>
        뷰를 통해 데이터를 변경하게 되면 실제 데이터가 담겨있는 기본 테이블에도 적용된다.
*/
CREATE OR REPLACE VIEW V_JOB
AS SELECT * FROM JOB;

-- VIEW에 SELECT
SELECT JOB_CODE, JOB_NAME
FROM V_JOB;

-- VIEW에 INSERT
INSERT INTO V_JOB VALUES ('J8', '알바');

SELECT * FROM V_JOB;
SELECT * FROM JOB;

-- VIEW에 UPDATE (J8의 직급명 알바 -> 인턴으로 변경)
UPDATE V_JOB 
SET JOB_NAME = '인턴'
WHERE JOB_CODE = 'J8';

SELECT * FROM V_JOB;
SELECT * FROM JOB;

-- VIEW에 DELETE (J8 삭제)
DELETE FROM V_JOB 
WHERE JOB_CODE = 'J8';

SELECT * FROM V_JOB;
SELECT * FROM JOB;



