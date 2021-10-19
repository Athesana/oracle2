/*
    <VIEW(뷰)>
        SELECT 문을 저장할 수 있는 객체이다. (논리적인 가상 테이블)
        데이터를 저장하고 있지 않으며 테이블에 대한 SQL만 저장되어 있어 VIEW에 접근할 때 SQL문을 수행하면서 결과 값을 가져온다.
        데이터를 가지고 있는 것이 아니라 쿼리를 가지고, 쿼리를 수행한 결과를 가지고 와서 테이블처럼 사용한다.
        OR PLEACE -> 기존 중복되는 뷰가 있으면 쿼리만 바꿔주고 없으면 새로 생성한다.
        
        [표현법]
            CREATE [OR REPLACE] VIEW 뷰명
            AS 서브 쿼리;
            
        - 사용자계정생성.sql 파일에서 GRANT CREATE VIEW TO KH; 했음
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
    
SELECT * FROM V_EMPLOYEE; -- FROM에 뷰 이름을 적기. 22행 출력, 가상 테이블로 실제 데이터가 담겨있는 것은 아니다.    

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

CREATE OR REPLACE VIEW V_EMP02 (사번, 이름, 성별, 근무년수) -- 모든 컬럼에 별칭을 부여해야 한다. 서브 쿼리 안에 갯수와 별칭 갯수 맞춰야 한다. 별칭에 "" 붙여서 해도 된다.
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

--------------------------------------------------------------------------------------
/*
    <DML 구문으로 VIEW 조작이 불가능한 경우>
        1) 뷰 정의에 포함되지 않는 컬럼을 조작하는 경우
        2) 뷰에 포함되지 않는 컬럼 중에 기본 테이블 상에 NOT NULL 제약 조건이 지정된 경우 (PK처럼 기본적으로 NOT NULL 제약조건이 있으면 동일하기 때문에 에러)
        3) 산술 표현식으로 정의된 경우
        4) 그룹 함수나 GROUP BY 절을 포함한 경우 (INSERT, UPDATE, DELETE 모두 허용하지 않는다.)
        5) DISTINCT를 포함한 경우 (INSERT, UPDATE, DELETE 모두 허용하지 않는다.)
        6) JOIN을 이용해서 여러 테이블을 연결한 경우
*/
-- 1) 뷰 정의에 포함되지 않는 컬럼을 조작하는 경우 뷰 테이블은 생성할 때 JOB 테이블의 컬럼 하나만 가지고 정의를 했는데 INSERT로 컬럼 값 2개를 넣으려고 하면 에러가 발생 "too many values" 
CREATE OR REPLACE VIEW VM_JOB2
AS  SELECT JOB_CODE
    FROM JOB;

-- INSERT

INSERT INTO VM_JOB2 VALUES('J8', '알바'); -- 에러
INSERT INTO VM_JOB2 VALUES('J8'); -- 가능 

SELECT * FROM VM_JOB2; -- J8이 삽입되어 있다.
SELECT * FROM JOB;  -- 대신 JOB_CODE에는 J8 들어가고 JOB_NAME에는 NULL이 들어간다.
-- UPDATE

UPDATE VM_JOB2
SET JOB_NAME = '알바'
WHERE JOB_CODE = 'J8';  -- JOB_CODE만 가지고 정의해놓고 JOB_NAME을 업데이트하는건 나는 모르겠어 "invalid identifier" 에러

UPDATE VM_JOB2
SET JOB_CODE = 'J0'
WHERE JOB_CODE = 'J8'; -- 가능

-- DELETE
DELETE FROM VM_JOB2
WHERE JOB_NAME = '사원'; -- "invalid identifier" 에러 발생

DELETE FROM VM_JOB2
WHERE JOB_CODE = 'J0';  -- 가능

ROLLBACK;

SELECT * FROM VM_JOB2;
SELECT * FROM JOB;   -- JOB_CODE에는 J8이 들어가지만 JOB_NAME에는 기본적으로 NULL이 삽입된다.

-- 2) 뷰에 포함되지 않는 컬럼 중에 기본 테이블 상에 NOT NULL 제약 조건이 지정된 경우 -- UPDATE만 가능
-- 정의된 컬럼만 가지고 작동하면 기본 테이블의 나머지 컬럼에는 NULL이 들어간다. 그럴 때 NULL이 들어갈 수 없는 제약조건이 걸린 컬럼에 INSERT는 에러가 발생한다.
CREATE OR REPLACE VIEW V_JOB3
AS SELECT JOB_NAME
   FROM JOB;

-- INSERT
-- 기본 테이블인 JOB 테이블에 JOB_CODE는 NOT NULL 제약조건이 있기 때문에 오류가 발생한다.
INSERT INTO V_JOB3 VALUES('알바'); -- "too many values" / '알바'만 하려고 해도 cannot insert NULL into ("KH"."JOB"."JOB_CODE")

-- UPDATE
UPDATE V_JOB3
SET JOB_NAME = '인턴'
WHERE JOB_NAME = '사원'; -- VIEW에 있는 JOB_NAME 컬럼 1개를 가지고 변경하는 것이기 때문에 가능!

-- DELETE (FK 제약조건으로 인해서 삭제되지 않는다.) (제약조건이 없다면 삭제된다.)
DELETE FROM V_JOB3
WHERE JOB_NAME = '인턴'; -- child record found, integrity constraint (KH.EMPLOYEE_JOB_CODE_FK) violated - child record found

SELECT * FROM V_JOB3;
SELECT * FROM JOB;

ROLLBACK;  -- 인턴 -> 사원으로 다시 바꿈

-- 3) 산술 표현식으로 정의된 경우
-- 사원들의 연봉을 조회하는 뷰를 만들자.
CREATE OR REPLACE VIEW V_EMP_SAL
AS SELECT EMP_ID, 
          EMP_NAME, 
          SALARY,
          SALARY * 12 AS "연봉"
   FROM EMPLOYEE;

SELECT * FROM V_EMP_SAL; -- 기본 테이블에 없는 산술 연산 정보를 보여주고 있다.
SELECT * FROM EMPLOYEE; -- 기본 테이블에는 연봉 정보는 없다.

-- INSERT
INSERT INTO V_EMP_SAL VALUES (800, '홍길동', 3000000, 36000000); -- "virtual column not allowed here" 실제 테이블에 존재하는 컬럼이 아닌 가상 컬럼이기 때문에 실제 값을 INSERT하려고 하니까 에러 발생

-- UPDATE
UPDATE V_EMP_SAL
SET "연봉" = 80000000 -- "연봉" 이라는 컬럼은 가상 컬럼이야(물리적으로 존재하지 않고 연산으로 만들어진 컬럼) 이라서 이걸 수정할 수는 없다.
WHERE EMP_ID = 200;   -- "virtual column not allowed here"

-- 산술연산과 무관한 컬럼은 변경 가능 (SALARY는 실제 있는 컬럼)
UPDATE V_EMP_SAL
SET SALARY = 5000000
WHERE EMP_ID = 200;

SELECT * FROM V_EMP_SAL;
SELECT * FROM EMPLOYEE;

-- DELETE (가상 컬럼 삭제시 별칭 이용 가능하다.)
-- (반면, SELECT에서 WHERE 절에 "연봉" = 60000000; 이런 식으로 별칭은 사용 불가능 -> WHY? 실행 순서 때문에, FROM -> WHERE -> SELECT라서 이렇게 하면 WHERE절은 별칭을 몰라~ 그래서 에러)
DELETE FROM V_EMP_SAL
WHERE "연봉" = 60000000;

ROLLBACK;

-- 4) 그룹 함수나 GROUP BY 절을 포함한 경우 : 여러 개 값을 모아서 하나의 결과로 만든 것이기 때문에 (INSERT, UPDATE, DELETE를 모두 허용하지 않는다.)
SELECT DEPT_CODE, SUM(SALARY), FLOOR(AVG(NVL(SALARY,0)))
FROM EMPLOYEE
GROUP BY DEPT_CODE;

-- 별칭 필수!
CREATE OR REPLACE VIEW V_DEPT
AS SELECT DEPT_CODE, SUM(SALARY) 합계 , FLOOR(AVG(NVL(SALARY,0))) 평균
   FROM EMPLOYEE
   GROUP BY DEPT_CODE;

SELECT * FROM V_DEPT;

-- INSERT
INSERT INTO V_DEPT VALUES ('D0', 8000000, 4000000); -- "virtual column not allowed here" 가상 컬럼에 함수식 INSERT는 에러! 그리고 그룹을 짓고 합계랑 평균을 구한건데 그냥 값을 하나 떡하니 넣는 것은 놉!

-- UPDATE
UPDATE V_DEPT
SET DEPT_CODE = 'D0'
WHERE DEPT_CODE = 'D1'; -- 에러 발생

UPDATE V_DEPT
SET "합계" = 12000000
WHERE DEPT_CODE = 'D1'; -- 총 합계를 바꾼다는건 각 직원들의 급여들이 각각 얼마씩은 바뀌어야 되는데 그걸 전혀 모르기 때문에 불가능

-- DELETE
DELETE FROM V_DEPT
WHERE DEPT_CODE = 'D1'; -- 에러 발생 / 그룹으로 묶었기 때문에 원본 테이블의 여러 개를 지워야 하는 상황이 발생하기 때문에 안된다.

-- 5) DISTINCT를 포함한 경우 (INSERT, UPDATE, DELETE를 모두 허용하지 않는다.)
CREATE OR REPLACE VIEW V_DT_JOB
AS SELECT DISTINCT JOB_CODE
   FROM EMPLOYEE;

SELECT * FROM V_DT_JOB; -- JOB_CODE가 중복제거 되고 출력된다.

-- INSERT
INSERT INTO V_DT_JOB VALUES('J8'); -- "data manipulation operation not legal on this view" 중복 제거했는데 INSERT한다? 놉!

-- UPDATE
UPDATE V_DT_JOB
SET JOB_CODE = 'J8'
WHERE JOB_CODE = 'J7'; -- J7은 여러 명 사원의 중복된 부서코드를 제거하고 나온 것이기 때문에 INSERT와 동일한 에러 발생

-- DELETE
DELETE FROM V_DT_JOB
WHERE JOB_CODE = 'J7'; -- 에러 

-- 6) JOIN을 이용해서 여러 테이블을 연결한 경우
CREATE OR REPLACE VIEW V_EMP
AS SELECT E.EMP_ID, E.EMP_NAME, D.DEPT_TITLE
   FROM EMPLOYEE E
   JOIN DEPARTMENT D ON E.DEPT_CODE = D.DEPT_ID;

SELECT * FROM V_EMP;

-- INSERT (JOIN 된 뷰는 수정이 불가능)
INSERT INTO V_EMP VALUES (800, '홍홍홍', '총무부'); -- "cannot modify more than one base table through a join view"

-- UPDATE
UPDATE V_EMP
SET EMP_NAME = '서동일'
WHERE EMP_ID = 200;  -- 성공!

UPDATE V_EMP
SET DEPT_TITLE = '총무1팀'
WHERE EMP_ID = 200;  -- 에러! E.DEPT_CODE를 통해서 D.DEPT_ID를 참조하고 있다. DEPT_TITLE을 가지고 있는 사원이 여러 명이라서 하나만 바꿀 수 없다. DEPT_TITLE은 조인된 DEPARTMENT 테이블에 있어서 추가/수정이 불가능

-- DELETE
DELETE FROM V_EMP
WHERE EMP_ID = 200; -- 성공!

DELETE FROM V_EMP
WHERE DEPT_TITLE = '총무부'; -- 2개 행이 삭제되었다. 서브 쿼리에 있는 FROM 절의 EMPLOYEE 테이블에만 영향을 준다.

SELECT *
FROM DEPARTMENT; -- DEPARTMENT 테이블은 영향이 없다.

SELECT *
FROM EMPLOYEE;

ROLLBACK;

---------------------------------------------------------------------------
/*
    <VIEW 옵션>
        [표현법]
            CREATE [OR REPLACE] [FORCE | NOFORCE] VIEW 뷰명
            AS 서브 쿼리
            [WITH CHECK OPTION]
            [WITH READ ONLY];
            
        - OR REPLACE : 기존에 동일한 뷰가 있으면 덮어쓰고, 존재하지 않으면 뷰를 새로 생성한다.
        - FORCE : 서브 쿼리에 기술된 테이블이 존재하지 않는 테이블이여도 뷰가 생성된다.
        - NOFORCE : 서브 쿼리에 기술된 테이블이 존재해야만 뷰가 생성된다. (기본값)
        - WITH CHECK OPTION : 서브 쿼리에 기술된 조건에 부합하지 않는 값으로 수정하는 경우에 오류를 발생시킨다.
        - WITH READ ONLY : 뷰에 대해서 조회만 가능하다. (DML : INSERT/UPDATE/DELETE 수행 불가능)
*/
-- 1) OR REPLACE (업무에서는 빼고 작성하는 것을 추천, 함부로 수정이 되어버릴 수가 있기때문에)
CREATE OR REPLACE VIEW V_EMP01
AS SELECT EMP_ID, EMP_NAME, SALARY
   FROM EMPLOYEE;  -- OR REPLACE 없이 작성하면 뷰가 이미 생성 되어버려서 뒤이어서 추가하고 싶은 컬럼이 있다거나 하는 등의 수정하고 싶으면 불가능 -> OR REPLACE 옵션을 적고 다시 실행하면 기존 뷰에 수정이 된다.

SELECT * FROM USER_VIEWS WHERE VIEW_NAME = 'V_EMP01';

-- 2) FORCE | NOFORCE 
-- NOFORCE (TT라는 테이블은 없기 때문에 "table or view does not exist" 에러, NOFORCE가 기본값이라서 생략해도 마찬가지)
CREATE OR REPLACE /* NOFORCE */ VIEW V_EMP02
AS SELECT TCODE, TNAME, TCONTENT
   FROM TT;

-- FORCE (명시적으로 적어야 한다. 컴파일 오류 = "table or view does not exist" 와 함께 뷰가 생성되었습니다.)
CREATE OR REPLACE FORCE VIEW V_EMP02
AS SELECT TCODE, TNAME, TCONTENT
   FROM TT;

SELECT * FROM USER_VIEWS WHERE VIEW_NAME = 'V_EMP02';
SELECT * FROM V_EMP02; -- 에러 발생! 뷰는 생성되었지만 실제 테이블이 없기 때문에, 테이블을 만들고 나서는 사용할 수 있다.

-- TT 테이블을 생성하면 그때부터 VIEW 조회 가능
CREATE TABLE TT(
    TCODE NUMBER, 
    TNAME VARCHAR2(10),
    TCONTENT VARCHAR2(20)
);

SELECT * FROM V_EMP02;

-- 3) WITH CHECK OPTION
-- 전체 직원 중 급여 300 이상인 사람 조회
CREATE OR REPLACE VIEW V_EMP03
AS SELECT *
   FROM EMPLOYEE
   WHERE SALARY >= 3000000
WITH CHECK OPTION;

SELECT * FROM V_EMP03;
SELECT * FROM USER_VIEWS WHERE VIEW_NAME = 'V_EMP03'; -- WITH CHECK OPTION 적용한 후 조회해보는 딕셔너리

-- 200 사원의 급여를 200만원으로 변경해보자. 
-- <서브 쿼리 조건에 부합하지 않기 때문에 변경이 불가능>
UPDATE V_EMP03
SET SALARY = 2000000
WHERE EMP_ID = 200; -- 엥? 200번 사원이 사라짐 / 왜냐 V_EMP03 뷰는 300이상인 사람만 나와있으니까 -> SELECT * FROM EMPLOYEE;로 조회해보면 200만원으로 바뀌어있다.
-- WITH CHECK OPTION 하면 애초에 300만원 이상인 사람만 데이터로 가지게 V_EMP03 뷰를 만든건데
-- 200만원으로 바꾸려고 하니까 이 옵션 설정한 뷰를 만들고나서 이 UPDATE를 다시 실행할 때는 에러 발생(view WITH CHECK OPTION where-clause violation)

-- 200 사원의 급여를 200만원 이상의 값으로 변경해보자. 
-- <서브 쿼리 조건에 부합하기 때문에 변경이 가능>
UPDATE V_EMP03
SET SALARY = 3000000
WHERE EMP_ID = 200; -- EMPLOYEE, 뷰 조회해보면 300만원으로 바뀌었음 (서브쿼리 조건절에 기술된 조건에 부합하는 경우에만 실행이 되고 안되면 에러 발생시킨다.)

SELECT * FROM EMPLOYEE; -- 200번 사원 급여가 200만원으로 바뀜

ROLLBACK;

-- 4) WITH READ ONLY (웬만한 VIEW에 다 붙는다)
CREATE OR REPLACE VIEW V_DEPT02
AS SELECT *
   FROM DEPARTMENT
WITH READ ONLY; -- 옵션 추가!

SELECT * FROM V_DEPT02;
SELECT * FROM USER_VIEWS WHERE VIEW_NAME = 'V_DEPT02';

-- INSERT
INSERT INTO V_DEPT02 VALUES('D0', '해외영업4부', 'L5');

-- UPDATE
UPDATE V_DEPT02
SET LOCATION_ID = 'L2'
WHERE DEPT_TITLE = '해외영업4부';

-- DELETE
DELETE FROM V_DEPT02
WHERE DEPT_ID = 'D0';

-- 옵션 추가 후에 3가지 작업 하려고 하면  "cannot perform a DML operation on a read-only view"
















