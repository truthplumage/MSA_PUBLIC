# 클라우드 이미지 CI/CD 정리

이 문서는 외부 클라우드 서버가 아직 없어도
GitHub Actions로 Docker 이미지를 자동 생성해서 레지스트리까지 올리는 흐름을 정리한 문서입니다.

대상:

- `config-service`
- `discovery`
- `apigateway`

`member-service`는 현재 별도 Git 저장소라서 이 문서의 workflow에는 포함하지 않습니다.

## 1. 전체 흐름

지금 기준 흐름은 아래와 같습니다.

1. GitHub에 코드 푸시
2. GitHub Actions 실행
3. 각 모듈 `jar` 빌드
4. Docker 이미지 생성
5. GHCR로 push

한 줄로 보면 아래 구조입니다.

```text
개발자 -> GitHub push -> GitHub Actions -> Docker Registry
```

## 2. 준비할 것

필요한 것은 2가지입니다.

- Git 저장소
- Docker 이미지 저장소
  - 여기서는 GHCR 사용

## 3. 가장 단순한 권장 구조

이 프로젝트에서는 아래 구조가 가장 단순합니다.

1. GitHub Actions 사용
2. 이미지 저장소는 GHCR 사용
3. 서버 배포는 나중에 추가

즉:

```text
GitHub Actions
-> Docker 이미지 빌드
-> GHCR push
```

## 4. 지금 저장소에 들어 있는 workflow

실제 workflow 파일:

- [image-registry-cicd.yml](/Users/parkjinwoo/source/study/grepp_BE2/MSA/.github/workflows/image-registry-cicd.yml)

이 workflow가 하는 일:

1. 코드 체크아웃
2. JDK 17 설정
3. `config`, `discovery`, `apigateway` 각각 `jar` 생성
4. Docker 이미지 생성
5. GHCR로 push

## 5. GitHub Secrets에 넣을 값

GHCR를 쓰면 별도 `REGISTRY_USERNAME`, `REGISTRY_PASSWORD` 없이도
기본 `GITHUB_TOKEN`으로 push 할 수 있습니다.

즉 지금 workflow 기준으로 필수 시크릿은 없습니다.

대신 workflow 권한은 아래가 필요합니다.

- `contents: read`
- `packages: write`

## 6. 어떤 이미지가 올라가나

이미지 경로는 아래 형식입니다.

```text
ghcr.io/<github-owner>/config:<commit-sha-7자리>
ghcr.io/<github-owner>/discovery:<commit-sha-7자리>
ghcr.io/<github-owner>/apigateway:<commit-sha-7자리>
```

예:

```text
ghcr.io/parkjinwoo/config:a1b2c3d
```

## 7. CI 단계에서 하는 일

CI는 여기까지입니다.

1. 코드 체크아웃
2. JDK 세팅
3. `jar` 빌드
4. Docker 이미지 빌드
5. 이미지 push

이 프로젝트 기준으로는 각 모듈의 아래 스크립트를 재사용합니다.

- `scripts/build_jar.sh`
- `scripts/build_docker.sh`

## 8. 나중에 서버가 생기면 추가할 것

서버가 생기면 그때 아래 단계만 뒤에 붙이면 됩니다.

1. 서버 또는 Kubernetes 접속 정보 추가
2. `docker pull` 또는 `kubectl set image`
3. 롤아웃 확인

즉 지금은 CI만 만들고, CD는 나중에 붙이는 구조입니다.

## 9. 추천 workflow 구조

파일 위치:

```text
MSA/.github/workflows/image-registry-cicd.yml
```

단계:

1. `main` 또는 `master` 브랜치 push 감지
2. Gradle 빌드
3. GHCR 로그인
4. 이미지 build/push

## 10. 실행 전에 확인할 것

- 저장소 `Settings -> Actions -> General`에서 패키지 권한이 막혀 있지 않은지
- GHCR 패키지 생성 권한이 있는지
- 각 모듈의 Dockerfile이 정상인지
- 각 모듈 `scripts/build_jar.sh`, `scripts/build_docker.sh`가 로컬에서 먼저 성공하는지

## 11. 가장 많이 막히는 부분

### 1) 이미지 push 실패

원인:

- 패키지 권한 부족
- GHCR 로그인 문제
- owner 이름 대소문자 문제

### 2) 특정 모듈 빌드 실패

원인:

- `jar` 빌드 실패
- Dockerfile과 jar 파일 이름 불일치
- Gradle wrapper 권한 문제

## 12. 추천 시작 방식

처음 구성할 때는 아래 순서가 가장 안정적입니다.

1. 먼저 로컬에서 이미지 생성 성공
2. 그 다음 GitHub Actions로 이미지 push 자동화
3. 마지막에 서버가 생기면 배포 단계 추가

즉:

```text
로컬 이미지 생성 성공 -> GitHub CI 자동화 -> 서버 배포 추가
```
