/* DCL(Data Control Language) : 데이터 제어 언어
 * 
 * - 계정별로 DB 또는 DB 객체에 대한 
 *   접근(제어) 권한을 부여(GRANT), 회수(REVOKE)하는 언어
 */


/* 계정(사용자)

* 관리자 계정 : 데이터베이스의 생성과 관리를 담당하는 계정
                모든 권한과 책임을 가지는 계정
                ex) sys(최고관리자), system(sys에서 권한 몇개 제외된 관리자)


* 사용자 계정 : 데이터베이스에 대하여 질의, 갱신, 보고서 작성 등의
                작업을 수행할 수 있는 계정으로
                업무에 필요한 최소한의 권한만을 가지는 것을 원칙으로 한다.
                ex) KH계정(각자 이니셜 계정), workbook 등
 */


/* 권한의 종류

1) 시스템 권한 : DB접속, 객체 생성 권한

CRETAE SESSION   : 데이터베이스 접속 권한
CREATE TABLE     : 테이블 생성 권한
CREATE VIEW      : 뷰 생성 권한
CREATE SEQUENCE  : 시퀀스 생성 권한
CREATE PROCEDURE : 함수(프로시져) 생성 권한
CREATE USER      : 사용자(계정) 생성 권한
DROP USER        : 사용자(계정) 삭제 권한
DROP ANY TABLE   : 임의 테이블 삭제 권한


2) 객체 권한 : 특정 객체를 조작할 수 있는 권한

   권한 종류                 설정 객체
    SELECT              TABLE, VIEW, SEQUENCE
    INSERT              TABLE, VIEW
    UPDATE              TABLE, VIEW
    DELETE              TABLE, VIEW
    ALTER               TABLE, SEQUENCE
    REFERENCES          TABLE
    INDEX               TABLE
    EXECUTE             PROCEDURE
 */



----------------------------------------------------------------------------

/* 관리자 계정 접속 → 사용자 계정 생성 */
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
--> 오라클 12C 이상 버전에서
--  계정명을 있는 그대로 사용하고 싶을 때 적용하는 옵션

/*
 * [사용자 계정 생성]
 * CREATE USER 사용자명 IDENTIFIED BY 비밀번호;
 */

CREATE USER TEST24_USER 
IDENTIFIED BY "TEST1234";

-- CREATE SESSION 권한을 가지고 있지 않음;
-- 로그온이 거절되었습니다.

/* 
 * [시스템 권한 부여]
 * - GRANT 권한, ... TO 사용자명;
 */

GRANT CREATE SESSION TO TEST24_USER;
--> 연결 확인됨

/* 생성된 사용자 계정으로 접속(TEST24_USER) */
CREATE TABLE TEST_TABLE(
	PK_NO NUMBER PRIMARY KEY,
	TEST_COL VARCHAR2(30) NOT NULL
);
--> SQL Error [1031] [42000]: ORA-01031: 권한이 불충분합니다.
-- + 사용 가능한 공간(TABLESPACE) 할당

/* 다시 관리자로 접속 */
GRANT RESOURCE TO TEST24_USER;

/*
 * ROLE(역할): 권한의 묶음
 * - CONNECT: 접속 관련 권한 묶음
 * - RESOURCE: 객체 생성 권한 묶음
 */

--SELECT * FROM ROLE_SYS_PRIVS
--WHERE ROLE = 'CONNECT';

/* 
 * TEST24_USER에게 테이블 생성 공간 할당 
 * - USERS 폴더 내에 10M 할당
 */
ALTER USER TEST24_USER
DEFAULT TABLESPACE USERS
QUOTA 10M ON USERS;

/* 다시 TEST24_USER 계정 접속 후 테이블 생성 */
CREATE TABLE TEST_TABLE(
	PK_NO NUMBER PRIMARY KEY,
	TEST_COL VARCHAR2(30) NOT NULL
);
--> 생성 성공

------------------------------------------------------------------

/* TEST24_USER 계정 접속 */

/* 객체 권한 부여 */
SELECT * FROM KH24_JAR.EMPLOYEE; -- 없어서 조회 못함
-- 테이블 또는 뷰가 존재하지 않습니다

/* KH24_JAR 계정 접속 */
-- TEST 계정에 권한 부여

/* 
 * [객체 권한 부여 방법]
 * - GRANT 객체 권한 ON 객체명 TO 사용자명;
 */
GRANT SELECT ON EMPLOYEE
TO TEST24_USER;

/* TEST24_USER 계정 접속 */
-- KH 계정의 EMPLOYEE 조회 시도
SELECT *
FROM KH24_JAR.EMPLOYEE;

------------------------------------------------------------------
/* KH 계정 접속 */

/* 
 * 권한 회수: REVOKE 
 * 
 * REVOKE 객체권한 ON 객체명 
 * FROM (회수할 사용자 계정명)
 */
REVOKE SELECT ON EMPLOYEE
FROM TEST24_USER;

/* TEST 계정 접속 → EMPLOYEE 조회 */
SELECT *
FROM KH24_JAR.EMPLOYEE;
-- 조회 권한을 회수당해서 조회 불가

------------------------------------------------------------------
/* 관리자 계정 접속 */

/* 
 * [사용자 계정 삭제]
 * DROP USER 사용자명 CASCADE;
 * 단, 현재 접속 중인 상태면 삭제 불가
 */
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
DROP USER TEST24_USER CASCADE; 















