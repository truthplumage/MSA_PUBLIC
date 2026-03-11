# Jenkins 로컬 자동배포 정리

이 문서는 내 PC 또는 내부 서버에 Jenkins를 설치해서 이 프로젝트를 자동 실행하는 흐름을 정리한 문서입니다.

## 1. Jenkins를 왜 쓰나

Jenkins를 쓰면 아래를 한 화면에서 볼 수 있습니다.

- 빌드 실행
- 배포 실행
- 성공/실패 기록
- 콘솔 로그

## 2. 어디에 설치하나

보통 아래 둘 중 하나입니다.

- minikube가 돌아가는 내 PC
- 항상 켜져 있는 내부 개발 서버

지금 구조에서는 minikube가 있는 같은 장비에 두는 것이 가장 단순합니다.

## 3. 같이 있어야 하는 것

Jenkins가 실행되는 장비 안에 아래도 있어야 합니다.

- Git
- JDK
- Docker
- kubectl
- minikube
- curl

## 4. Jenkins가 실행할 파일

가장 단순한 기준은 이 스크립트입니다.

- [4_run_local_deploy.sh](/Users/parkjinwoo/source/study/grepp_BE2/MSA/scripts/jenkins/4_run_local_deploy.sh)

이 스크립트가 하는 일:

1. minikube 시작
2. `config-service` 배포
3. `discovery` 배포
4. `apigateway` 배포
5. `member-service` 배포

Swagger 응답 확인은 아래 스크립트로 분리했습니다.

- [5_check_local_deploy.sh](/Users/parkjinwoo/source/study/grepp_BE2/MSA/scripts/jenkins/5_check_local_deploy.sh)

같이 보면 좋은 파일:

- [README.md](/Users/parkjinwoo/source/study/grepp_BE2/MSA/scripts/jenkins/README.md)
- [1_install_jenkins.sh](/Users/parkjinwoo/source/study/grepp_BE2/MSA/scripts/jenkins/1_install_jenkins.sh)
- [2_start_jenkins.sh](/Users/parkjinwoo/source/study/grepp_BE2/MSA/scripts/jenkins/2_start_jenkins.sh)
- [3_show_admin_password.sh](/Users/parkjinwoo/source/study/grepp_BE2/MSA/scripts/jenkins/3_show_admin_password.sh)
- [5_check_local_deploy.sh](/Users/parkjinwoo/source/study/grepp_BE2/MSA/scripts/jenkins/5_check_local_deploy.sh)
- [6_stop_jenkins.sh](/Users/parkjinwoo/source/study/grepp_BE2/MSA/scripts/jenkins/6_stop_jenkins.sh)

## 5. Jenkins Job은 뭘 쓰나

가장 단순한 방식은 `Pipeline` Job입니다.

흐름:

1. 저장소 checkout
2. 쉘 실행
3. `4_run_local_deploy.sh` 호출

## 6. 가장 단순한 실행 명령

```bash
cd /Users/parkjinwoo/source/study/grepp_BE2
IMAGE_REGISTRY=local IMAGE_TAG=jenkins-${BUILD_NUMBER} ./MSA/scripts/jenkins/4_run_local_deploy.sh
```

## 7. Jenkins에 넣을 값

필요한 값:

- `TOKEN_MAKER`
- `TOKEN_PRIVATE`
- `TOKEN_PUBLIC`

이 값은 Jenkins Credentials 또는 환경변수로 넣는 것이 안전합니다.

## 8. 추천 순서

1. 터미널에서 `4_run_local_deploy.sh` 수동 성공
2. Jenkins에서 `4_run_local_deploy.sh` 실행
3. Git push 후 자동 실행 연결

## 9. 자주 막히는 부분

### 1) Docker 명령 실패

원인:

- Jenkins 실행 계정에 Docker 권한이 없음

### 2) kubectl 실패

원인:

- Jenkins 계정이 kubeconfig를 못 읽음

### 3) member-service만 실패

원인:

- `TOKEN_*` 누락
- 기존 시크릿 없음

## 10. 한 줄 정리

```text
Jenkins가 4_run_local_deploy.sh를 대신 실행해주는 구조
```
