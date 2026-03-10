#!/usr/bin/env bash
set -euo pipefail

# 현재 모듈(apigateway)의 jar를 이용해 Docker 이미지만 만든다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${MODULE_DIR}"

IMAGE_REGISTRY="${IMAGE_REGISTRY:-local}"
IMAGE_NAME="${IMAGE_NAME:-apigateway}"
IMAGE_TAG="${IMAGE_TAG:-dev}"
LOAD_TO_MINIKUBE="${LOAD_TO_MINIKUBE:-false}"
PUSH_IMAGE="${PUSH_IMAGE:-false}"
IMAGE="${IMAGE_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

if [[ ! -d build/libs ]]; then
  echo "build/libs 가 없습니다. 먼저 ./scripts/build_jar.sh 를 실행하세요." >&2
  exit 1
fi

JAR_PATH="$(find build/libs -maxdepth 1 -type f -name '*.jar' ! -name '*plain.jar' | head -n 1)"
if [[ -z "${JAR_PATH}" ]]; then
  echo "실행용 jar 파일이 없습니다. 먼저 ./scripts/build_jar.sh 를 실행하세요." >&2
  exit 1
fi

echo "[apigateway] 도커 이미지 빌드 시작: ${IMAGE}"
docker build -t "${IMAGE}" .

if [[ "${LOAD_TO_MINIKUBE}" == "true" ]]; then
  echo "[apigateway] minikube에 이미지 적재: ${IMAGE}"
  minikube image load "${IMAGE}"
fi

if [[ "${PUSH_IMAGE}" == "true" ]]; then
  echo "[apigateway] 원격 레지스트리로 이미지 푸시: ${IMAGE}"
  docker push "${IMAGE}"
fi

echo "[apigateway] 도커 이미지 생성 완료: ${IMAGE}"
