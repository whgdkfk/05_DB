/*
    * SUBQUERY(서브쿼리)
    - 하나의 SQL문 안에 포함된 또다른 SQL문
    - 메인쿼리(기존쿼리)를 위해 보조 역할을 하는 쿼리문
    -- SELECT, FROM, WHERE, HAVGIN 절에서 사용가능
    
    -- Main Query = SELECT, INSERT, UPDATE, DELETE, CREATE, FUNCTION, ...
    -- Sub Query  = SELECT
 */  

-- 서브쿼리 예시 1.
-- 부서코드가 노옹철 사원과 같은 소속의 직원의 
-- 이름, 부서코드 조회하기

-- 1) 사원명이 노옹철인 사람의 부서코드 조회
SELECT DEPT_CODE
FROM EMPLOYEE 
WHERE EMP_NAME = '노옹철'; -- D9(1행 1열)

-- 2) 부서코드가 D9인 직원을 조회
SELECT EMP_NAME, DEPT_CODE
FROM EMPLOYEE 
WHERE DEPT_CODE = 'D9'; -- 선동일, 송종기, 노옹철

-- 3) 부서코드가 노옹철사원과 같은 소속의 직원 명단 조회   
--> 위의 2개의 단계를 하나의 쿼리로!!! --> 1) 쿼리문을 서브쿼리로!!
SELECT -- 메인쿼리 
		EMP_NAME
	, DEPT_CODE
FROM 
	EMPLOYEE 
WHERE 
	DEPT_CODE = (SELECT -- 서브쿼리
								DEPT_CODE 
							 FROM 
							 	EMPLOYEE 
							 WHERE 
								EMP_NAME = '노옹철');
                   
-- 서브쿼리 예시 2.
-- 전 직원의 평균 급여보다 많은 급여를 받고 있는 직원의 
-- 사번, 이름, 직급코드, 급여 조회

-- 1) 전 직원의 평균 급여 조회하기
SELECT FLOOR(AVG(SALARY))
FROM EMPLOYEE;

-- 2) 직원들중 급여가 4091140원 이상인 사원들의 사번, 이름, 직급코드, 급여 조회
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY 
FROM EMPLOYEE 
WHERE SALARY >= 4091140;

-- 3) 전 직원의 평균 급여보다 많은 급여를 받고 있는 직원 조회
--> 위의 2단계를 하나의 쿼리로 가능하다!! --> 1) 쿼리문을 서브쿼리로!!
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY 
FROM EMPLOYEE 
WHERE SALARY >= (SELECT FLOOR(AVG(SALARY))
								 FROM EMPLOYEE);
                 
-------------------------------------------------------------------

/*  서브쿼리 유형

    - 단일행 서브쿼리: 서브쿼리의 조회 결과 값의 개수가 1개일 때 
    
    - 다중행 서브쿼리: 서브쿼리의 조회 결과 값의 개수가 여러개일 때
    
    - 다중열 서브쿼리: 서브쿼리의 SELECT 절에 자열된 항목수가 여러개 일 때
    
    - 다중행 다중열 서브쿼리: 조회 결과 행 수와 열 수가 여러개일 때 
    
    - 상관 서브쿼리: 서브쿼리가 만든 결과 값을 메인 쿼리가 비교 연산할 때 
                     메인 쿼리 테이블의 값이 변경되면 서브쿼리의 결과값도 바뀌는 서브쿼리
                     
    - 스칼라 서브쿼리: 상관 쿼리이면서 결과 값이 하나인 서브쿼리
    
   * 서브쿼리 유형에 따라 서브쿼리 앞에 붙은 연산자가 다름
    
 */


-- 1. 단일행 서브쿼리(SINGLE ROW SUBQUERY) == 단일행 단일열
--    서브쿼리의 조회 결과 값의 개수가 1개인 서브쿼리
--    단일행 서브쿼리 앞에는 비교 연산자 사용
--    <, >, <=, >=, =, !=/^=/<>


-- 전 직원의 급여 평균보다 많은 급여를 받는 직원의 
-- 이름, 직급명, 부서명, 급여를 직급 순으로 정렬하여 조회
SELECT EMP_NAME, J.JOB_NAME, D.DEPT_TITLE, E.SALARY 
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
LEFT OUTER JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
WHERE E.SALARY > (SELECT AVG(SALARY) FROM EMPLOYEE)
ORDER BY E.JOB_CODE ASC;

-- 가장 적은 급여를 받는 직원의
-- 사번, 이름, 직급명, 부서코드, 급여, 입사일을 조회
SELECT 
	E.EMP_ID, E.EMP_NAME, J.JOB_NAME, 
	E.DEPT_CODE, E.SALARY, E.HIRE_DATE
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE SALARY = (SELECT MIN(SALARY) FROM EMPLOYEE);
                 
-- 노옹철 사원의 급여보다 많이 받는 직원의 
-- 사번, 이름, 부서명, 직급명, 급여를 조회
SELECT 
	E.EMP_ID, E.EMP_NAME, 
	D.DEPT_TITLE, J.JOB_NAME, E.SALARY
FROM EMPLOYEE E
JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE SALARY > (SELECT SALARY 
								FROM EMPLOYEE 
								WHERE EMP_NAME = '노옹철');

 
-- 부서별(부서가 없는 사람 포함) 급여의 합계 중 가장 큰 부서의
-- 부서명, 급여 합계를 조회 

-- 1) 부서별 급여 합 중 가장 큰값 조회
SELECT MAX(SUM(SALARY))
FROM EMPLOYEE 
GROUP BY DEPT_CODE; -- 21760000

-- 2) 부서별 급여합이 21760000원 부서의 부서명과 급여 합 조회
SELECT DEPT_CODE, SUM(SALARY)
FROM EMPLOYEE 
--JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
GROUP BY DEPT_CODE
HAVING SUM(SALARY) = 21760000;

-- WHERE: FROM절 테이블에서 조회를 원하는 행에 대한 조건
-- HAVING: GROUP BY절에 의해 만들어진 그룹 중 조회를 원하는 그룹에 대한 조건


-- 3) >> 위의 두 서브쿼리를 합쳐 부서별 급여 합이 큰 부서의 부서명, 급여 합 조회
SELECT DEPT_CODE, SUM(SALARY)
FROM EMPLOYEE 
GROUP BY DEPT_CODE
HAVING SUM(SALARY) = (SELECT MAX(SUM(SALARY))
											FROM EMPLOYEE 
											GROUP BY DEPT_CODE);
                      
-- 부서별 인원수가 3명 이상인 부서의
-- 부서명, 인원수 조회
SELECT D.DEPT_TITLE, COUNT(*)
FROM EMPLOYEE E
LEFT JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
GROUP BY D.DEPT_TITLE
HAVING COUNT(*) >= 3;

/*
 * GROUP BY가 사용된 SELECT문의 SELECT절에는 
 * 그룹 함수 또는 GROUP BY에 사용된 컬럼명만 작성 가능하다.
 */

-- 부서별 인원수가 가장 적은 부서의 부서명, 인원수 조회
-- 단, 부서명이 없으면 '없음'으로 표시
SELECT NVL(D.DEPT_TITLE, '없음'), COUNT(*)
FROM EMPLOYEE E
LEFT JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
GROUP BY D.DEPT_TITLE
HAVING COUNT(*) = (SELECT MIN(COUNT(*)) -- 서브쿼리: 2
									 FROM EMPLOYEE 
									 GROUP BY DEPT_CODE);

-------------------------------------------------------------------------

-- 2. 다중행 서브쿼리 (MULTI ROW SUBQUERY)
--    서브쿼리의 조회 결과 값의 개수가 여러 행일 때 

/*
    >> 다중행 서브쿼리 앞에는 일반 비교연산자 사용 x
    
    - IN / NOT IN : 여러 개의 결과값 중에서 한 개라도 일치하는 값이 있다면
                    혹은 없다면 이라는 의미(가장 많이 사용!)
    - > ANY, < ANY : 여러개의 결과값 중에서 한개라도 큰 / 작은 경우
                     가장 작은 값보다 큰가? / 가장 큰 값 보다 작은가?
    - > ALL, < ALL : 여러개의 결과값의 모든 값보다 큰 / 작은 경우
                     가장 큰 값 보다 큰가? / 가장 작은 값 보다 작은가?
    - EXISTS / NOT EXISTS : 값이 존재하는가? / 존재하지 않는가?
    
*/

-- 부서별 최고 급여를 받는 직원의 
-- 이름, 직급, 부서, 급여를 부서 순으로 정렬하여 조회

-- 1) 부서별 최고 급여만 조회
SELECT DEPT_CODE, MAX(SALARY)
FROM EMPLOYEE
GROUP BY DEPT_CODE;

-- 2) 부서별 최고 급여를 받는 직원 조회
SELECT EMP_NAME, JOB_CODE, DEPT_CODE, SALARY 
FROM EMPLOYEE 
WHERE SALARY IN (SELECT MAX(SALARY) -- 결과: 7행
								 FROM EMPLOYEE
								 GROUP BY DEPT_CODE);


-- 사수에 해당하는 직원에 대해 조회 
--  사번, 이름, 부서명, 직급명, 구분(사수 / 직원)

-- 1) 사수에 해당하는 사원 번호 조회
-- == MANAGER_ID 컬럼에 사번이 작성된 사원
--  + DISTINCT: 컬럼 값 중복 제거
SELECT DISTINCT MANAGER_ID
FROM EMPLOYEE
WHERE MANAGER_ID IS NOT NULL;

-- 2) 직원의 사번, 이름, 부서명, 직급명 조회
SELECT 
		E.EMP_ID	
	, E.EMP_NAME
	, NVL(D.DEPT_TITLE, '없음') AS DEPT_TITLE
	, J.JOB_NAME
FROM EMPLOYEE E
LEFT JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE);

-- 3) 사수에 해당하는 직원에 대한 정보 추출 조회 (이때, 구분은 '사수'로)
SELECT 
		E.EMP_ID	
	, E.EMP_NAME
	, NVL(D.DEPT_TITLE, '없음') AS DEPT_TITLE
	, J.JOB_NAME
	, '사수' AS 구분
FROM EMPLOYEE E
LEFT JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE E.EMP_ID IN (SELECT DISTINCT MANAGER_ID
									 FROM EMPLOYEE
									 WHERE MANAGER_ID IS NOT NULL); -- 6행

-- 4) 일반 직원에 해당하는 사원들 정보 조회 (이때, 구분은 '사원'으로)
SELECT 
		E.EMP_ID	
	, E.EMP_NAME
	, NVL(D.DEPT_TITLE, '없음') AS DEPT_TITLE
	, J.JOB_NAME
	, '사수' AS 구분
FROM EMPLOYEE E
LEFT JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE E.EMP_ID NOT IN -- 사수 역할을 갖지 않는 사원만
									(SELECT DISTINCT MANAGER_ID
									 FROM EMPLOYEE
									 WHERE MANAGER_ID IS NOT NULL); -- 17행
            
-- 5) 3, 4의 조회 결과를 하나로 합침 -> SELECT절 SUBQUERY
-- * SELECT 절에도 서브쿼리 사용할 수 있음
SELECT 
		E.EMP_ID	
	, E.EMP_NAME
	, NVL(D.DEPT_TITLE, '없음') AS DEPT_TITLE
	, J.JOB_NAME
	, '사수' AS 구분
FROM EMPLOYEE E
LEFT JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE E.EMP_ID IN (SELECT DISTINCT MANAGER_ID
									 FROM EMPLOYEE
									 WHERE MANAGER_ID IS NOT NULL)
UNION 
SELECT 
		E.EMP_ID	
	, E.EMP_NAME
	, NVL(D.DEPT_TITLE, '없음') AS DEPT_TITLE
	, J.JOB_NAME
	, '사수' AS 구분
FROM EMPLOYEE E
LEFT JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE E.EMP_ID NOT IN -- 사수 역할을 갖지 않는 사원만
									(SELECT DISTINCT MANAGER_ID
									 FROM EMPLOYEE
									 WHERE MANAGER_ID IS NOT NULL);

/* SELECT절에 서브쿼리를 작성해서 길이 줄이기 */
SELECT 
		E.EMP_ID	
	, E.EMP_NAME
	, NVL(D.DEPT_TITLE, '없음') AS DEPT_TITLE
	, J.JOB_NAME
	, CASE 
			-- 현재 행의 EMP_ID와 일치하는 값이 
			-- 서브쿼리 결과에 있으면 '사수', 없으면 '사원'
			WHEN E.EMP_ID IN (SELECT DISTINCT MANAGER_ID -- 다중행 서브쿼리
												FROM EMPLOYEE 
												WHERE MANAGER_ID IS NOT NULL)
			THEN '사수'
			ELSE '사원'
		END
		AS 구분
FROM EMPLOYEE E
LEFT JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE);

-- 대리 직급의 직원들 중에서 과장 직급의 최소 급여보다 많이 받는 직원의
-- 사번, 이름, 직급, 급여를 조회하세요
-- 단, > ANY 혹은 < ANY 연산자를 사용하세요


-- > ANY, < ANY : 여러 개의 결과값 중에서 하나라도 큰 / 작은 경우
--                     가장 작은 값보다 큰가? / 가장 큰 값 보다 작은가?

-- 1) 직급이 대리인 직원들의 사번, 이름, 직급명, 급여 조회
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY 
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE J.JOB_NAME = '대리';

-- 2) 직급이 과장인 직원들 급여 조회
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY 
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE J.JOB_NAME = '과장';


-- 3) 대리 직급의 직원들 중에서 과장 직급의 최소 급여보다 많이 받는 직원
-- 3-1) MIN을 이용하여 단일행 서브쿼리를 만듦.
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY 
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE J.JOB_NAME = '대리'
AND E.SALARY > (SELECT MIN(E.SALARY) -- 과장 최소 급여(320만)보다 많이 받는 대리 조회
								FROM EMPLOYEE E
								JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
								WHERE J.JOB_NAME = '과장');	

-- 3-2) ANY를 이용하여 과장 중 가장 급여가 적은 직원 초과하는 대리를 조회
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY 
FROM EMPLOYEE E
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE J.JOB_NAME = '대리'
AND E.SALARY > ANY(SELECT E.SALARY -- 476만, 320만, 350만
									 FROM EMPLOYEE E
									 JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
									 WHERE J.JOB_NAME = '과장');	


-- 차장 직급의 급여의 가장 큰 값보다 많이 받는 과장 직급의 직원
-- 사번, 이름, 직급, 급여를 조회하세요
-- 단, > ALL 혹은 < ALL 연산자를 사용하세요

-- > ALL, < ALL : 여러개의 결과값의 모든 값보다 큰 / 작은 경우
--                     가장 큰 값 보다 크냐? / 가장 작은 값 보다 작냐?

-- 1) MAX 이용
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY
FROM EMPLOYEE E
JOIN JOB J ON (J.JOB_CODE = E.JOB_CODE)
WHERE J.JOB_NAME = '과장'
AND SALARY > (SELECT MAX(SALARY) 
							FROM EMPLOYEE E
							JOIN JOB J ON (J.JOB_CODE = E.JOB_CODE)
							WHERE J.JOB_NAME = '차장');

-- 2) > ALL 이용
SELECT E.EMP_ID, E.EMP_NAME, J.JOB_NAME, E.SALARY
FROM EMPLOYEE E
JOIN JOB J ON (J.JOB_CODE = E.JOB_CODE)
WHERE J.JOB_NAME = '과장'
AND SALARY > ALL(SELECT SALARY -- 380, 348, 349, 255
								 FROM EMPLOYEE E
								 JOIN JOB J ON (J.JOB_CODE = E.JOB_CODE)
								 WHERE J.JOB_NAME = '차장');                    
                      
-- 서브쿼리 중첩 사용(응용편!)


-- LOCATION 테이블에서 NATIONAL_CODE가 KO인 경우의 LOCAL_CODE와
-- DEPARTMENT 테이블의 LOCATION_ID와 동일한 DEPT_ID가 
-- EMPLOYEE테이블의 DEPT_CODE와 동일한 사원을 구하시오.

-- 1) LOCATION 테이블을 통해 NATIONAL_CODE가 KO인 LOCAL_CODE 조회
SELECT LOCAL_CODE
FROM LOCATION 
WHERE NATIONAL_CODE = 'KO'; -- L1(단일행)

-- 2)DEPARTMENT 테이블에서 위의 결과와 동일한 
-- LOCATION_ID를 가지고 있는 DEPT_ID를 조회
SELECT DEPT_ID
FROM DEPARTMENT 
WHERE LOCATION_ID = (SELECT LOCAL_CODE
										 FROM LOCATION 
										 WHERE NATIONAL_CODE = 'KO'); 
-- D1, D2, D3, D4, D9(다중행)

-- 3) 최종적으로 EMPLOYEE 테이블에서 
-- 위의 결과들과 동일한 DEPT_CODE를 가지는 사원을 조회
SELECT EMP_NAME, DEPT_CODE -- 3) 메인쿼리
FROM EMPLOYEE 
WHERE DEPT_CODE IN (SELECT DEPT_ID -- 2) 서브쿼리
										FROM DEPARTMENT 
										WHERE LOCATION_ID = (SELECT LOCAL_CODE -- 1) 서브쿼리
										 										 FROM LOCATION 
										 										 WHERE NATIONAL_CODE = 'KO'));
                  
-----------------------------------------------------------------------

-- 3. 다중열 서브쿼리 (단일행 = 결과값은 한 행)
--    서브쿼리 SELECT 절에 나열된 컬럼 수가 여러개 일 때

-- 퇴사한 여직원과 같은 부서, 같은 직급에 해당하는
-- 사원의 이름, 직급, 부서, 입사일을 조회        

-- 1) 퇴사한 여직원 조회
SELECT EMP_NAME, DEPT_CODE, JOB_CODE, HIRE_DATE
FROM EMPLOYEE 
WHERE ENT_YN = 'Y'
AND SUBSTR(EMP_NO, 8, 1) IN ('2', '4');

-- 2) 퇴사한 여직원과 같은 부서, 같은 직급 (다중 열 서브쿼리)
SELECT EMP_NAME, DEPT_CODE, JOB_CODE, HIRE_DATE
FROM EMPLOYEE 
WHERE DEPT_CODE = (SELECT DEPT_CODE
									 FROM EMPLOYEE 
									 WHERE ENT_YN = 'Y'
									 AND SUBSTR(EMP_NO, 8, 1) IN ('2', '4'))	
AND JOB_CODE = (SELECT JOB_CODE
							  FROM EMPLOYEE 
								WHERE ENT_YN = 'Y'
								AND SUBSTR(EMP_NO, 8, 1) IN ('2', '4'));

/* 다중열 서브쿼리 사용 */
SELECT EMP_NAME, DEPT_CODE, JOB_CODE, HIRE_DATE
FROM EMPLOYEE 
WHERE (DEPT_CODE, JOB_CODE) = (
				SELECT DEPT_CODE, JOB_CODE 
				FROM EMPLOYEE 
				WHERE ENT_YN = 'Y'
				AND SUBSTR(EMP_NO, 8, 1) IN ('2', '4')
			);
-- 비교하려는 컬럼을 ()로 묶어서
-- 여러 컬럼을 한 번에 비교

-------------------------- 연습문제 -------------------------------
-- 1. 노옹철 사원과 같은 부서, 같은 직급인 사원을 조회하시오. (단, 노옹철 사원은 제외)
--    사번, 이름, 부서코드, 직급코드, 부서명, 직급명
SELECT E.EMP_ID, E.EMP_NAME, E.DEPT_CODE, E.JOB_CODE, D.DEPT_TITLE, J.JOB_NAME 
FROM EMPLOYEE E
JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE (E.DEPT_CODE, E.JOB_CODE) = (
				SELECT DEPT_CODE, JOB_CODE
				FROM EMPLOYEE 
				WHERE EMP_NAME = '노옹철'
			)
AND E.EMP_NAME != '노옹철';

-- 2. 2010년도에 입사한 사원의 부서와 직급이 같은 사원을 조회하시오
--    사번, 이름, 부서코드, 직급코드, 고용일
SELECT 
		EMP_ID
	, EMP_NAME
	, DEPT_CODE
	, JOB_CODE
	, HIRE_DATE
FROM EMPLOYEE
WHERE (DEPT_CODE, JOB_CODE) = (
			SELECT DEPT_CODE, JOB_CODE
			FROM EMPLOYEE
--		WHERE EXTRACT(YEAR FROM HIRE_DATE) = 2010
			WHERE TO_CHAR(HIRE_DATE, 'YYYY') = '2010'
			);

-- 3. 87년생 여자 사원과 동일한 부서이면서 동일한 사수를 가지고 있는 사원을 조회하시오
--    사번, 이름, 부서코드, 사수번호, 주민번호, 고용일     
SELECT 	
		EMP_ID
	, EMP_NAME
	, DEPT_CODE
	, MANAGER_ID
	, EMP_NO
	, HIRE_DATE
--	, SUBSTR(EMP_NO, 1, 2)
FROM EMPLOYEE 
WHERE (DEPT_CODE, MANAGER_ID) = (		
			SELECT DEPT_CODE, MANAGER_ID
			FROM EMPLOYEE 
			WHERE SUBSTR(EMP_NO, 1, 2) = '87'
			AND SUBSTR(EMP_NO, 8, 1) = '2'
		);

----------------------------------------------------------------------

-- 다중행 서브쿼리 → IN, > ANY, > ALL 연산자 사용
-- 다중열 서브쿼리 → WHERE절 컬럼을 (A, B)로 묶음

-- 4. 다중행 다중열 서브쿼리
--    서브쿼리 조회 결과 행 수와 열 수가 여러개 일 때

-- 본인 직급의 평균 급여를 받고 있는 직원의
-- 사번, 이름, 직급, 급여를 조회하세요
-- 단, 급여와 급여 평균은 만원 단위로 계산하세요. TRUNC(컬럼명, -4)    

-- 1) 급여를 300, 700만 받는 직원 (300만, 700만이 평균 급여라 생각할 경우)
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE 
WHERE SALARY IN (3000000, 7000000);

-- 2) 직급별 평균 급여
SELECT JOB_CODE, TRUNC(AVG(SALARY), -4)
FROM EMPLOYEE 
GROUP BY JOB_CODE;

-- 3) 본인 직급의 평균 급여를 받고 있는 직원
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE 
WHERE (JOB_CODE, SALARY) IN (
			SELECT JOB_CODE, TRUNC(AVG(SALARY), -4)
			FROM EMPLOYEE 
			GROUP BY JOB_CODE
			);
                  
                

-------------------------------------------------------------------------------

-- 5. 상[호연]관 서브쿼리
--    상관 쿼리는 메인쿼리가 사용하는 테이블값을 서브쿼리가 이용해서 결과를 만듦
--    메인쿼리의 테이블값이 변경되면 서브쿼리의 결과값도 바뀌게 되는 구조임

-- 상관쿼리는 먼저 메인쿼리 한 행을 조회하고
-- 해당 행이 서브쿼리의 조건을 충족하는지 확인하여 SELECT를 진행함


-- 사수가 있는 직원의 사번, 이름, 부서명, 사수사번 조회



-- 직급별 급여 평균보다 급여를 많이 받는 직원의 
-- 이름, 직급코드, 급여 조회



-- 부서별 입사일이 가장 빠른 사원의
--    사번, 이름, 부서명(NULL이면 '소속없음'), 직급명, 입사일을 조회하고
--    입사일이 빠른 순으로 조회하세요
--    단, 퇴사한 직원은 제외하고 조회하세요



----------------------------------------------------------------------------------

-- 6. 스칼라 서브쿼리
--    SELECT절에 사용되는 서브쿼리 결과로 1행만 반환
--    SQL에서 단일 값을 가르켜 '스칼라'라고 함

-- 각 직원들이 속한 직급의 급여 평균 조회



-- 모든 사원의 사번, 이름, 관리자사번, 관리자명을 조회
-- 단 관리자가 없는 경우 '없음'으로 표시
-- (스칼라 + 상관 쿼리)





-----------------------------------------------------------------------


-- 7. 인라인 뷰(INLINE-VIEW)
--    FROM 절에서 서브쿼리를 사용하는 경우로
--    서브쿼리가 만든 결과의 집합(RESULT SET)을 테이블 대신에 사용한다.

-- 인라인뷰를 활용한 TOP-N분석
-- 전 직원 중 급여가 높은 상위 5명의
-- 순위, 이름, 급여 조회





-- 급여 평균이 3위 안에 드는 부서의 부서코드와 부서명, 평균급여를 조회


------------------------------------------------------------------------

-- 8. WITH
--    서브쿼리에 이름을 붙여주고 사용시 이름을 사용하게 함
--    인라인뷰로 사용될 서브쿼리에 주로 사용됨
--    실행 속도도 빨라진다는 장점이 있다. 

-- 
-- 전 직원의 급여 순위 
-- 순위, 이름, 급여 조회

--------------------------------------------------------------------------


-- 9. RANK() OVER / DENSE_RANK() OVER

-- RANK() OVER : 동일한 순위 이후의 등수를 동일한 인원 수 만큼 건너뛰고 순위 계산
--               EX) 공동 1위가 2명이면 다음 순위는 2위가 아니라 3위



-- DENSE_RANK() OVER : 동일한 순위 이후의 등수를 이후의 순위로 계산
--                     EX) 공동 1위가 2명이어도 다음 순위는 2위



