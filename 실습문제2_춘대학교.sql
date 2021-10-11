-- [Basic SELECT] --
-- 1. 춘 기술 대학교의 학과 이름과 계열을 표시하시오. 단 출력 헤더는 "학과 명", "계열" 으로 표시하도록 한다. // 63 ROWS SELECTED
SELECT DEPARTMENT_NAME AS "학과 명", CATEGORY AS "계열"
FROM TB_DEPARTMENT;

-- 2. 학과의 학과 정원을 다음과 같은 형태로 화면에 출력한다. // 연결 연산자 || 을 사용 // 63 ROWS SELECTED
SELECT DEPARTMENT_NAME || '의 정원은 ' || CAPACITY || '명 입니다.' AS "학과별 정원"
FROM TB_DEPARTMENT;

-- 3. "국어국문학과"에 다니는 여학생 중 현재 휴학중인 여학생을 찾아달라는 요청이 들어왔다. 누구인가? (국문학과의 '학과코드'는 학과 테이블(TB_DEAPRTMENT)을 조회해서 찾아내도록 하자.
SELECT STUDENT_NAME
FROM TB_STUDENT TS
JOIN TB_DEPARTMENT TD ON (TS.DEPARTMENT_NO = TD.DEPARTMENT_NO)
WHERE TD.DEPARTMENT_NO = 001 AND SUBSTR(STUDENT_SSN, 8, 1) = '2' AND ABSENCE_YN = 'Y'; 

-- 4. 도서관에서 대출 도서 장기 연체자 들을 찾아 이름을 게시하고자 한다. 그 대상자들의 학번이 다음과 같을 때 대상자들을 찾는 적절한 SQL 구문을 작성하시오.