@echo off
setlocal EnableExtensions

rem self-hosted runner 장비에서 필요한 도구가 준비됐는지 확인한다.
rem 등록 전에 한 번, 장애가 날 때 한 번 보면 된다.

call "%~dp0common.bat"

rem runner 장비에서 실제로 쓰는 도구들이 모두 있어야 한다.
where git >nul 2>&1 || (
  echo 필수 명령을 찾지 못했습니다: git
  exit /b 1
)
where java >nul 2>&1 || (
  echo 필수 명령을 찾지 못했습니다: java
  exit /b 1
)
where docker >nul 2>&1 || (
  echo 필수 명령을 찾지 못했습니다: docker
  exit /b 1
)
where kubectl >nul 2>&1 || (
  echo 필수 명령을 찾지 못했습니다: kubectl
  exit /b 1
)
where minikube >nul 2>&1 || (
  echo 필수 명령을 찾지 못했습니다: minikube
  exit /b 1
)
where curl >nul 2>&1 || (
  echo 필수 명령을 찾지 못했습니다: curl
  exit /b 1
)
where bash >nul 2>&1 || (
  echo 필수 명령을 찾지 못했습니다: bash
  echo Git Bash를 설치하고 PATH에 bash.exe가 잡히도록 설정하세요.
  exit /b 1
)

echo [runner-check] 도구 버전 확인
git --version
java -version
docker --version
kubectl version --client
minikube version
curl --version

echo.
echo [runner-check] 로컬 실행 상태 확인
docker ps >nul
if errorlevel 1 exit /b 1
minikube status
if errorlevel 1 exit /b 1
kubectl get ns >nul
if errorlevel 1 exit /b 1

echo.
echo [runner-check] 준비 확인 완료
echo 작업 루트: %WORKSPACE_ROOT%
exit /b 0
