--// 부서명을 입력받아
--		// 해당 부서의 근무하는 사원의
--		// 사번, 이름, 부서명, 직급명을
--		// 직급코드 내림차순으로 조회
	
SELECT E.EMP_ID, E.EMP_NAME, D.DEPT_TITLE, J.JOB_NAME
FROM EMPLOYEE E
JOIN DEPARTMENT D ON (E.DEPT_CODE = D.DEPT_ID)
JOIN JOB J ON (E.JOB_CODE = J.JOB_CODE)
WHERE D.DEPT_TITLE = '총무부'
ORDER BY J.JOB_CODE DESC;
