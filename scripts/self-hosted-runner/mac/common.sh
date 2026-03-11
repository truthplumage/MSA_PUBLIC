#!/usr/bin/env bash
set -euo pipefail

# 공통으로 쓰는 경로와 기본값을 한 곳에 모아 둔 파일이다.
# 다른 self-hosted runner 스크립트들은 이 파일을 source 해서 같은 값을 재사용한다.

# 현재 파일 위치를 기준으로 경로를 계산하면
# 어느 폴더에서 실행하든 동일한 경로를 사용할 수 있다.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# `WORKSPACE_ROOT`는 `MSA`, `member-service`가 같이 있는 작업 폴더다.
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
# 공통 인프라 모듈이 있는 MSA 폴더
MSA_DIR="${WORKSPACE_ROOT}/MSA"
# member-service 모듈 폴더
MEMBER_DIR="${WORKSPACE_ROOT}/member-service"

# Docker 이미지 이름 앞부분
IMAGE_REGISTRY="${IMAGE_REGISTRY:-local}"
# GitHub Actions에서 넘겨주지 않으면 현재 시각으로 태그를 만든다.
IMAGE_TAG="${IMAGE_TAG:-runner-$(date +%Y%m%d%H%M%S)}"
# Kubernetes 네임스페이스
NAMESPACE="${NAMESPACE:-msa}"
# true면 이미지를 minikube에 적재한다.
LOAD_TO_MINIKUBE="${LOAD_TO_MINIKUBE:-true}"
# minikube가 사용할 드라이버
MINIKUBE_DRIVER="${MINIKUBE_DRIVER:-docker}"
# true면 배포 확인 시 Swagger 응답까지 검사한다.
CHECK_SWAGGER="${CHECK_SWAGGER:-true}"
# port-forward에 잠깐 사용할 로컬 포트
PORT_FORWARD_PORT="${PORT_FORWARD_PORT:-18000}"

# 스크립트 실행 전에 필요한 명령이 설치돼 있는지 확인한다.
require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "필수 명령을 찾지 못했습니다: $1" >&2
    exit 1
  fi
}

# 배포할 모듈 하나를 지정된 폴더에서 실행한다.
run_module() {
  local module_dir="$1"
  local module_name="$2"

  echo "[runner-deploy] ${module_name} 배포 시작"
  (
    # 대상 모듈 폴더로 이동해서 그 모듈 스크립트를 실행한다.
    cd "${module_dir}"
    # 이미지 태그, 네임스페이스 같은 값은 runner job에서 바꾸기 쉽도록
    # 환경변수로 넘겨준다.
    IMAGE_REGISTRY="${IMAGE_REGISTRY}" \
    IMAGE_TAG="${IMAGE_TAG}" \
    NAMESPACE="${NAMESPACE}" \
    LOAD_TO_MINIKUBE="${LOAD_TO_MINIKUBE}" \
    ./scripts/all_in_one.sh
  )
}
