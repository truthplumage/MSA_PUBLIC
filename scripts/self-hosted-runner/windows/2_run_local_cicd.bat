@echo off
setlocal EnableExtensions

rem self-hosted runner에서 호출할 로컬 배포 스크립트
rem 순서:
rem 1) minikube 시작
rem 2) config-service 배포
rem 3) discovery 배포
rem 4) apigateway 배포
rem 5) member-service 배포

call "%~dp0common.bat"

rem 이 스크립트는 minikube, kubectl, docker, bash를 모두 사용한다.
where minikube >nul 2>&1 || (
  echo 필수 명령을 찾지 못했습니다: minikube
  exit /b 1
)
where kubectl >nul 2>&1 || (
  echo 필수 명령을 찾지 못했습니다: kubectl
  exit /b 1
)
where docker >nul 2>&1 || (
  echo 필수 명령을 찾지 못했습니다: docker
  exit /b 1
)
where bash >nul 2>&1 || (
  echo 필수 명령을 찾지 못했습니다: bash
  echo Git Bash를 설치하고 PATH에 bash.exe가 잡히도록 설정하세요.
  exit /b 1
)

echo [runner-deploy] minikube 시작
minikube start --driver=%MINIKUBE_DRIVER%
if errorlevel 1 exit /b 1

call :run_module "%MSA_DIR_BASH%/config" "config-service"
if errorlevel 1 exit /b 1

call :run_module "%MSA_DIR_BASH%/discovery" "discovery"
if errorlevel 1 exit /b 1

call :run_module "%MSA_DIR_BASH%/apigateway" "apigateway"
if errorlevel 1 exit /b 1

call :run_module "%MEMBER_DIR_BASH%" "member-service"
if errorlevel 1 exit /b 1

echo.
echo [runner-deploy] 배포 완료
echo 상태 확인은 3_check_local_cicd.bat로 진행하세요.
exit /b 0

:run_module
set "MODULE_DIR=%~1"
set "MODULE_NAME=%~2"

echo [runner-deploy] %MODULE_NAME% 배포 시작
bash -lc "cd \"%MODULE_DIR%\" && IMAGE_REGISTRY=\"%IMAGE_REGISTRY%\" IMAGE_TAG=\"%IMAGE_TAG%\" NAMESPACE=\"%NAMESPACE%\" LOAD_TO_MINIKUBE=\"%LOAD_TO_MINIKUBE%\" ./scripts/all_in_one.sh"
exit /b %errorlevel%
