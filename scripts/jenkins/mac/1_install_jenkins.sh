#!/usr/bin/env bash
set -euo pipefail

# Jenkins를 Docker 컨테이너로 설치한다.
# 이 스크립트는 Jenkins 자체와 Jenkins가 사용할 로컬 도구가 포함된 전용 이미지를 먼저 만든다.

# 공통 변수와 공통 함수를 불러온다.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# 설치 전에 Docker만 먼저 있어도 된다.
# kubectl, minikube는 Jenkins 전용 이미지 안에 같이 넣는다.
for cmd in docker; do
  require_cmd "${cmd}"
done

# 같은 이름의 컨테이너가 이미 있으면
# 현재 스크립트 기준 이미지인지 먼저 확인한다.
if container_exists; then
  existing_image="$(docker inspect -f '{{.Config.Image}}' "${JENKINS_CONTAINER}")"

  if [[ "${existing_image}" == "${JENKINS_IMAGE}" ]]; then
    echo "이미 Jenkins 컨테이너가 있습니다: ${JENKINS_CONTAINER}"
    print_jenkins_info
    exit 0
  fi

  echo "기존 Jenkins 컨테이너 구성이 현재 스크립트와 다릅니다."
  echo "기존 이미지: ${existing_image}"
  echo "새 이미지: ${JENKINS_IMAGE}"
  echo "기존 컨테이너를 삭제하고 다시 만듭니다."
  docker rm -f "${JENKINS_CONTAINER}" >/dev/null 2>&1 || true
fi

# Jenkins 설정 파일을 저장할 로컬 폴더를 미리 만든다.
mkdir -p "${JENKINS_HOME_DIR}"

echo "[jenkins] Jenkins 전용 이미지 빌드"
# mac에서는 /usr/local/bin, /opt/homebrew/bin 바이너리를 직접 마운트하면
# Docker Desktop이 경로 공유 오류를 낼 수 있다.
# 그래서 Jenkins 컨테이너 안에 docker, kubectl, minikube를 미리 넣은 이미지를 만든다.
docker build -t "${JENKINS_IMAGE}" -f "${SCRIPT_DIR}/Dockerfile" "${SCRIPT_DIR}"

echo "[jenkins] Jenkins 컨테이너 설치"
# Jenkins를 Docker 컨테이너로 띄운다.
# 주요 포인트:
# - root 계정으로 실행해서 Docker socket, kube 설정 파일 접근을 단순하게 만든다.
# - docker.sock을 마운트해서 컨테이너 안 Jenkins가 바깥 Docker를 제어한다.
# - ~/.kube, ~/.minikube를 마운트해서 host의 Kubernetes 설정을 그대로 쓴다.
# - 작업 폴더 전체를 /workspace로 마운트해서 Jenkins가 같은 소스를 바로 사용한다.
docker run -d \
  --name "${JENKINS_CONTAINER}" \
  --restart unless-stopped \
  -u root \
  -p "${JENKINS_PORT}:8080" \
  -p "${JENKINS_AGENT_PORT}:50000" \
  -v "${JENKINS_HOME_DIR}:/var/jenkins_home" \
  -v "${WORKSPACE_ROOT}:/workspace" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "${HOME}/.kube:/root/.kube" \
  -v "${HOME}/.minikube:/root/.minikube" \
  -w /workspace \
  "${JENKINS_IMAGE}"

echo
echo "[jenkins] 설치 완료"
# 접속 주소와 Jenkins Home 위치를 바로 출력한다.
print_jenkins_info
# 최초 로그인 비밀번호를 바로 확인할 다음 명령도 같이 보여준다.
echo "초기 비밀번호 확인: ./MSA/scripts/jenkins/mac/3_show_admin_password.sh"
