@echo off

rem 공통으로 쓰는 경로와 기본값을 한 곳에 모아 둔 파일이다.
rem 다른 self-hosted runner 배치 파일들은 이 파일을 먼저 호출해서 같은 값을 재사용한다.

rem 현재 배치 파일이 있는 폴더 경로를 구한다.
set "SCRIPT_DIR=%~dp0"

rem 작업 루트는 `MSA`, `member-service`가 같이 있는 폴더다.
for %%I in ("%SCRIPT_DIR%..\..\..") do set "WORKSPACE_ROOT=%%~fI"

rem 공통 인프라 모듈이 있는 MSA 폴더
for %%I in ("%WORKSPACE_ROOT%\MSA") do set "MSA_DIR=%%~fI"

rem member-service 모듈 폴더
for %%I in ("%WORKSPACE_ROOT%\member-service") do set "MEMBER_DIR=%%~fI"

rem Docker 이미지 이름 앞부분
if not defined IMAGE_REGISTRY set "IMAGE_REGISTRY=local"

rem 이미지 태그를 따로 주지 않으면 runner-local을 기본값으로 사용한다.
if not defined IMAGE_TAG set "IMAGE_TAG=runner-local"

rem Kubernetes 네임스페이스
if not defined NAMESPACE set "NAMESPACE=msa"

rem true면 이미지를 minikube에 적재한다.
if not defined LOAD_TO_MINIKUBE set "LOAD_TO_MINIKUBE=true"

rem minikube가 사용할 드라이버
if not defined MINIKUBE_DRIVER set "MINIKUBE_DRIVER=docker"

rem true면 배포 확인 시 Swagger 응답까지 검사한다.
if not defined CHECK_SWAGGER set "CHECK_SWAGGER=true"

rem port-forward에 잠깐 사용할 로컬 포트
if not defined PORT_FORWARD_PORT set "PORT_FORWARD_PORT=18000"

rem Git Bash에서 쓰기 쉽게 경로 구분자를 슬래시로 바꾼 값도 함께 만든다.
set "MSA_DIR_BASH=%MSA_DIR:\=/%"
set "MEMBER_DIR_BASH=%MEMBER_DIR:\=/%"
set "WORKSPACE_ROOT_BASH=%WORKSPACE_ROOT:\=/%"

exit /b 0
