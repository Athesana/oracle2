-- CREATE TABLE 권한이 없어서 오류 발생
-- 3. 계정에서 테이블을 생성할 수 있는 CREATE TABLE 권한을 부여받기.
CREATE TABLE TEST(
    TID NUMBER 
);

-- insufficient privileges 접속권한은 있지만 CREATE 권한은 없어서 다음과 같은 에러가 발생한다.

-- 본인이 소유하고 있는 테이블들은 바로 조작이 가능하다.
SELECT * FROM TEST;
INSERT INTO TEST VALUES(1);

-- 다른 계정의 테이블에 접근할 수 있는 권한이 없기 때문에 오류가 발생한다.
-- 5. KH.EMPLOYEE 테이블을 조회할 수 있는 권한 부여받기
SELECT * FROM KH.EMPLOYEE; -- (앞에 '계정명.' 생략되면 )현재 계정의 EMPLOYEE TABLE을 의미한다.

-- 6. KH.DEPARTMENT 테이블을 조회할 수 있는 권한 부여받기
SELECT * FROM KH.DEPARTMENT;

-- 7. KH.DEPARTMENT 테이블에 데이터를 삽입 할 수 있는 권한 부엽다기
INSERT INTO KH.DEPARTMENT 
VALUES ('D0', '개발부', 'L2');

ROLLBACK;