-- 1번 
-- 영어영문학과(학과코드 002) 학생들의 학번과 이름, 입학 년도를  
-- 입학 년도가 빠른 순으로 표시하는 SQL을 작성하시오. 
-- (단, 헤더는 "학번", "이름", "입학년도" 가 표시되도록 한다.)
SELECT 
		STUDENT_NO AS "학번"
	, STUDENT_NAME AS "이름"
--	, SUBSTR(ENTRANCE_DATE, 1, 10)
--	, TO_DATE(SUBSTR(ENTRANCE_DATE, 1, 10), 'YYYY-MM-DD') AS "입학년도"
	, TO_CHAR(ENTRANCE_DATE, 'YYYY-MM-DD')  AS "입학년도"
-- TO_CHAR: 날짜 → 문자열
-- TO_DATE: 문자열 → 날짜
FROM 
	TB_STUDENT 
WHERE 
	DEPARTMENT_NO = '002'
ORDER BY 입학년도 ASC;

-- 2번 
-- 춘 기술대학교의 교수 중 이름이 세 글자가 아닌 교수가 두 명 있다고 한다.  
-- 그 교수의 이름과 주민번호를 조회하는 SQL을 작성하시오. 
SELECT PROFESSOR_NAME, PROFESSOR_SSN 
FROM TB_PROFESSOR 
WHERE PROFESSOR_NAME 