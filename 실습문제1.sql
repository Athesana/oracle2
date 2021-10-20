---------------------------------------------------------------------
-- 실습 문제
-- 도서관리 프로그램을 만들기 위한 테이블 만들기
-- 이때, 제약조건에 이름을 부여하고, 각 컬럼에 주석 달기


-- 1. 출판사들에 대한 데이터를 담기 위한 출판사 테이블(TB_PUBLISHER) 
--  1) 컬럼 : PUB_NO(출판사 번호) -- 기본 키
--           PUB_NAME(출판사명) -- NOT NULL
--           PHONE(출판사 전화번호) -- 제약조건 없음

CREATE TABLE TB_PUBLISHER (
    PUB_NO NUMBER CONSTRAINT TB_PUBLISHER_PUB_NO_PK PRIMARY KEY,
    PUB_NAME VARCHAR2(20) CONSTRAINT TB_PUBLISHER_PUB_NAME_NN NOT NULL,
    PHONE VARCHAR2(20)
    -- CONSTRAINT TB_PUBLISHER_PUB_NO_PK PRIMARY KEY(PUB_NO)  
);

COMMENT ON COLUMN TB_PUBLISHER.PUB_NO IS '출판사 번호';
COMMENT ON COLUMN TB_PUBLISHER.PUB_NAME IS '출판사명';
COMMENT ON COLUMN TB_PUBLISHER.PHONE IS '출판사 전화번호';

SELECT * FROM TB_PUBLISHER;
DESC TB_PUBLISHER;

--  2) 3개 정도의 샘플 데이터 추가하기

INSERT INTO TB_PUBLISHER VALUES (00001, '파피루스', '1234-5678');
INSERT INTO TB_PUBLISHER VALUES (00002, '미코노스', '2345-6789');
INSERT INTO TB_PUBLISHER VALUES (00003, '미케비치', '3456-7890');
INSERT INTO TB_PUBLISHER VALUES ('00004', '메롱메롱', '0000-0000');

SELECT * FROM TB_PUBLISHER;

-- 2. 도서들에 대한 데이터를 담기 위한 도서 테이블 (TB_BOOK)
--  1) 컬럼 : BK_NO (도서번호) -- 기본 키
--           BK_TITLE (도서명) -- NOT NULL
--           BK_AUTHOR(저자명) -- NOT NULL
--           BK_PRICE(가격)
--           BK_PUB_NO(출판사 번호) -- 외래 키(TB_PUBLISHER 테이블을 참조하도록)
--                                    이때 참조하고 있는 부모 데이터 삭제 시 자식 데이터도 삭제 되도록 옵션 지정

CREATE TABLE TB_BOOK (
    BK_NO VARCHAR2(20) CONSTRAINT TB_BOOK_BK_NO_PK PRIMARY KEY,
    BK_TITLE VARCHAR2(40) CONSTRAINT TB_BOOK_BK_TITLE_NN NOT NULL,
    BK_AUTHOR VARCHAR2(40) CONSTRAINT TB_BOOK_BK_AUTHOR_NN NOT NULL,
    BK_PRICE NUMBER,
    BK_PUB_NO NUMBER CONSTRAINT TB_BOOK_BK_PUB_NO_FK REFERENCES TB_PUBLISHER(PUB_NO) ON DELETE CASCADE
);

/* 선생님 코드
CREATE TABLE TB_BOOK(
    BK_NO NUMBER,
    BK_TITLE VARCHAR2(100) CONSTRAINT TB_BOOK_BK_TITLE_NN NOT NULL,
    BK_AUTHOR VARCHAR2(20) CONSTRAINT TB_BOOK_BK_AUTHOR_NN NOT NULL,
    BK_PRICE NUMBER,
    BK_PUB_NO NUMBER,
    CONSTRAINT TB_BOOK_BK_NO_PK PRIMARY KEY(BK_NO),
    CONSTRAINT TB_BOOK_BK_PUB_NO_FK FOREIGN KEY(BK_PUB_NO) REFERENCES TB_PUBLISHER ON DELETE CASCADE
);
*/

COMMENT ON COLUMN TB_BOOK.BK_NO IS '도서번호';
COMMENT ON COLUMN TB_BOOK.BK_TITLE IS '도서명';
COMMENT ON COLUMN TB_BOOK.BK_AUTHOR IS '저자명';
COMMENT ON COLUMN TB_BOOK.BK_PRICE IS '가격';
COMMENT ON COLUMN TB_BOOK.BK_PUB_NO IS '출판사 번호';

DESC TB_BOOK;

--  2) 5개 정도의 샘플 데이터 추가하기

INSERT INTO TB_BOOK VALUES (10001, 'Die for you', 'TheWeeknd', 50000, 1);
INSERT INTO TB_BOOK VALUES (10002, 'Get You', 'Daniel Caesar', 25000, 1);
INSERT INTO TB_BOOK VALUES (10003, 'Like a Queen', 'spring gang', 10000, 2);
INSERT INTO TB_BOOK VALUES (10004, '빨간 립스틱', '이하이', 31500, 00003);
INSERT INTO TB_BOOK VALUES (10005, 'Next Level', '에스파(aespa)', 9000, 00004);

SELECT * FROM TB_BOOK;

/* 선생님 코드
SELECT * 
FROM TB_BOOK TB
JOIN TB_PUBLISHER TP ON(TB.BK_PUB_NO = TP.PUB_NO);
*/

-- 3. 회원에 대한 데이터를 담기 위한 회원 테이블 (TB_MEMBER)
--  1) 컬럼 : MEMBER_NO(회원번호) -- 기본 키
--           MEMBER_ID(아이디)   -- 중복 금지
--           MEMBER_PWD(비밀번호) -- NOT NULL
--           MEMBER_NAME(회원명) -- NOT NULL
--           GENDER(성별)        -- 'M' 또는 'F'로 입력되도록 제한
--           ADDRESS(주소)       
--           PHONE(연락처)       
--           STATUS(탈퇴 여부)     -- 기본값으로 'N' 그리고 'Y' 혹은 'N'으로 입력되도록 제약조건
--           ENROLL_DATE(가입일)  -- 기본값으로 SYSDATE, NOT NULL

CREATE TABLE TB_MEMBER(
    MEMBER_NO NUMBER CONSTRAINT TB_MEMBER_MEMBER_NO_PK PRIMARY KEY,
    MEMBER_ID VARCHAR2(40) CONSTRAINT TB_MEMBER_MEMBER_ID_UQ UNIQUE,
    MEMBER_PWD VARCHAR2(20) CONSTRAINT TB_MEMBER_MEMBER_PWD_NN NOT NULL,
    MEMBER_NAME VARCHAR2(20) CONSTRAINT TB_MEMBER_MEMBER_NAME_NN NOT NULL,
    GENDER CHAR(1) CHECK (GENDER IN ('M', 'F')),
    ADDRESS VARCHAR2(100),
    PHONE VARCHAR2(20),
    STATUS CHAR(1 BYTE) DEFAULT 'N' CHECK (STATUS IN ('N', 'Y')),
    ENROLL_DATE DATE DEFAULT SYSDATE NOT NULL
);

SELECT * FROM TB_MEMBER;

COMMENT ON COLUMN TB_MEMBER.MEMBER_NO IS '회원번호';
COMMENT ON COLUMN TB_MEMBER.MEMBER_ID IS '아이디';
COMMENT ON COLUMN TB_MEMBER.MEMBER_PWD IS '비밀번호';
COMMENT ON COLUMN TB_MEMBER.MEMBER_NAME IS '회원명';
COMMENT ON COLUMN TB_MEMBER.GENDER IS '성별';
COMMENT ON COLUMN TB_MEMBER.ADDRESS IS '주소';
COMMENT ON COLUMN TB_MEMBER.PHONE IS '연락처';
COMMENT ON COLUMN TB_MEMBER.STATUS IS '탈퇴 여부';
COMMENT ON COLUMN TB_MEMBER.ENROLL_DATE IS '가입일';

--  2) 3개 정도의 샘플 데이터 추가하기

INSERT INTO TB_MEMBER VALUES (90001, 'abc1', '1234', '김가가', 'F', '서울시 강남구 블라블라', '010-1111-2222', DEFAULT, DEFAULT);
INSERT INTO TB_MEMBER VALUES (90111, '5CLD', '1234', '이나나', 'M', '경기도 시흥시 블라블라', '010-2222-3333', 'N', DEFAULT);
INSERT INTO TB_MEMBER VALUES (92500, '_NARO', '1234', '최도도', 'M', '전라도 고흥시 블라블라', '010-3333-4444', 'Y', DEFAULT);

-- 4. 도서를 대여한 회원에 대한 데이터를 담기 위한 대여 목록 테이블(TB_RENT)
--  1) 컬럼 : RENT_NO(대여번호) -- 기본 키
--           RENT_MEM_NO(대여 회원번호) -- 외래 키(TB_MEMBER와 참조)
--                                      이때 부모 데이터 삭제 시 NULL 값이 되도록 옵션 설정
--           RENT_BOOK_NO(대여 도서번호) -- 외래 키(TB_BOOK와 참조)
--                                      이때 부모 데이터 삭제 시 NULL 값이 되도록 옵션 설정
--           RENT_DATE(대여일) -- 기본값 SYSDATE

CREATE TABLE TB_RENT(
    RENT_NO NUMBER CONSTRAINT TB_RENT_RENT_NO_PK PRIMARY KEY,
    RENT_MEM_NO NUMBER CONSTRAINT TB_RENT_RENT_MEM_NO_FK REFERENCES TB_MEMBER(MEMBER_NO) ON DELETE SET NULL,
    RENT_BOOK_NO VARCHAR2(20) CONSTRAINT TB_RENT_RENT_BOOK_NO_FK REFERENCES TB_BOOK(BK_NO) ON DELETE SET NULL,
    RENT_DATE DATE DEFAULT SYSDATE
);

COMMENT ON COLUMN TB_RENT.RENT_NO IS '대여번호';
COMMENT ON COLUMN TB_RENT.RENT_MEM_NO IS '대여 회원번호';
COMMENT ON COLUMN TB_RENT.RENT_BOOK_NO IS '대여 도서번호';
COMMENT ON COLUMN TB_RENT.RENT_DATE IS '대여일';

--  2) 샘플 데이터 3개 정도 

INSERT INTO TB_RENT VALUES (20001, 92500, '10001', DEFAULT);
INSERT INTO TB_RENT VALUES (23897, 90111, '10002', DEFAULT);
INSERT INTO TB_RENT VALUES (29999, 90001, '10005', DEFAULT);
INSERT INTO TB_RENT VALUES (27000, 90001, '10003', DEFAULT);

SELECT * FROM TB_RENT;

-- 4. 2번 도서를 대여한 회원의 이름, 아이디, 대여일, 반납 예정일(대여일 + 7일)을 조회하시오.

SELECT  M.MEMBER_NAME AS "회원 이름", 
        M.MEMBER_ID AS "아이디", 
        R.RENT_DATE AS "대여일", 
        R.RENT_DATE + 7 AS  "반납 예정일"
FROM TB_MEMBER M
LEFT OUTER JOIN TB_RENT R ON (M.MEMBER_NO = R.RENT_MEM_NO)
WHERE R.RENT_BOOK_NO = 10002;

-- 5. 회원번호가 1번인 회원이 대여한 도서들의 도서명, 출판사명, 대여일, 반납예정일을 조회하시오.

SELECT  B.BK_TITLE AS "도서명", 
        P.PUB_NAME AS "출판사명", 
        R.RENT_DATE AS "대여일", 
        R.RENT_DATE + 7 AS "반납 예정일"
FROM TB_BOOK B
JOIN TB_PUBLISHER P ON (P.PUB_NO = B.BK_PUB_NO)
JOIN TB_RENT R ON (B.BK_NO = R.RENT_BOOK_NO)
WHERE R.RENT_MEM_NO = 90001;

/* 선생님 코드
SELECT TB.BK_TITLE AS "도서명", 
       TP.PUB_NAME AS "출판사명", 
       TR.RENT_DATE AS "대여일", 
       TR.RENT_DATE + 7 AS "반납 예정일"
FROM TB_RENT TR
JOIN TB_BOOK TB ON(TR.RENT_BOOK_NO = TB.BK_NO)
JOIN TB_PUBLISHER TP ON(TB.BK_PUB_NO = TP.PUB_NO)
WHERE TR.RENT_MEM_NO = 1;
*/



----------------------------------------------------------------------------------------------------------------





















