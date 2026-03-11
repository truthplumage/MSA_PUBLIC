# Self-hosted Runner 스크립트 정리

운영체제별로 폴더를 나눴습니다.

## mac

1. `mac/1_check_runner_env.sh`
2. `mac/2_run_local_cicd.sh`
3. `mac/3_check_local_cicd.sh`
4. `mac/common.sh`

## windows

1. `windows/1_check_runner_env.bat`
2. `windows/2_run_local_cicd.bat`
3. `windows/3_check_local_cicd.bat`
4. `windows/common.bat`

공통 순서는 같습니다.

1. runner 장비 준비 상태 확인
2. 로컬 배포 실행
3. 배포 상태 확인

Windows 배치 파일은 `docker`, `kubectl`, `minikube`, `powershell`을 직접 사용합니다.

`windows/2_run_local_cicd.bat`는 기존 모듈별 `all_in_one.sh`를 재사용하므로
Git Bash의 `bash.exe`가 PATH에 잡혀 있어야 합니다.
