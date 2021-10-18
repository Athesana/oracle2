/*
    <TRIGGER>
        테이블이 INSERT, UPDATE, DELETE 등 DML 구문에 의해서 변경될 경우
        자동으로 실행될 내용을 정의해놓는 객체이다.
        
        * 트리거의 종류
        1) SQL 문의 실행 시기에 따른 분류
            - BEFORE TRIGGER : 해당 SQL 문장 실행 전 트리거를 실행한다. 
            - AFTER TRIGGER  : 해당 SQL 문장 실행 후 트리거를 실행한다.
        2) SQL 문에 의해 영향을 받는 행에 따른 분류
            - 문장 트리거(STATEMENT TRIGGER) : 해당 SQL 문에 대해 한 번만 트리거를 실행한다.
            - 행 트리거(ROW TRIGGER)         : 해당 SQL 문에 영향을 받는 행마다 트리거를 실행한다. (FOR EACH ROW 옵션을 기술해야한다.)
            
        [표현법]
            CREATE [OR REPLACE] TRIGGER 트리거명
            BEFORE|AFTER INSERT|UPDATE|DELETE ON 테이블명
            [FOR EACH ROW]
            [DECLARE
                선언부]
            BEGIN
                실행부 (위에서 지정한 비포 ~ DML ON 테이블명 에서 트리거로써 자동으로 실행될 구문 작업)
            [EXCEPTION
                예외처리부]
            END;
            /
            
    ** 실무에서는 OR REPLACE 쓰지마세요.
*/

CREATE OR REPLACE TRIGGER TRG_01
AFTER UPDATE ON EMPLOYEE
BEGIN
    DBMS_OUTPUT.PUT_LINE('업데이트 실행!');
END;
/

CREATE OR REPLACE TRIGGER TRG_02
AFTER UPDATE ON EMPLOYEE
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('변경 전 : ' || :OLD.DEPT_CODE || ', 변경 후 : ' || :NEW.DEPT_CODE);
END;
/

UPDATE EMPLOYEE
SET DEPT_CODE = 'D1'
WHERE DEPT_CODE = 'D9';

SELECT * FROM EMPLOYEE;

ROLLBACK;

-- 트리거는 한 번만 수행되는데 영향 받는 행은 3개였다. 영향 받은 행이 없어도 수행되고 = 문장 트리거
-- 업데이트가 수행될 때마다 트리거 문장이 3번 실행된다. 영향 받은 행이 없다면 수행되지 않는다. = 행 트리거

-------------------------------------------------------------------------------
-- 상품 입고, 출고 관련 예시
-- 1. 상품에 대한 데이터를 보관할 테이블 (PRODUCT)
-- DROP TABLE PRODUCT;
CREATE TABLE PRODUCT(
    PCODE NUMBER PRIMARY KEY, -- 상품 코드
    PNAME VARCHAR2(30),       -- 상품 이름
    BRAND VARCHAR2(30),       -- 브랜드명
    PRICE NUMBER,             -- 가격
    STOCK NUMBER DEFAULT 0    -- 재고
);
-- 상품 코드가 중복되지 않게 새로운 번호를 발생하는 시퀀스 객체를 생성한다.
CREATE SEQUENCE SEQ_PCODE;

INSERT INTO PRODUCT VALUES(SEQ_PCODE.NEXTVAL, 'Z플립', '삼성', 1500000, DEFAULT);
INSERT INTO PRODUCT VALUES(SEQ_PCODE.NEXTVAL, '아이폰13', '애플', 1000000, DEFAULT);
INSERT INTO PRODUCT VALUES(SEQ_PCODE.NEXTVAL, '샤오미폰', '샤오미', 800000, DEFAULT);

SELECT * FROM PRODUCT;

-- 2. 상품 입출고 상세 이력을 보관할 테이블 (PRODETAIL)
CREATE TABLE PRODETAIL(
    DCODE NUMBER PRIMARY KEY,               -- 입출력 이력 코드
    PDATE DATE,                             -- 상품 입/출고 일
    AMOUNT NUMBER,                          -- 수량
    STATUS VARCHAR2(10),                    -- 상태(입고, 출고)
    PCODE NUMBER,                           -- 상품코드(외래 키로 지정, PRODUCT 테이블을 참조)
    CHECK(STATUS IN ('입고', '출고')),
    FOREIGN KEY(PCODE) REFERENCES PRODUCT
);

CREATE SEQUENCE SEQ_DCODE;

-- 1번 상품이 오늘 날짜로 10개 입고
INSERT INTO PRODETAIL VALUES(SEQ_DCODE.NEXTVAL, SYSDATE, 10, '입고', 1); -- 체크 제약에 입고 출고 아닌 다른 글자 넣으면 check constraint 발생 // 외래키 걸린 PCODE 값을 부모 테이블에 없는 값을 입력하면 parent key not found 에러 발생.
-- 재고 수량도 변경해야 한다.
UPDATE PRODUCT
SET STOCK = STOCK + 10
WHERE PCODE = 1;

-- 2번 상품이 오늘 날짜로 20개 입고
INSERT INTO PRODETAIL VALUES(SEQ_DCODE.NEXTVAL, SYSDATE, 20, '입고', 2);
-- 재고 수량도 변경해야 한다.
UPDATE PRODUCT
SET STOCK = STOCK + 20
WHERE PCODE = 2;

-- 3번 상품이 오늘 날짜로 5개 입고
INSERT INTO PRODETAIL VALUES(SEQ_DCODE.NEXTVAL, SYSDATE, 5, '입고', 3);
-- 재고 수량도 변경해야 한다.
UPDATE PRODUCT
SET STOCK = STOCK + 5
WHERE PCODE = 3;

-- 2번 상품이 오늘 날짜로 5개 출고
INSERT INTO PRODETAIL VALUES(SEQ_DCODE.NEXTVAL, SYSDATE, 5, '출고', 2);
-- 재고 수량도 변경해야 한다.
UPDATE PRODUCT
SET STOCK = STOCK - 5
WHERE PCODE = 2;

SELECT * FROM PRODUCT;
SELECT * FROM PRODETAIL; -- DCODE 전에 지금 2번 오류 체크하느라 일부러 해보고 나서 하느라 3으로 표시된다. (에러도 카운팅 된다. 크게 신경쓰지 말 것)

-- 여기까지는 아직 PRODUCT 테이블에 STOCK 변화가 없다. 쿼리문을 작성해주어야한다. -- 재고수량변경해야한다 ~ 3번 일일히 입고 되는 부분 -- // 일일히 이걸 어떻게 다 해욧!! 

-- PRODETAIL 테이블에 데이터 삽입 시 PRODUCT 테이블에 재고 수량이 업데이트 되도록 트리거를 생성한다.
CREATE OR REPLACE TRIGGER TGR_PRO_STOCK
AFTER INSERT ON PRODETAIL
FOR EACH ROW 
BEGIN
    DBMS_OUTPUT.PUT_LINE(:NEW.STATUS || ' ' || :NEW.AMOUNT || ' ' || :NEW.PCODE);
    
    -- 상품이 입고된 경우
    IF(:NEW.STATUS = '입고') THEN
        UPDATE PRODUCT
        SET STOCK = STOCK + :NEW.AMOUNT
        WHERE PCODE = :NEW.PCODE;
    END IF;
    
    -- 상품이 출고된 경우
    IF(:NEW.STATUS = '출고') THEN
        UPDATE PRODUCT
        SET STOCK = STOCK - :NEW.AMOUNT
        WHERE PCODE = :NEW.PCODE;
    END IF;
END;
/

-- 2번 상품이 오늘 날짜로 20개가 입고
INSERT INTO PRODETAIL VALUES(SEQ_DCODE.NEXTVAL, SYSDATE, 20, '입고', 2);

-- 2번 상품이 오늘 날짜로 25개 출고
INSERT INTO PRODETAIL VALUES(SEQ_DCODE.NEXTVAL, SYSDATE, 25, '출고', 2);

-- 2번 상품이 오늘 날짜로 25개 출고 -- STOCK이 -15개가 되어버린다. -- 이 경우는 숙제! 
-- (제약조건** : INSERT 0 미만일 때 안되게 OR 변수에 현재 재고를 담고, 출고되는 경우에 현재 재고가 AMOUNT보다 큰지 OR 예외처리부에서 (예외도 선언해야함)잘못됐습니다. 찍고 롤백, IF문으로 현재 재고 가져와서 - 마이너스 나오면 문구찍고 롤백)
INSERT INTO PRODETAIL VALUES(SEQ_DCODE.NEXTVAL, SYSDATE, 25, '출고', 2);

SELECT * FROM PRODUCT;
SELECT * FROM PRODETAIL;

-- 위에 DDL들은 자동으로 COMMIT이 된다. 그래서 롤백이 안됨.



ROLLBACK;
