/*
    <TCL(Transaction Control Language)>
        트랜잭션을 제어하는 언어이다.
        
        * WHAT IS 트랜잭션?
        - 하나의 논리적인 작업 단위를 트랜잭션이라고 한다.
          <ATM에서 현금을 출금>
            1. 카드 삽입
            2. 메뉴 선택
            3. 금액 확인 및 인증(PASSWORD)
            4. 실제 계좌에서 금액만큼 인출
            5. 실제 금액만큼 현금 인출
            6. 완료
        - 각각의 업무들을 묶어서 하나의 작업 단위로 만들어 버리는 것을 트랜잭션이라고 한다. 
        - 데이터의 변경 사항(DML)들을 논리적인 하나의 단위로 묶어서 하나의 트랜잭션에 담아서 처리한다.
        - 정상 종료되면 COMMIT , 중간 오류 발생하면 ROLLBACK
         (COMMIT 하기 전까지의 변경사항들을 하나의 트랜잭션에 담게 된다.)
        - 트랜잭션은 DML(INSERT, UPDATE, DELETE)을 대상으로 적용된다.
        - COMMIT(트랜잭션 종료 처리 후 저장), ROLLBACK(트랜잭션 취소), SAVEPOINT(임시 저장)을 통해서 트랜잭션을 제어한다.
          COMMIT
            메모리 버퍼에 임시 저장된 데이터를 DB에 반영한다.
            모든 작업들을 정상적으로 처리하겠다고 확정하는 구문(명령어), 하나의 트랜잭션 과정을 종료하게 된다.
          ROLLBACK
            메모리 버퍼에 임시 저장된 데이터를 삭제한 후 마지막 COMMIT 시점으로 돌아간다.
            모든 작업들을 취소 처리하겠다고 확정하는 구문, 하나의 트랜잭션 과정을 취소하게 된다.
          SAVEPOIONT
            저장점을 정의해두면 ROLLBACK 진행 할 때 전체 작업을 ROLLBACK 하는게 아니라 SAVEPOINT 까지의 일부만 롤백 한다.
                SAVEPOINT 포인트명; -- 저장점 지정
                ROLLBACK TO 포인트명; -- 해당 포인트 지점까지의 트랜잭션만 롤백한다. (앞에 COMMIT이 있어도 포인트명 적힌데 까지 돌아가서 ROLLBACK 된다.)
*/
CREATE TABLE EMP_01
AS  SELECT EMP_ID, EMP_NAME, DEPT_TITLE
    FROM EMPLOYEE E
    LEFT OUTER JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID);

-- EMP_ID가 900, 901인 사원 지우기(공유, 이산아)
DELETE FROM EMP_01 
WHERE EMP_ID IN (901, 900);

-- 두 개의 행이 삭제된 시점에 SAVEPOINT를 지정해보자. 내가 원하는 SAVEPOINT 시점
SAVEPOINT SP;

-- EMP_ID가 200번인 사원 지우기
DELETE FROM EMP_01
WHERE EMP_ID = 200;

ROLLBACK TO SP; -- 200번 사원은 돌아오는데 900, 901번 사원은 안 돌아온다. 

ROLLBACK; -- 200, 900, 901 전부 다 돌아온다. DDL 만드는 시점에는 자동으로 COMMIT이 한 번된다 따라서 SAVEPOINT를 지정하지 않고 ROLLBACK하게 되면 그 시점까지 ROLLBACK이 된다.
-- SAVEPOINT는 무시하고 가장 최근 COMMIT까지 돌아간다. 
-- ROLLBACK하고 ROLLBACK TO SP; 하면 오류 난다. SP의 의미가 없어졌다. 

COMMIT;

-- EMP_ID가 213인 사원 지우기
DELETE FROM EMP_01
WHERE EMP_ID = 213;

-- DDL 구문을 실행하는 순간 기존에 메모리 버퍼에 임시 저장된 변경 사항들이 무조건 DB에 반영된다.(COMMIT 시켜버린다.)
CREATE TABLE TEST(
    TID NUMBER
);

ROLLBACK; -- 213번 사원이 돌아오지 않는다. WHY? 위에서 DDL 구문을 사용했기 때문에 

SELECT *
FROM EMP_01
ORDER BY EMP_ID;

DROP TABLE TEST;
DROP TABLE EMP_01;





















