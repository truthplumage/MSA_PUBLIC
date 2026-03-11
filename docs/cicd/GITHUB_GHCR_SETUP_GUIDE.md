# GitHub Actions, GHCR 설정 순서

이 문서는 `MSA/.github/workflows/image-registry-cicd.yml`를 실행하기 전에
GitHub에서 먼저 확인해야 하는 내용을 순서대로 정리한 문서입니다.

대상:

- `MSA` 저장소
- GitHub Actions
- GHCR

## 1. 먼저 알아둘 점

지금 workflow는 다음까지만 합니다.

1. 코드 체크아웃
2. `jar` 빌드
3. Docker 이미지 생성
4. GHCR push

즉 지금 당장 필요한 것은:

- GitHub Actions가 실행 가능해야 함
- GHCR에 이미지 push 권한이 있어야 함

서버 배포 설정은 아직 필요 없습니다.

## 2. 저장소에 workflow 파일이 들어 있는지 확인

먼저 아래 파일이 `MSA` 저장소 안에 있어야 합니다.

- [image-registry-cicd.yml](/Users/parkjinwoo/source/study/grepp_BE2/MSA/.github/workflows/image-registry-cicd.yml)

그리고 이 파일을 GitHub에 push 해야
GitHub Actions 화면에서 workflow가 보입니다.

## 3. GitHub Actions가 막혀 있지 않은지 확인

GitHub에서 아래 순서로 들어갑니다.

1. `MSA` 저장소 열기
2. `Settings`
3. `Actions`
4. `General`

여기서 확인할 것:

- Actions 실행이 허용되어 있는지
- workflow 실행이 막혀 있지 않은지

보통 저장소에서 Actions를 전혀 막아두지 않았다면 그대로 써도 됩니다.

## 4. workflow 권한 확인

지금 workflow는 `GITHUB_TOKEN`으로 GHCR에 push 합니다.

그래서 workflow 안에 아래 권한이 있어야 합니다.

```yaml
permissions:
  contents: read
  packages: write
```

이 부분은 이미 workflow에 들어 있습니다.

확인 파일:

- [image-registry-cicd.yml](/Users/parkjinwoo/source/study/grepp_BE2/MSA/.github/workflows/image-registry-cicd.yml)

의미:

- `contents: read`
  - 저장소 코드를 checkout 할 때 필요
- `packages: write`
  - GHCR에 이미지를 올릴 때 필요

## 5. GHCR에 이미지가 올라갈 수 있는지 확인

현재 workflow는 아래 방식으로 로그인합니다.

```yaml
uses: docker/login-action@v3
with:
  registry: ghcr.io
  username: ${{ github.actor }}
  password: ${{ secrets.GITHUB_TOKEN }}
```

즉:

- 별도 Docker Hub 아이디/비밀번호를 넣는 구조가 아님
- GitHub가 자동으로 주는 `GITHUB_TOKEN`으로 GHCR push

그래서 먼저 볼 것은 시크릿이 아니라 권한입니다.

## 6. 첫 실행 방법

가장 쉬운 방법은 수동 실행입니다.

1. `MSA` 저장소 열기
2. `Actions`
3. `image-registry-cicd` 선택
4. `Run workflow` 클릭
5. 실행 로그 확인

이렇게 하면 권한 문제인지, 빌드 문제인지 바로 구분하기 쉽습니다.

## 7. 실행 후 어디서 결과를 보나

성공하면 아래 두 군데에서 확인할 수 있습니다.

### 1) GitHub Actions 실행 로그

마지막 단계에서 이런 형식으로 이미지 경로가 출력됩니다.

```text
ghcr.io/<github-owner>/config:<sha7>
ghcr.io/<github-owner>/discovery:<sha7>
ghcr.io/<github-owner>/apigateway:<sha7>
```

### 2) GitHub Packages 화면

GitHub에서 아래 순서로 봅니다.

1. GitHub 프로필 또는 조직 페이지
2. `Packages`
3. 방금 올라간 `config`, `discovery`, `apigateway` 이미지 확인

## 8. 가장 자주 막히는 부분

### 1) workflow는 도는데 push 단계에서 실패

보통 원인:

- `packages: write` 권한 부족
- 저장소 Actions 정책 제한
- GHCR 패키지 생성 권한 문제

### 2) checkout은 되는데 빌드 실패

보통 원인:

- Gradle 빌드 실패
- Dockerfile과 실제 `jar` 결과물 불일치

### 3) workflow 자체가 Actions 화면에 안 보임

보통 원인:

- workflow 파일을 GitHub에 아직 push 안 함
- 파일 위치가 저장소 루트 기준 `.github/workflows`가 아님

## 9. 지금 해야 할 순서

지금은 아래 순서로 진행하면 됩니다.

1. `MSA` 저장소에 workflow 파일 push
2. `Settings -> Actions -> General` 확인
3. `Actions -> image-registry-cicd -> Run workflow`
4. 성공하면 `Packages`에서 이미지 확인

## 10. 참고 문서

아래는 GitHub 공식 문서입니다.

- [Working with the Container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Publishing and installing a package with GitHub Actions](https://docs.github.com/en/actions/use-cases-and-examples/publishing-packages/about-packaging-with-github-actions)

위 문서 기준으로 정리하면:

- workflow에서 `GITHUB_TOKEN`으로 패키지 publish 가능
- 이때 `contents: read`, `packages: write` 권한이 필요
