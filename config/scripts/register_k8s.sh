#!/usr/bin/env bash
set -euo pipefail

# config-service 리소스만 쿠버네티스에 등록한다.
# 실제 실행은 run_k8s.sh 에서 한다.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${MODULE_DIR}"

NAMESPACE="${NAMESPACE:-msa}"

echo "[config] 네임스페이스 준비"
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

echo "[config] Config Server가 읽을 설정 파일을 ConfigMap으로 등록"
kubectl -n "${NAMESPACE}" create configmap config-repo \
  --from-file="${MODULE_DIR}/config" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "[config] 디플로이먼트와 서비스 등록"
kubectl apply -f "${MODULE_DIR}/k8s/config.yaml"

echo "[config] 아직 실행하지 않고 등록만 하도록 replica를 0으로 맞춤"
kubectl -n "${NAMESPACE}" scale deployment/config-service --replicas=0

echo "[config] 쿠버네티스 리소스 등록 완료"
