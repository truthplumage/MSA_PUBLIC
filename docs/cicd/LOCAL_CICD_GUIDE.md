# 로컬 CI/CD 정리

이 문서는 외부 서버 없이 내 PC 안에서 자동 빌드와 자동 배포 흐름을 만드는 방법을 정리한 문서입니다.

대상:

- 로컬 Docker
- minikube 또는 kind
- 현재 레포에 있는 `scripts/*.sh`

## 1. 전체 흐름

로컬에서는 보통 아래 흐름으로 자동화를 만듭니다.

1. 코드 변경
2. 빌드
3. 테스트
4. Docker 이미지 생성
5. 로컬 Kubernetes에 반영

한 줄로 보면 아래입니다.

```text
내 PC 코드 변경 -> 로컬 빌드 -> 로컬 이미지 생성 -> minikube 반영
```

## 2. 로컬에서도 CI/CD가 가능한가

가능합니다.

차이점은 이것뿐입니다.

- 외부 서버 CI/CD
  - 다른 서버가 빌드하고 배포
- 로컬 CI/CD
  - 내 PC가 직접 빌드하고 배포

즉 자동 실행 주체만 다릅니다.

## 3. 로컬에서 많이 쓰는 방식

### 3-1. Jenkins를 내 PC에 설치

구조:

1. Jenkins가 Git 변경 감지
2. 빌드 실행
3. Docker 이미지 생성
4. minikube 반영

### 3-2. GitHub Actions self-hosted runner

구조:

1. GitHub Actions가 실행됨
2. 실제 작업은 내 PC에서 수행됨

이 방식은 GitHub UI를 그대로 쓰고 싶을 때 편합니다.

## 4. 이 프로젝트에서 가장 쉬운 구성

지금 레포에서는 아래 구성이 가장 단순합니다.

1. minikube 실행
2. 각 모듈 `scripts` 사용
3. 필요하면 Jenkins 또는 self-hosted runner 연결

추가된 자동화 파일:

- [SELF_HOSTED_RUNNER_GUIDE.md](/Users/parkjinwoo/source/study/grepp_BE2/MSA/docs/cicd/SELF_HOSTED_RUNNER_GUIDE.md)

즉 먼저 아래 스크립트가 기준이 됩니다.

- [config/scripts/all_in_one.sh](/Users/parkjinwoo/source/study/grepp_BE2/MSA/config/scripts/all_in_one.sh)
- [discovery/scripts/all_in_one.sh](/Users/parkjinwoo/source/study/grepp_BE2/MSA/discovery/scripts/all_in_one.sh)
- [apigateway/scripts/all_in_one.sh](/Users/parkjinwoo/source/study/grepp_BE2/MSA/apigateway/scripts/all_in_one.sh)
- [member-service/scripts/all_in_one.sh](/Users/parkjinwoo/source/study/grepp_BE2/member-service/scripts/all_in_one.sh)

그리고 self-hosted runner를 쓰면 아래 스크립트가 전체 순서를 한 번에 실행합니다.

- [local-cicd.sh](/Users/parkjinwoo/source/study/grepp_BE2/MSA/scripts/local/local-cicd.sh)

## 5. 로컬 배포 순서

순서는 아래가 안전합니다.

1. `config-service`
2. `discovery`
3. `apigateway`
4. `member-service`

## 6. 로컬 CI 단계

로컬 CI는 보통 여기까지입니다.

1. 코드 pull
2. 테스트
3. `jar` 생성
4. Docker 이미지 생성

이 레포에서 대응되는 단계:

- `build_jar.sh`
- `build_docker.sh`

## 7. 로컬 CD 단계

로컬 CD는 여기입니다.

1. Kubernetes 리소스 등록
2. Deployment 실행
3. 상태 확인

이 레포에서 대응되는 단계:

- `register_k8s.sh`
- `run_k8s.sh`
- `check_k8s.sh`

## 8. 로컬 자동화에 필요한 것

보통 아래만 있으면 됩니다.

- Docker
- kubectl
- minikube 또는 kind
- JDK
- Git

## 9. 로컬에서 자주 쓰는 자동화 도구

### 1) Jenkins

장점:

- UI가 있음
- 배포 이력 보기 쉬움

### 2) GitHub Actions self-hosted runner

장점:

- GitHub와 연결 쉬움
- 워크플로 파일을 그대로 저장소에 둘 수 있음

이 레포에서는 아래 파일이 그 역할을 합니다.

- [local-cicd.yml](/Users/parkjinwoo/source/study/grepp_BE2/.github/workflows/local-cicd.yml)

### 3) 단순 쉘 스크립트

장점:

- 제일 빠르게 시작 가능
- 지금 레포 구조와 바로 맞음

## 11. local 전용으로 볼 포인트

### 1) `minikube image load`

의미:

- 내 PC에서 만든 이미지를 minikube가 보게 만드는 작업

### 2) `member-service-secrets`

주의:

- JWT 키를 매번 새로 만들면 기존 토큰이 무효화됨
- 한 번 만든 시크릿을 계속 재사용해야 함

### 3) 포트 충돌

주의:

- 로컬 실행과 Kubernetes 실행을 같이 하면 `8000`, `8080`, `8081`, `8761`, `8888` 충돌 가능

## 12. 추천 시작 순서

로컬에서는 아래 순서가 가장 깔끔합니다.

1. 수동으로 스크립트 실행 성공
2. `all_in_one.sh`로 묶기
3. Jenkins 또는 self-hosted runner 연결

즉 아래 순서입니다.

```text
수동 실행 성공 -> 스크립트 고정 -> 자동 실행 연결
```

## 13. 마지막 확인

배포가 끝나면 아래로 확인하면 됩니다.

```bash
kubectl -n msa get pods,svc
kubectl -n msa port-forward svc/apigateway 8000:8000
```

브라우저:

```text
http://localhost:8000/swagger-ui/index.html
```

여기서 서비스가 보이면 로컬 자동배포 흐름은 정상입니다.
