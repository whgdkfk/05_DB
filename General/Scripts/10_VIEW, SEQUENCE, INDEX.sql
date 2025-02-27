/* VIEW
 * 
 * 	- 논리적 가상 테이블
 * 	-> 테이블 모양을 하고는 있지만, 실제로 값을 저장하고 있진 않음.
 * 
 *  - SELECT문의 실행 결과(RESULT SET)를 저장하는 객체
 * 
 * 
 * ** VIEW 사용 목적 **
 *  1) 복잡한 SELECT문을 쉽게 재사용하기 위해.
 *  2) 테이블의 진짜 모습을 감출 수 있어 보안상 유리.
 * 
 * ** VIEW 사용 시 주의 사항 **
 * 	1) 가상의 테이블(실체 X)이기 때문에 ALTER 구문 사용 불가.
 * 	2) VIEW를 이용한 DML(INSERT,UPDATE,DELETE)이 가능한 경우도 있지만
 *     제약이 많이 따르기 때문에 조회(SELECT) 용도로 대부분 사용.
 * 
 * 
 *  ** VIEW 작성법 **
 *  CREATE [OR REPLACE] [FORCE | NOFORCE] VIEW 뷰이름 [컬럼 별칭]
 *  AS 서브쿼리(SELECT문)
 *  [WITH CHECK OPTION]
 *  [WITH READ ONLY];
 *
 * 
 *  1) OR REPLACE 옵션 : 
 * 		기존에 동일한 이름의 VIEW가 존재하면 이를 변경
 * 		없으면 새로 생성
 * 
 *  2) FORCE | NOFORCE 옵션 : 
 *    FORCE : 서브쿼리에 사용된 테이블이 존재하지 않아도 뷰 생성
 *    NOFORCE(기본값): 서브쿼리에 사용된 테이블이 존재해야만 뷰 생성
 *    
 *  3) 컬럼 별칭 옵션 : 조회되는 VIEW의 컬럼명을 지정
 * 
 *  4) WITH CHECK OPTION 옵션 : 
 * 		옵션을 지정한 컬럼의 값을 수정 불가능하게 함.
 * 
 *  5) WITH READ ONLY 옵션 :
 * 		뷰에 대해 SELECT만 가능하도록 지정.
 */


/* VIEW를 생성하기 위해서는 권한이 필요하다 !!!! */
-- (관리자 계정 접속)
GRANT CREATE VIEW TO 계정명;

-- 사번, 이름, 부서명, 직급명을 쉽게 조회하기 위한
-- VIEW 생성
-- CREATE VIEW 뷰이름
-- AS 서브쿼리;
CREATE VIEW V_EMP
AS 
SELECT 
		E.EMP_ID AS 사번
	, E.EMP_NAME AS 이름
	, NVL(D.DEPT_TITLE, '부서없음') AS 부서명
	, J.JOB_NAME AS 직급명
FROM 
	EMPLOYEE E
JOIN 
	JOB J ON (E.JOB_CODE = J.JOB_CODE)
LEFT JOIN 
	DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
ORDER BY 
	EMP_ID ASC;

-- VIEW를 이용해서 조회하기
SELECT * FROM V_EMP;

-- V_EMP에서 대리 직급의 직원 조회
SELECT 사번, 이름, 직급명
FROM V_EMP
WHERE 직급명 = '대리';

/* VIEW를 이용한 DML 사용 시 문제점 */
-- DEPARTMENT 테이블을 복사한 DEPT_COPY2 테이블 생성
CREATE TABLE DEPT_COPY2
AS SELECT * FROM DEPARTMENT;
--> DEPT_COPY2 테이블의 제약 조건 확인
-- DEPT_ID, LOCATION_ID: NOT NULL
-- DEPT_TITLE: NULL 허용

-- 값이 무조건 들어가야 하는 컬럼만 이용해서 VIEW 생성
CREATE VIEW V_DCOPY2
AS 
SELECT DEPT_ID, LOCATION_ID
FROM DEPT_COPY2;

SELECT * FROM V_DCOPY2;

-- V_DCOPY2를 이용해서 INSERT 수행
INSERT INTO V_DCOPY2
VALUES('D0', 'L2');
--> 가상 테이블인데 데이터 삽입 성공?!
--> 실제로는 원본 테이블에 데이터가 삽입됨

SELECT * FROM V_DCOPY2;   -- D0 L2
SELECT * FROM DEPT_COPY2; -- D0 NULL L2

-- V_DCOPY2 수정 (REPLACE 옵션 사용)
CREATE OR REPLACE VIEW V_DCOPY2
AS
SELECT DEPT_ID, DEPT_TITLE -- LOCATION_ID 제외
FROM DEPT_COPY2;

SELECT * FROM V_DCOPY2; -- DEPT_ID, DEPT_TITLE만 보임

-- V_DCOPY2에 다시 INSERT
INSERT INTO V_DCOPY2
VALUES('A1', '마케팅1팀');
-- NULL을 ("KH24_JAR"."DEPT_COPY2"."LOCATION_ID") 안에 삽입할 수 없습니다.

-- V_DCOPY2를 이용하면 LOCATION_ID 컬럼에 
-- INSERT 할 수 없기 때문에 자동으로 NULL이 삽입됨
--> LOCATION_ID는 NOT NULL 제약 조건이 설정되어 있기 때문에
-- NULL 삽입 불가

-- 테이블, VIEW 구조를 파악하지 못하고 있으면
-- VIEW를 이용한 DML 수행 시 잦은 오류 발생

/* 
 * VIEW READ ONLY OPTION 추가 
 * → VIEW는 ALTER 불가 → CREATE OR REPLACE 이용
 */
CREATE OR REPLACE VIEW V_DCOPY2
AS
SELECT DEPT_ID, DEPT_TITLE -- LOCATION_ID 제외
FROM DEPT_COPY2
WITH READ ONLY; -- 읽기 전용

-- 다시 INSERT 시도
INSERT INTO V_DCOPY2
VALUES('A1', '마케팅1팀');
-- 읽기 전용 뷰에서는 DML 작업을 수행할 수 없습니다.


----------------------------------------------------------------

/* SEQUENCE(순서, 연속)
 * - 순차적으로 일정한 간격의 숫자(번호)를 발생시키는 객체
 *   (번호 생성기)
 * 
 * *** SEQUENCE 왜 사용할까? ***
 * PRIMARY KEY(기본키) : 테이블 내 각 행을 구별하는 식별자 역할
 * 						 NOT NULL + UNIQUE의 의미를 가짐
 * 
 * PK가 지정된 컬럼에 삽입될 값을 생성할 때 SEQUENCE를 이용하면 좋다!
 * 
 *   [작성법]
  CREATE SEQUENCE 시퀀스이름
  [STRAT WITH 숫자] -- 처음 발생시킬 시작값 지정, 생략하면 자동 1이 기본
  [INCREMENT BY 숫자] -- 다음 값에 대한 증가치, 생략하면 자동 1이 기본
  [MAXVALUE 숫자 | NOMAXVALUE] -- 발생시킬 최대값 지정 (10의 27승 -1)
  [MINVALUE 숫자 | NOMINVALUE] -- 최소값 지정 (-10의 26승)
  [CYCLE | NOCYCLE] -- 값 순환 여부 지정
  [CACHE 바이트크기 | NOCACHE] -- 캐쉬메모리 기본값은 20바이트, 최소값은 2바이트
	-- 시퀀스의 캐시 메모리는 할당된 크기만큼 미리 다음 값들을 생성해 저장해둠
	-- --> 시퀀스 호출 시 미리 저장되어진 값들을 가져와 반환하므로 
	--     매번 시퀀스를 생성해서 반환하는 것보다 DB속도가 향상됨.
 * 
 * 
 * ** 사용법 **
 * 
 * 1) 시퀀스명.NEXTVAL : 다음 시퀀스 번호를 얻어옴.
 * 						 (INCREMENT BY 만큼 증가된 수)
 * 						 단, 생성 후 처음 호출된 시퀀스인 경우
 * 						 START WITH에 작성된 값이 반환됨.
 * 
 * 2) 시퀀스명.CURRVAL : 현재 시퀀스 번호를 얻어옴.
 * 						 단, 시퀀스가 생성 되자마자 호출할 경우 오류 발생.
 * 						 == 마지막으로 호출한 NEXTVAL 값을 반환
 */

/* 시퀀스 삭제*/
DROP SEQUENCE SEQ_TEST_NO;

/* 시퀀스 만들기 */
CREATE SEQUENCE SEQ_TEST_NO
START WITH 100 -- 시작 번호 100
INCREMENT BY 5 -- NEXTVAL 호출 시 5씩 증가
MAXVALUE 150   -- 증가 가능한 최댓값 150
NOMINVALUE     -- 최솟값 없음(CYCLE과 관련된 속성)
NOCYCLE        -- 순환 X
NOCACHE;       -- 미리 만들어두는 시퀀스 번호 없음

-- 시퀀스 테스트용 테이블 생성
CREATE TABLE TB_TEST(
	TEST_NO NUMBER PRIMARY KEY,
	TEST_NAME VARCHAR2(30) NOT NULL
);


-- 현재 시퀀스 번호 확인
SELECT SEQ_TEST_NO.CURRVAL FROM DUAL;
-- 시퀀스 SEQ_TEST_NO.CURRVAL은 이 세션에서는 정의 되어 있지 않습니다.
-- == NEXTVAL가 한 번도 호출된 적이 없다.
-- NEXTVAL 호출 후 CURRVAL 호출하면 됨

SELECT SEQ_TEST_NO.NEXTVAL FROM DUAL; -- 100
SELECT SEQ_TEST_NO.CURRVAL FROM DUAL; -- 100
SELECT SEQ_TEST_NO.NEXTVAL FROM DUAL; 
-- 105, 110, 115, 120 → 5씩 증가 확인

-- TB_TEST 테이블에 INSERT 시 PK 컬럼 값을
-- 시퀀스로 얻어와서 삽입
INSERT INTO TB_TEST 
VALUES(SEQ_TEST_NO.NEXTVAL, '짱구'); -- 125

INSERT INTO TB_TEST 
VALUES(SEQ_TEST_NO.NEXTVAL, '철수'); -- 130

INSERT INTO TB_TEST 
VALUES(SEQ_TEST_NO.NEXTVAL, '유리'); -- 135

SELECT * FROM TB_TEST;

-- UPDATE에서 시퀀스 사용하기
UPDATE TB_TEST 
SET TEST_NO = SEQ_TEST_NO.NEXTVAL
WHERE TEST_NAME = '짱구'; -- 140, 145, 150
-- 150 초과로 증가 불가(MAXVALUE)
-- 시퀀스 SEQ_TEST_NO.NEXTVAL exceeds MAXVALUE은 사례로 될 수 없습니다.

SELECT * FROM TB_TEST;

---------------------------------------------------------------------------------

-- SEQUENCE 변경(ALTER)

--> CREATE SEQUENCE 작성법이 유사함
--> 단, START WITH 제외

/*
 	[작성법]
  ALTER SEQUENCE 시퀀스이름
  [INCREMENT BY 숫자] -- 다음 값에 대한 증가치, 생략하면 자동 1이 기본
  [MAXVALUE 숫자 | NOMAXVALUE] -- 발생시킬 최대값 지정 (10의 27승 -1)
  [MINVALUE 숫자 | NOMINVALUE] -- 최소값 지정 (-10의 26승)
  [CYCLE | NOCYCLE] -- 값 순환 여부 지정
  [CACHE 바이트크기 | NOCACHE] -- 캐쉬메모리 기본값은 20바이트, 최소값은 2바이트
 */	

-- SEQ_TEST_NO의 
-- 증가 값을 10,
-- MAXVALUE를 200으로 수정
ALTER SEQUENCE SEQ_TEST_NO
INCREMENT BY 10
MAXVALUE 200;

UPDATE TB_TEST 
SET TEST_NO = SEQ_TEST_NO.NEXTVAL
WHERE TEST_NAME = '짱구'; -- 160, 170 ~ 200까지

SELECT * FROM TB_TEST;

-----------------------------------------------------

-- VIEW, SEQUENCE 삭제




------------------------------------------------------------------------

/* 
 * INDEX(색인)
 * - SQL 구문 중 SELECT 처리 속도를 향상시키기 위해 
 *   컬럼에 대하여 생성하는 객체
 * 
 * - 인덱스 내부 구조는 B* 트리 형식으로 되어있음.
 * 
 *  
 * ** INDEX의 장점 **
 * - 이진 트리 형식으로 구성되어 자동 정렬 및 검색 속도 증가
 * 
 * - 조회 시 테이블의 전체 내용을 확인하며 조회하는 것이 아닌
 *   인덱스가 지정된 컬럼만을 이용해서 조회하기 때문에
 *   시스템의 부하가 낮아짐
 * 
 * ** 인덱스의 단점 **
 * - 데이터 변경(INSERT,UPDATE,DELETE) 작업 시 
 * 	 이진 트리 구조에 변형이 일어남
 *    -> DML 작업이 빈번한 경우 시스템 부하가 늘어 성능이 저하됨.
 * 
 * - 인덱스도 하나의 객체이다 보니 별도 저장공간이 필요(메모리 소비)
 * 
 * - 인덱스 생성 시간이 필요함.
 * 
 * 
 * 
 *  [작성법]
 *  CREATE [UNIQUE] INDEX 인덱스명
 *  ON 테이블명 (컬럼명[, 컬럼명 | 함수명]);
 * 
 *  DROP INDEX 인덱스명;
 * 
 * 
 *  ** 인덱스가 자동 생성되는 경우 **
 *  -> PK 또는 UNIQUE 제약조건이 설정된 컬럼에 대해 
 *    UNIQUE INDEX가 자동 생성된다. 
 */

-- PK: 식별자(각 행 구분), 중복X, NULL X
-- UNIQUE: 중복X

/* 
 * 인덱스를 활용해서 검색하는 방법 
 * - SELECT문의 WHERE절에 INDEX가 설정된 컬럼을 언급하면 된다.
 */

-- INDEX 이용X
SELECT * FROM EMPLOYEE;

-- INDEX 이용O
SELECT * FROM EMPLOYEE
WHERE EMP_ID != 0;

/* WORKBOOK 계정으로 접속 */
SELECT COUNT(*) FROM TB_IDX_TEST; -- 100만개
-- TEST_NO(PK, INDEX), TEST_ID(NOT NULL)

-- 테이블 형태 확인
SELECT * FROM TB_IDX_TEST
WHERE TEST_NO = 1; -- 1 TEST1

/* 
 * 인덱스를 이용하지 않고 조회하기
 * - TEST_ID 컬럼 값이 'TEST500000'인 행 조회
 */

SELECT * FROM TB_IDX_TEST
WHERE TEST_ID = 'TEST500000'; -- 소요 시간 0.04s

/* 
 * 인덱스를 이용해서 조회하기
 * - TEST_ID 컬럼 값이 500000인 행 조회
 */

SELECT * FROM TB_IDX_TEST
WHERE TEST_NO = '500000'; -- 소요 시간 0.03s

/*
 * INDEX는 데이터의 양, 쿼리의 복잡도에 따라서
 * 속도가 더 증가할 수 있다.
 */
