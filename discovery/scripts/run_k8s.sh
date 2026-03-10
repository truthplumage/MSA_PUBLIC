#!/usr/bin/env bash
set -euo pipefail

# 등록된 discovery Deployment에 실제 이미지를 연결하고 실행한다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${MODULE_DIR}"

NAMESPACE="${NAMESPACE:-msa}"
IMAGE_REGISTRY="${IMAGE_REGISTRY:-local}"
IMAGE_NAME="${IMAGE_NAME:-discovery}"
IMAGE_TAG="${IMAGE_TAG:-dev}"
IMAGE="${IMAGE_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "[discovery] 디플로이먼트 이미지 교체"
kubectl -n "${NAMESPACE}" set image deployment/discovery discovery="${IMAGE}"

echo "[discovery] replica를 1로 올려 실행"
kubectl -n "${NAMESPACE}" scale deployment/discovery --replicas=1

echo "[discovery] 롤아웃 상태 확인"
kubectl -n "${NAMESPACE}" rollout status deployment/discovery

echo "[discovery] 실행 완료"
