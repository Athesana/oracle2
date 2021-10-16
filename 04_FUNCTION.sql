/*
    <함수>
     컬럼값을 읽어서 계산한 결과를 반환한다.
        - 단일행 함수 : N 개의 값을 읽어서 N 개의 결과를 리턴한다. ( 매 행 함수 실행 결과 반환)
        - 그룹 함수 : N 개의 값을 읽어서 1개의 결과를 리턴한다. ( 하나의 그룹 별로 함수 실행 결과를 반환)
        - SELECT 절에 단일행 함수와 그룹 함수를 함께 사용하지 못한다. (결과 행의 개수가 다르기 때문)
        - 함수를 기술할 수 있는 위치는 SELECT, WHERE, ORDER BY, GROUP BY, HAVING 절에 기술 할 수 있다.
*/
-------------단일행 함수-------------
/*
    <문자 관련 함수>
     1) LENGTH / LENGTHB
      - LENGTH(컬럼|'문자값') : 글자 수 반환
      - LENGTHB(컬럼|'문자값') : 글자의 바이트 수 반환
        한글 한 글자 -> 3BYTE
        영문자, 숫자, 특수문자 한 글자 -> 1BYTE
        
     * DUAL 테이블
      - sys 사용자가 소유하는 테이블
      - SYS 소유자가 소유하짐나 모든 사용자가 접근이 가능하다.
      - 한 행, 한 컬럼을 가지고 있는 더미(DUMMY) 테이블이다.
      - 사용자가 함수(계산)을 사용할 때 임시로 사용하는 테이블이다.
      - 실제 테이블을 만들고 실행하는게 아니라 함수식의 결과 값을 확인할 때 사용하는 테이블
*/

SELECT LENGTH('오라클'), LENGTHB('오라클')
FROM DUAL;

SELECT EMP_NAME, LENGTH(EMP_NAME), LENGTHB(EMP_NAME), -- 이름은 한글이라서 길이를 가져오는 함수 실행 시 LENGTH와 LENGTHB 결과가 다르다.
       EMAIL, LENGTH(EMAIL), LENGTHB(EMAIL) -- 이메일은 영어, 특수문자라서 LENGTH와 LENGTHB가 동일하다.
FROM EMPLOYEE;

/*
     2) INSTR
      - INSTR(컬럼|'문자값', '문자값(찾을 문자값)'[, POSITION [, OCCURANCE(발생순번)]])
      - 지정한 위치부터 지정된 숫자 번째로 나타나는 문자의 시작 위치를 반환한다. (왼->오)
      - POSITION이 0보다 작으면 오->왼, OCCURANCE 지정안하면 기본 값은 1
      - 쿼리문, 컬럼명은 대소문자를 구분하지 않지만, 데이터는 대소문자를 구분한다.
*/

SELECT INSTR('AABAACAABBAA', 'B') FROM DUAL; -- 3번째 자리 B 위치 값인 3이 반환된다.
SELECT INSTR('AABAACAABBAA', 'B',1) FROM DUAL; -- 3번째 자리 B
SELECT INSTR('AABAACAABBAA', 'B',1,2) FROM DUAL; -- 9번째 자리 B
SELECT INSTR('AABAACAABBAA', 'B',-1) FROM DUAL; -- 10번째 자리 B
SELECT INSTR('AABAACAABBAA', 'B',-1,3) FROM DUAL; -- 3번째 자리 B

SELECT EMAIL, INSTR(EMAIL, '@') AS "@위치", INSTR(EMAIL, 'S', 1, 2) "s위치" -- S는 두번째로 나오는 S를 존재하는 컬럼의 위치 값만 나오게 된다.
FROM EMPLOYEE;

/*
     3) LPAD / RPAD
      - LPAD/RPAD(컬럼|'문자값', 최종적으로 반환할 문자의 길이(바이트)[, 덧붙이고자 하는 문자]) // 덧붙이는 문자를 생략시에는 반환할 문자의 길이가 남게 되면 남는 부분은 공백으로 채운다.
      - 제시한 컬럼|'문자값'에 임의의 문자(덧붙이고자 하는 문자)를 왼쪽 혹은 오른쪽에 덧붙여 최종 반환할 문자의 N 길이 만큼의 문자열을 반환한다.
      - 문자에 대해 통일감 있게 표시하고자 할 때 사용한다.
      - 반환될 값보다 문자열의 길이가 크면 그 이후는 잘리게 된다.
*/

-- 20만큼의 길이 중 EMAIL 값은 *오른쪽으로 정렬*하고 공백을 왼쪽으로 채운다.
SELECT LPAD(EMAIL, 20)
FROM EMPLOYEE;

-- SELECT LPAD(EMAIL, 10)
-- FROM EMPLOYEE;

-- SELECT LPAD(EMP_NAME, 3) -- 반환할 길이는 BYTE 단위를 말하는 것이기 때문에 한글은 성씨 한 글자만 출력된다.
-- FROM EMPLOYEE;

-- 20만큼의 길이 중 EMAIL 값은 *왼쪽으로 정렬*하고 공백을 오른쪽으로 채운다.
SELECT RPAD(EMAIL, 20)
FROM EMPLOYEE;

SELECT LPAD(EMAIL, 20, '#')
FROM EMPLOYEE;

SELECT RPAD(EMAIL, 20, '$')
FROM EMPLOYEE;

-- 991212-2******를 출력
SELECT RPAD('991212-2', 14, '*')
FROM DUAL;

SELECT RPAD(SUBSTR('991212-2222222', 1, 8), 14, '*')
FROM DUAL;

-- EMPLOYEE 테이블에서 주민등록번호 첫 번재 자리부터 성별까지를 추출한 결과 값에 오른쪽에 * 문자를 채워서 최종적으로 14글자를 반환
SELECT EMP_NAME, RPAD(SUBSTR(EMP_NO, 1, 8), 14, '*')
FROM EMPLOYEE;

/*
     4) LTRIM / RTRIM
      - LTRIM / RTRIM(컬럼|'문자값'[, 제거하고자 하는 문자값])
      - 문자열의 왼쪽 혹은 오른쪽에서 제거하고자 하는 문자들을 찾아서 제거한 결과를 반환한다.
      - 제거하고자 하는 문자값을 생략 시 기본값으로 공백을 제거한다.
*/

SELECT LTRIM ('   KH') FROM DUAL;
SELECT LTRIM ('   K H') FROM DUAL; -- 중간 공백은 지워지지 않는다.
SELECT LTRIM('0000123456', '0') FROM DUAL;
SELECT LTRIM('123123KH', '123') FROM DUAL;
SELECT LTRIM('123123KH123', '123') FROM DUAL; -- 왼쪽에서부터 동일 패턴 문자가 반복되는 만큼만 지워주기 때문에 오른쪽에 있는 123은 지워지지 않는다.

SELECT RTRIM('KH   ') FROM DUAL;
SELECT RTRIM('001230000456000', '0') FROM DUAL;

/*
     5) TRIM
     - TRIM([[LEADING|TRAILING|BOTH] 제거하고자하는문자 FROM, ] 컬럼|'문자값')
     - 문자열 앞/뒤/양쪽에 있는 지정한 문자를 제거한 나머지를 반환한다.
     - 제거하고자 하는 문자값을 생략 시 기본적으로 양쪽에 있는 공백을 제거한다.
*/

SELECT TRIM('   KH   ') FROM DUAL;
SELECT TRIM('Z' FROM 'ZZZKHZZZ') FROM DUAL;
SELECT TRIM(BOTH 'Z' FROM 'ZZZKHZZZ') FROM DUAL;
SELECT TRIM(LEADING 'Z' FROM 'ZZZKHZZZ') FROM DUAL;
SELECT TRIM(TRAILING 'Z' FROM 'ZZZKHZZZ') FROM DUAL;

/*
     6) SUBSTR
     - SUBSTR(컬럼|'문자값', POSITION[, LENGTH]) // LENGTH 생략하면 POSITION부터 문자열 끝까지를 반환
     - 문자열에서 지정한 위치부터 지정한 갯수(LENGTH)만큼의 문자열을 추출해서 반환한다. 
     - POSITION 이 양수면 왼->오, 음수면 오->왼
*/
SELECT SUBSTR('SHOWMETHEMONEY', 7) FROM DUAL; -- THEMONEY
SELECT SUBSTR('SHOWMETHEMONEY', 5, 2) FROM DUAL; -- ME
SELECT SUBSTR('SHOWMETHEMONEY', 1, 6) FROM DUAL; -- SHOWME
SELECT SUBSTR('SHOWMETHEMONEY', -8, 3) FROM DUAL; -- THE
SELECT SUBSTR('쇼우 미 더 머니', 2, 5) FROM DUAL; -- '우 미 더' 

-- EMPLOYEE 테이블에서 주민번호에 성별을 나타내는 부분만 잘라서 조회하기 (사원명, 성별코드)
SELECT EMP_NAME, SUBSTR(EMP_NO, 8, 1) AS "성별 코드"
FROM EMPLOYEE;

-- EMPLOYEE 테이블에서 여자 사원만 조회하기 (사원명, 성별코드)
SELECT EMP_NAME, SUBSTR(EMP_NO, 8, 1) AS "성별 코드"
FROM EMPLOYEE
WHERE  SUBSTR(EMP_NO, 8, 1) = '2'; 

-- EMPLOYEE 테이블에서 사원명, 이메일, 아이디(이메일에서 '@' 앞의 문자 값만 출력)를 조회(함수 중첩 사용)
-- @의 위치가 다 다르기 때문에 LENGTH가 다 다른 것이다. 
-- 1은 내가 지정한 위치 POSITION이다.
-- INSTR(EMAIL, '@')이 POSITION 인데 이걸 LENGGTH로 잡아버리면 @까지 출력되기 때문에 -1을 해주면 아이디만 출력된다.
SELECT EMP_NAME, EMAIL, SUBSTR(EMAIL, 1, INSTR(EMAIL, '@') -1) AS "아이디", INSTR(EMAIL, '@')
FROM EMPLOYEE;

/*
     7) LOWER / UPPER / INITCAP
      - LOWER / UPPER / INITCAP(컬럼|'문자값')
      - LOWER : 모두 소문자로 변경한다.
      - UPPER : 모두 대문자로 변경한다.
      - INITCATP : 단어 앞 글자마자 대문자로 변경한다.
*/
SELECT LOWER('Welcome To My World!') FROM DUAL;
SELECT UPPER('Welcome To My World!') FROM DUAL;
SELECT INITCAP('welcome to my world!') FROM DUAL;

/*
     8) CONCAT
     - CONCAT(컬럼|'문자값', 컬럼|'문자값')
     - 문자열 두 개를 전달받아서 하나로 합친 후 결과를 반환한다.
*/

SELECT CONCAT('가나다라', 'ABCD') FROM DUAL;
SELECT '가나다라' || 'ABCD' FROM DUAL;

SELECT CONCAT('가나다라', 'ABCD', '1234') FROM DUAL; -- 에러 발생(CONCAT은 두 개의 문자열만 전달 받을 수 있다.)
SELECT '가나다라' || 'ABCD' || '1234' FROM DUAL;

SELECT EMP_ID || ',' || EMP_NAME || ',' || DEPT_CODE
FROM EMPLOYEE;

SELECT CONCAT(EMP_ID, ',')
FROM EMPLOYEE;

SELECT CONCAT(CONCAT(EMP_ID, ','), EMP_NAME)
FROM EMPLOYEE;

SELECT CONCAT(CONCAT(CONCAT(EMP_ID, ','), EMP_NAME), ',')
FROM EMPLOYEE;

SELECT CONCAT(CONCAT(CONCAT(CONCAT(EMP_ID, ','), EMP_NAME), ','), DEPT_CODE)
FROM EMPLOYEE;

SELECT CONCAT(EMP_ID, EMP_NAME)
FROM EMPLOYEE;

SELECT CONCAT(EMP_ID, EMP_NAME)
FROM EMPLOYEE;

SELECT CONCAT(CONCAT(EMP_ID, EMP_NAME), DEPT_CODE)
FROM EMPLOYEE;

/*
     9) REPLACE
     - REPLACE(컬럼|'문자값', 변경하려고 하는 문자, 변경하고자 하는 문자)
     - 컬럼 또는 문자값에서 "변경하려고 하는 문자를" "변경하고자 하는 문자"로 변경해서 반환한다. 
*/
SELECT REPLACE('서울시 강남구 역삼동', '역삼동', '삼성동') FROM DUAL;

-- EMPLOYEE 테이블에서 이메일의 kh.or.kr을 gamil.com으로 변경해서 조회
SELECT EMP_NAME, REPLACE(EMAIL, 'kh.or.kr', 'gamil.com')
FROM EMPLOYEE;

/*
    <숫자 관련 함수>
      1) ABS
        [표현법]
          ABS(NUMBER)
          
          - 절대값을 구하는 함수
*/
SELECT ABS(10.9) FROM DUAL;
SELECT ABS (-10.9) FROM DUAL;

/*
      2) MOD
        [표현법]
          MOD(NUMBER, DIVISION)
          
          - 두 수를 나눈 나머지를 반환해주는 함수(like 자바의 % 연산자와 동일하다.)
*/
-- SELECT 10 % 3 FROM DUAL; // invalid character 오류, %는 오라클에서 지원하지 않는다.
SELECT MOD (10, 3) FROM DUAL;  -- 1출력
SELECT MOD(-10, 3) FROM DUAL; -- -1출력
SELECT MOD(10, -3) FROM DUAL; -- 1출력
SELECT MOD(10.9, 3) FROM DUAL; -- 1.9출력
SELECT MOD(-10.9, 3) FROM DUAL; -- -1.9출력

 /*
      3) ROUND
        [표현법]
          ROUND(NUMBER[, 위치])
          
          - 소수점 기준으로 "반올림" 해주는 함수
          - 위치 : 기본값이 0(.)이다, 양수(소수점 기준으로 오른쪽)와 음수(소수점 기준으로 왼쪽)로 입력가능
*/
SELECT ROUND(123.456) FROM DUAL;
SELECT ROUND(123.456, 1) FROM DUAL; -- 123.5출력
SELECT ROUND(123.456, 2) FROM DUAL; -- 123.46출력
SELECT ROUND(123.456, -1) FROM DUAL; -- 120출력
SELECT ROUND(123.456, 4) FROM DUAL;
SELECT ROUND(123.456, -1) FROM DUAL; -- 120출력
SELECT ROUND(123.456, -2) FROM DUAL; -- 100출력
SELECT ROUND(723.456, -3) FROM DUAL; -- 1000출력

/*
      4) CEIL
        [표현법]
          CEIL(NUMBER)
          
          - 무조건 "올림"해주는 함수
          - 위치 지정 불가능
*/
SELECT CEIL(123.456) FROM DUAL; --124출력
-- SELECT CEIL(123.456,2) FROM DUAL; 에러발생

/*
      5) FLOOR
        [표현법]
          FLOOR(NUMBER)
          
          - 소수점 아래를 버림하는 함수
          - 위치 지정 불가능
*/
SELECT FLOOR(123.456) FROM DUAL; -- 123출력
SELECT FLOOR(456.789) FROM DUAL; -- 456출력

/*
      6) TRUNC
        [표현법]
          TRUNC(NUMBER[, 위치])
          
          - 위치를 지정하여 버림이 가능한 함수
          - 위치 : 기본값이 0(.)이다, 양수(소수점 기준으로 오른쪽)와 음수(소수점 기준으로 왼쪽)로 입력가능
*/
SELECT TRUNC(123.456) FROM DUAL; --123출력
SELECT TRUNC(123.456, 1) FROM DUAL; --123.4출력
SELECT TRUNC(123.456, -1) FROM DUAL; --120출력

/*
    <날짜 관련 함수>
      1) SYSDATE
          - 시스템의 날짜를 반환한다. (현재 날짜)
*/
SELECT SYSDATE FROM DUAL;

/*
      2) MONTHS_BETWEEN
        [표현법]
          MONTHS_BETWEEN(DATE1, DATE2)
          
          - 입력받는 두 날짜 사이의 개월 수를 반환한다.
          - 결과값으로 NUMBER(숫자 데이터)이다.
*/
--  EMPLOYEE 테이블에서 직원명, 입사일, 근무개월수 추출
SELECT EMP_NAME, HIRE_DATE, FLOOR(MONTHS_BETWEEN(SYSDATE, HIRE_DATE)) AS "근무개월수" -- FLOOR 작성 전에는 xxx.xxxx.. 이런식으로 숫자로 나온다. 바꿔 넣으면 정수로 나옴.
FROM EMPLOYEE;

--근속년수 구하기
SELECT FLOOR(MONTHS_BETWEEN(SYSDATE, HIRE_DATE)/12)
FROM EMPLOYEE;

SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, HIRE_DATE)/12,0)
FROM EMPLOYEE;

-- 근속년수가 20년 이상인 사원 이름 구하기
SELECT EMP_NAME
FROM EMPLOYEE
WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, HIRE_DATE)/12,0) >= 20;


/*
      3) ADD_MONTHS
        [표현법]
          ADD_MONTHS(DATE, NUMBER)
          
          - 특정 날짜에 입력받는 숫자만큼(NUMBER)만큼 개월 수를 더한 날짜를 리턴한다.
          - 결과값은 DATE이다.
*/
SELECT ADD_MONTHS(SYSDATE, 6) FROM DUAL;

-- EMPLOYEE 테이블에서 직원명, 입사일, 입사 후 6개월 이 된 날짜를 조회
SELECT EMP_NAME, HIRE_DATE, ADD_MONTHS(HIRE_DATE, 6)
FROM EMPLOYEE;

/*
      4) NEXT_DAY
        [표현법]
          NEXT_DAY(DATE, 요일(문자|숫자))
          
          - 특정 날짜에서 구하려는 요일의 (다가오는, 지난x)가장 가까운 날짜를 리턴한다.
          - 결과값은 DATE이다.
*/
SELECT SYSDATE, NEXT_DAY('21/09/27', '금요일') FROM DUAL; -- 그냥 날짜형태는 안되고 '' 사이에 문자형태로 넣어주면 작동된다.
SELECT SYSDATE, NEXT_DAY(SYSDATE, '금요일') FROM DUAL;
SELECT SYSDATE, NEXT_DAY(SYSDATE, '금') FROM DUAL;
SELECT SYSDATE, NEXT_DAY(SYSDATE, 4) FROM DUAL; --1:일요일, 2:월요일, 3:화요일 ... 7:토요일
-- SELECT SYSDATE, NEXT_DAY(SYSDATE, 'SUNDAY') FROM DUAL; -- 오류 (영어는 NOPE! cuz 현재 언어가 KOREAN 이기 때문에)

-- ALTER SESSION SET NLS_LANGUGE = AMERICAN; -- 언어를 변경
-- SELECT SYSDATE, NEXT_DAY(SYSDATE, 'SUNDAY') FROM DUAL;
-- SELECT SYSDATE, NEXT_DAY(SYSDATE, 'SUN') FROM DUAL;
-- SELECT SYSDATE, NEXT_DAY(SYSDATE, 1) FROM DUAL;
-- SELECT SYSDATE, NEXT_DAY(SYSDATE, '금') FROM DUAL; -- 오류

/*
      5) LAST_DAY
        [표현법]
          LAST_DAY(DATE)
          
          - 해당 월의 마지막 날짜를 반환한다.
          - 결과값은 DATE이다.
*/

SELECT LAST_DAY (SYSDATE) FROM DUAL;
SELECT LAST_DAY ('20210810') FROM DUAL; -- 그냥 숫자만 쓰면 에러! 함수에 매개 값으로는 날짜형태로 줘야하는데 문자로 넘겨줘야 자동으로 형변환이 된다.

-- EMPLOYEE 테이블에서 직원명, 입사일, 입사월의 마지막 날짜 조회
SELECT EMP_NAME, HIRE_DATE, LAST_DAY(HIRE_DATE)
FROM EMPLOYEE;

/*
      6) EXTRACT
        [표현법]
          EXTRACT(YEAR|MONTH|DAY FROM DATE)
          
          - 특정 날짜에서 연도, 월, 일 정보를 추출해서 반환한다.
            YEAR : 연도만 추출
            MONTH : 월만 추출
            DAY : 일만 추출
          - 결과값은 NUMBER이다.
*/
--EMPLOYEE 테이블에서 직원명, 입사년도, 입사월, 입사일을 조회
SELECT EMP_NAME, HIRE_DATE, 
       EXTRACT(YEAR FROM HIRE_DATE),
       EXTRACT(MONTH FROM HIRE_DATE),
       EXTRACT(DAY FROM HIRE_DATE)
FROM EMPLOYEE
ORDER BY 3, 4, 5;

--날짜포맷변경
--ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH:MI:SS';
--ALTER SESSION SET NLS_DATE_FORMAT = 'RR/MM/DD'; -- 원래 형식

SELECT SYSDATE FROM DUAL;

/*
    <형변환 함수>
     1) TO_CHAR
      [표현법]
        TO_CHAR(날짜|숫자[, 포맷])
        
      - 날짜 또는 숫자 타입의 데이터를 문자 타입으로 변환해서 반환한다.
      - 결과값은 CHARACTER이다.
*/

-- 숫자 --> 문자
SELECT TO_CHAR(1234) FROM DUAL;
SELECT TO_CHAR(1234, '999999') FROM DUAL; -- 6칸의 공간을 확보, 오른쪽 정렬, 빈칸은 공백 / 출력되는 결과가 최대 6자리의 문자열로 설정, 입력받은 숫자는 4자리여서 <공백공백1234> 로 출력
SELECT TO_CHAR(1234, '000000') FROM DUAL; -- 6칸의 공간을 확보, 오른쪽 정렬, 빈칸은 0 / 0은 하나의 숫자값을 의미하는데 오른쪽부터 정렬하는데 숫자를 입력받고 남은 자리는 0으로 출력 <001234>로 출력
-- > 포맷을 벗어나는 자리값의 숫자를 입력하면  #####.. 이렇게 표시된다. '' 안의 자리를 늘려주면 된다.
SELECT TO_CHAR(1234, 'L999999') FROM DUAL; -- 통화기호1234 : 현재 설정된 나라(LOCAL) 의 화폐단위를 표시
SELECT TO_CHAR(1234, '$999999') FROM DUAL; -- $1234 출력
SELECT TO_CHAR(1234, 'L') FROM DUAL; -- # 으로만 표시, 얼마만큼 표시할건지 단위 지정을 하지 않았기 때문이다.
SELECT TO_CHAR(1234, 'L999,999') FROM DUAL; -- 자리수를 구분해주고 싶을 때, 통화기호1234 : 현재 설정된 나라(LOCAL) 의 화폐단위를 표시에서 단위 수를 표시한다.

-- EMPLOYEE 테이블에서 사원명, 급여 조회(통화 표시, 자릿수 구분해서 출력)
SELECT EMP_NAME, TO_CHAR(SALARY, 'L999,999,999') AS "급여"
FROM EMPLOYEE
ORDER BY "급여" DESC;

-- 숫자 또는 날짜 --> 문자 TO_CHAR(데이터, '출력 형식')
-- 날짜 --> 문자
SELECT SYSDATE FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'AM HH24:MI:SS') FROM DUAL; -- 24시간 기준이면 00부터 시작하고 24가 생략되어 있으면 12시부터 시작한다.
SELECT TO_CHAR(SYSDATE, 'PM HH:MI:SS') FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'MON DY, YYYY') FROM DUAL; -- 9월 화 2021
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD(DAY)') FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD') FROM DUAL;

-- 문자 --> 날짜 TO_DATE(데이터, '날짜 형식')
SELECT TO_DATE('20/10/13', 'YYYY/MM/DD') FROM DUAL;
SELECT TO_CHAR(TO_DATE('20/10/13', 'YY/MM/DD'), 'YYYY-MM-DD') FROM DUAL;
SELECT TO_CHAR(TO_DATE('20/10/13'), 'YYYY-MM-DD') FROM DUAL;

SELECT TO_DATE('190505', 'YY/MM/DD') FROM DUAL;
SELECT TO_CHAR(TO_DATE('190505', 'YY/MM/DD'), 'YYYY"년" MM"월" DD"일"') FROM DUAL; -- 2019년 05월 05일
SELECT TO_CHAR(TO_DATE('190505', 'YY/MM/DD'), 'YYYY"년" fmMM"월" DD"일"') FROM DUAL; -- 2019년 5월 5일, 앞에 0 없애기


-- 연도에 대한 포맷 문자는 'Y', 'R'이 있다.
-- YY는 무조건 현재 세기를 반영하고, RR은 50미만이면 현재 세기를 반영, 50 이상이면 이전 세기를 반영한다.
-- 20 18 90 -> YY 2020, 2018, 2090
-- 20 18 90 -> RR 2020, 2018, 1990
SELECT TO_CHAR(SYSDATE, 'YYYY'),
       TO_CHAR(SYSDATE, 'RRRR'),
       TO_CHAR(SYSDATE, 'YY'),
       TO_CHAR(SYSDATE, 'RR'),
       TO_CHAR(SYSDATE, 'YEAR') -- TWENTY TWENTY-ONE
FROM DUAL;

-- 월에 대한 포맷
SELECT TO_CHAR(SYSDATE, 'MM'), --M 하나만 쓰면 에러! / 09
       TO_CHAR(SYSDATE, 'MON'), -- 9월 or SEP
       TO_CHAR(SYSDATE, 'MONTH'), -- 9월 or SEPTEMBER
       TO_CHAR(SYSDATE, 'RM') -- IX 로마기호 표시
FROM DUAL;

-- 일에 대한 포맷
SELECT TO_CHAR(SYSDATE, 'D'), -- 1주를 기준으로 며칠 째인지 표시, 일요일 기준 시작
       TO_CHAR(SYSDATE, 'DD'), -- 1달을 기준으로 며칠 째인지 표시
       TO_CHAR(SYSDATE, 'DDD') -- 1년을 기준으로 며칠 째인지 표시
FROM DUAL;

-- 요일에 대한 포맷
SELECT TO_CHAR(SYSDATE, 'DAY'), -- TUESDAY
       TO_CHAR(SYSDATE, 'DY') -- 요일에 대한 약어 / TUE
FROM DUAL;

ALTER SESSION SET NLS_LANGUAGE = AMERICAN;
ALTER SESSION SET NLS_LANGUAGE = KOREAN;

-- EMPLOYEE 테이블에서 직원명, 입사일 조회
-- 입사일은 포맷을 지정해서 조회한다. (2021년 09월 28일(화))
-- 포맷 안에 한글은 형식이 없기 때문에 "" 큰 따옴표로 작성해야한다.
SELECT EMP_NAME, TO_CHAR(HIRE_DATE, 'YYYY"년" MM"월" DD"일" (DY)') AS "입사일"
FROM EMPLOYEE;

/*
     2) TO_DATE
      [표현법]
        TO_CHAR(숫자|문자[, 포맷])
        
      - 숫자 또는 문자 타입의 데이터를 날짜 타입의 데이터로 변환해서 반환한다.
      - 결과값은 DATE이다.
*/
-- 숫자 --> 날짜
--날짜포맷변경
--ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH:MI:SS';
--ALTER SESSION SET NLS_DATE_FORMAT = 'RR/MM/DD'; -- 원래 형식
SELECT TO_DATE(20210928) FROM DUAL;  -- 출력 포맷 설정에 영향을 받는다. 아래에 두 개 왔다 갔다 하면서 형식 변경
SELECT TO_DATE(20210928111630) FROM DUAL; -- 정수형태를 날짜로 바꿔서 출력, 원래 형식 세션에서는 오류가 난다.

-- 문자 --> 날짜
SELECT TO_DATE('20210928') FROM DUAL;
SELECT TO_DATE('20210928 222530') FROM DUAL; -- 원래 형식 세션에서는 오류가 난다.
SELECT TO_DATE('20210928', 'YYYYMMDD') FROM DUAL;

-- YY와 RR 비교
SELECT TO_DATE('210928', 'YYMMDD') FROM DUAL; 
SELECT TO_DATE('980928', 'YYMMDD') FROM DUAL; -- YY : 무조건 현재 세기
SELECT TO_CHAR(TO_DATE('980928', 'YYMMDD'), 'YYYYMMDD') FROM DUAL; -- 2098년

SELECT TO_DATE('210928', 'RRMMDD') FROM DUAL; 
SELECT TO_DATE('980928', 'RRMMDD') FROM DUAL; -- RR : 해당 값(여기에서는 98)이 50이상이면 이전 세기, 50 미만이면 현재 세기
SELECT TO_CHAR(TO_DATE('980928', 'RRMMDD'), 'YYYYMMDD') FROM DUAL; -- 1998년

-- EMPLOYEE 테이블에서 1998년 1월 1일 이후에 입사한 사원의 사번, 이름, 입사일 조회
SELECT EMP_ID, EMP_NAME, HIRE_DATE
FROM EMPLOYEE
--WHERE HIRE_DATE > TO_DATE('19980101', 'YYYYMMDD');
--WHERE HIRE_DATE > TO_DATE('980101', 'RRMMDD');
WHERE HIRE_DATE > '19980101'; -- 자동으로 형변환이 이루어진다.

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH:MI:SS'; -- 12:00:00
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS'; -- 00:00:00D
ALTER SESSION SET NLS_DATE_FORMAT = 'RR/MM/DD'; -- 원래 형식

/*
     2) TO_NUMBER
      [표현법]
        TO_NUMBER('문자값'[, 포맷])
        
      - 문자 타입의 데이터를 숫자 타입의 데이터로 변환해서 반환한다.
      - 결과값은 NUMBER이다.
*/
SELECT TO_NUMBER('0123456789') FROM DUAL; -- 123456789 출력
SELECT '123' + '456' FROM DUAL; -- 579 출력 / 자동으로 숫자 타입으로 형변환 뒤 연산처리를 해준다.
SELECT '123' + '456A' FROM DUAL; -- 에러 발생 / 문자 안에 숫자형태의 문자들만 자동형변환 가능하다.
SELECT '10,000,000' + '500,000' FROM DUAL; -- 에러 발생 / 중간에 , 콤마가 있어서 안된다.
SELECT TO_NUMBER('10,000,000', '99,999,999') + TO_NUMBER('500,000', '999,999') FROM DUAL; -- 에러 발생 / ,콤마 때문에 불가능 / 따라서 포맷<'99,999,999'>을 지정해주면 연산 가능 -> 10500000 출력

/*
    <NULL 처리 함수>
     1) NVL
      [표현법]
        NVL(컬럼명|컬럼값, 컬럼값이 NULL일 경우 반환할 결과값)
        
      - NULL로 되어있는 컬럼의 값을 두번째 인자로 지정한 값으로 변경하여 반환한다.
      
     2) NVL2
      [표현법]
        NVL2(컬럼명|컬럼값, 바꿀값1, 바꿀값2)
    
      - 컬럼 값이 NULL이 아니면 바꿀값 1이 반환되고, 컬럼 값이 NULL이면 바꿀값 2가 반환된다. 
      
      3) NULLIF
       [표현법]
         NULLIF(비교대상 1, 비교대상 2)
         
      - 두 개의 값이 동일하면 NULL 반환, 두 개의 값이 동일하지 않으면 비교대상 1을 반환한다.
*/
--<NVL>
-- EMPLOYEE 테이블에서 사원명, 보너스, 보너스가 포함된 연봉 조회
SELECT EMP_NAME, NVL(BONUS,0), (SALARY + (SALARY * NVL(BONUS, 0))) * 12 AS "연봉" -- 연산시에 NULL이 있으면 NULL이 되기 때문에 숫자 0으로 바꿔주겠다.
FROM EMPLOYEE;

-- EMPLOYEE 테이블에서 사원명, 부서 코드를 조회 (단, 부서 코드가 NULL이면 "부서 없음" 출력)
SELECT EMP_NAME, NVL(DEPT_CODE, '부서 없음') 
FROM EMPLOYEE;

-- <NVL2인 경우> 보너스를 동결하고 싶을 때 (안 받는 사람은 그대로 0으로 놔두고, 받는 사람(=NULL이 아닌)은 일일히 0.1로 BONUS를 바꾸는게 아니라 NVL2를 통해서 0.1로 바꿔서 동결시키고 안받는 사람(=NULL인 사람)은 0으로)
SELECT EMP_NAME, NVL(BONUS, 0), NVL2(BONUS, 0.1, 0), (SALARY + (SALARY * NVL2 (BONUS, 0.1, 0))) * 12 AS "연봉"
FROM EMPLOYEE;

--<NULLIF>
SELECT NULLIF('123', '123') FROM DUAL;  --NULL
SELECT NULLIF('123', '456') FROM DUAL;  --123

SELECT NULLIF(123, 123) FROM DUAL; --NULL
SELECT NULLIF(123, 456) FROM DUAL; --123


/*
    <선택 함수>
    - 여러 가지 경우에 선택할 수 있는 기능을 제공하는 함수
    
     1) DECODE
      [표현법]
        DECODE(컬럼명|계산식, 조건값1, 결과값1, 조건값2, 결과값2,... 결과값)
        
      - 비교하고자 하는 값이 조건값과 일치할 경우 그에 해당하는 결과값을 반환해주는 함수이다.
      - 가장 마지막에 있는 결과값은 DEFAULT이다.
      - 모든 조건을 만족하지 않을 때 가장 마지막에 있는 결과값을 리턴해준다.
*/

--EMPLOYEE 테이블에서 사번, 사원명, 주민번호, 성별(남/여) 조회
SELECT EMP_ID, 
       EMP_NAME, 
       EMP_NO, 
       DECODE(SUBSTR(EMP_NO, 8, 1), '2', '여자', '1', '남자', '잘못 된 주민등록 번호입니다.') AS "성별"
FROM EMPLOYEE;

-- EMPLOYEE 테이블에서 사원명, 직급 코드, 기존 급여, 인상된 급여를 조회
-- 직급 코드가 J7인 사원은 급여를 10% 인상
-- 직급 코드가 J6인 사원은 급여를 15% 인상
-- 직급 코드가 J5인 사원은 급여를 20% 인상
-- 그 외의 직급의 사원은 급여를 5%만 인상

SELECT EMP_NAME AS "사원명" , 
       JOB_CODE AS "직급코드" , 
       SALARY "기존급여", 
       DECODE(JOB_CODE, 'J7', SALARY * 1.1, 'J6', SALARY * 1.15, 'J5', SALARY * 1.2, SALARY * 1.05) AS "인상급여" 
FROM EMPLOYEE;

/*     
     2) CASE
      [표현법]
        CASE WHEN 조건식 1 THEN 결과값 1    
             WHEN 조건식 2 THEN 결과값 2    
             WHEN 조건식 3 THEN 결과값 3
             ELSE 결과값
        END
        
        - 조건식을 만족해서 결과값이 리턴되는 경우가 있으면 아래의 구문은 실행되지 않는다.
        - 항상 END를 써야 한다.
 */     

--EMPLOYEE 테이블에서 사번, 사원명, 주민번호, 성별(남/여) 조회
SELECT EMP_ID, EMP_NAME, EMP_NO,
       CASE WHEN SUBSTR(EMP_NO, 8, 1) = '1' OR SUBSTR(EMP_NO, 8, 1) = '3' THEN '남자'
            WHEN SUBSTR(EMP_NO, 8, 1) = '2' OR SUBSTR(EMP_NO, 8, 1) = '4' THEN '여자'
            ELSE '잘못된 주민번호 입니다.'
       END AS "성별"
FROM EMPLOYEE;

-- 사원명, 급여, 급여 등급(1 ~ 4 등급) 조회
-- SALARY 값이 500만원 초과일 경우 1등급
-- SALARY 값이 500만원 이하 350만원 초과일 경우 2등급
-- SALARY 값이 350만원 이하 200만원 초과일 경우 3등급
-- 그 외의 경우 4등급
SELECT EMP_NAME AS "사원명", 
       TO_CHAR(SALARY, '9,999,999') AS "급여",
       CASE WHEN SALARY > 5000000 THEN '1등급'
            WHEN SALARY > 3500000 THEN '2등급'
            WHEN SALARY > 2000000 THEN '3등급'
            ELSE '4등급'
       END AS "급여 등급"
FROM EMPLOYEE
ORDER BY "급여 등급" ;

/*
    <그룹 함수>
     대량의 데이터들로 집계나 통계같은 작업을 처리해야 하는 경우 사용되는 함수들이다.
     모든 그룹 함수는 NULL 값을 자동으로 제외하고 값이 있는 것들만 계산한다.
     따라서 AVG 함수 사용시에는 NLV() 함수와 함께 사용하는 것을 권장한다.
     그룹으로 묶어서 하나의 값으로 만들어준다.
     
      1) SUM
        [표현법]
          SUM(NUMBER)
          
       - 해당 컬럼 값들의 총 합계를 반환
*/

-- EMPLOYEE 테이블에서 전체 사원 총 급여 합계
SELECT SUM(SALARY) AS "총 급여의 합"
FROM EMPLOYEE;

-- EMPLOYEE 테이블에서 남자/여자 사원 총 급여 합계
SELECT SUM(SALARY) AS "여자 사원 급여의 합"
FROM EMPLOYEE
WHERE SUBSTR(EMP_NO, 8, 1) = '2';

-- EMPLOYEE 테이블의 전사원 총 연봉의 합계
SELECT SUM(SALARY * 12)
FROM EMPLOYEE;
-- 조건 추가하고싶을 때 : WHERE JOB_CODE = 'J7';

/*
      2) AVG
        [표현법]
          AVG(NUMBER)
          
       - 해당 컬럼 값들의 평균을 구해서 반환
*/
-- EMPLOYEE 테이블의 전사원의 급여 평균 조회
SELECT TO_CHAR(ROUND(AVG(NVL(SALARY, 0))), 'L99,999,999') AS "급여 평균"
FROM EMPLOYEE;

/*
      3) MIN / MAX
        [표현법]
          MIN/ MAX(모든 타입 컬럼)
          
       - MIN : 해당 컬럼 값들 중에 가장 작은 값을 반환
       - MAX : 해당 컬럼 값들 중에 가장 큰 값을 반환
       - 내부적으로 정렬 하고 가져오기 때문에 데이터가 많은 경우에는 (INDEX를 사용한다.) 속도가 느리다.
*/

SELECT MIN(EMP_NAME),MAX(EMP_NAME), MIN(EMAIL), MAX(EMAIL), MIN(SALARY), MAX(SALARY), MIN(HIRE_DATE), MAX(HIRE_DATE)
FROM EMPLOYEE;

/*
      4) COUNT
        [표현법]
          COUNT(*|컬럼명|DISTINCT 컬럼명)
          
       - 컬럼 또는 행의 갯수를 세서 반환하는 함수이다.
       - COUNT(*) : 조회 결과에 해당하는 모든 행의 갯수를 반환한다.
       - COUNT(컬럼명) : 제시한 컬럼 값이 <<NULL이 아닌>> 행의 개수를 반환한다.
       - COUNT(DISTINCT 컬럼명) : 해당 컬럼 값의 중복을 제거한 행의 개수를 반환한다. NULL 값은 갯수에 포함하지 않는다.
*/
-- 전체 사원수
SELECT COUNT(*)
FROM EMPLOYEE;

-- 남자 사원 수 구하기
SELECT COUNT(*)
FROM EMPLOYEE
WHERE SUBSTR(EMP_NO, 8, 1) = '1';

-- 퇴사한 직원의 수 구하기 방법 2가지 (ENT_DATE가 NULL인 경우 개수를 세지 않는다.)
SELECT COUNT(ENT_DATE)
FROM EMPLOYEE;

SELECT COUNT(*)
FROM EMPLOYEE
WHERE ENT_YN = 'Y';

-- 현재 사원들이 속해있는 부서의 수 (NULL은 포함이 되지 않기 때문에 카운팅되지 않는다.)
SELECT COUNT(DISTINCT DEPT_CODE)
FROM EMPLOYEE;

-- 현재 사원들이 분포되어 있는 직급의 수
SELECT COUNT(DISTINCT JOB_CODE) -- / JOB CODE -> DISTINCT -> COUNT
FROM EMPLOYEE;







