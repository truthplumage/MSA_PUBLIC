@echo off
setlocal EnableExtensions

rem self-hosted runner 배포 후 상태를 확인한다.
rem Pod/Service 상태를 보고, 필요하면 게이트웨이 Swagger 응답도 체크한다.

call "%~dp0common.bat"

rem 상태 조회와 HTTP 확인에 필요한 명령만 체크한다.
where kubectl >nul 2>&1 || (
  echo 필수 명령을 찾지 못했습니다: kubectl
  exit /b 1
)
where powershell >nul 2>&1 || (
  echo 필수 명령을 찾지 못했습니다: powershell
  exit /b 1
)

echo [runner-check] deployment 상태
kubectl -n %NAMESPACE% get deployment
if errorlevel 1 exit /b 1

echo.
echo [runner-check] pod 상태
kubectl -n %NAMESPACE% get pods -o wide
if errorlevel 1 exit /b 1

echo.
echo [runner-check] service 상태
kubectl -n %NAMESPACE% get svc
if errorlevel 1 exit /b 1

if /i not "%CHECK_SWAGGER%"=="true" exit /b 0

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$log = Join-Path $env:TEMP 'runner-local-port-forward.log';" ^
  "$proc = Start-Process kubectl -ArgumentList '-n','%NAMESPACE%','port-forward','svc/apigateway','%PORT_FORWARD_PORT%:8000' -RedirectStandardOutput $log -RedirectStandardError $log -PassThru -WindowStyle Hidden;" ^
  "try {" ^
  "  for ($i = 0; $i -lt 20; $i++) {" ^
  "    try {" ^
  "      Invoke-WebRequest -Uri 'http://127.0.0.1:%PORT_FORWARD_PORT%/v3/api-docs/swagger-config' -UseBasicParsing | Out-Null;" ^
  "      Write-Host '';" ^
  "      Write-Host '[runner-check] 게이트웨이 Swagger 응답 확인 완료';" ^
  "      Write-Host 'Swagger URL: http://127.0.0.1:%PORT_FORWARD_PORT%/swagger-ui/index.html';" ^
  "      exit 0;" ^
  "    } catch {" ^
  "      Start-Sleep -Seconds 2;" ^
  "    }" ^
  "  }" ^
  "  Write-Error '게이트웨이 Swagger 확인에 실패했습니다.';" ^
  "  Write-Error '확인 경로: http://127.0.0.1:%PORT_FORWARD_PORT%/v3/api-docs/swagger-config';" ^
  "  exit 1;" ^
  "} finally {" ^
  "  if ($proc -and -not $proc.HasExited) { Stop-Process -Id $proc.Id -Force }" ^
  "}"
exit /b %errorlevel%
