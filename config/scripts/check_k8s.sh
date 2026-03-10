#!/usr/bin/env bash
set -euo pipefail

# config-service 상태를 한 번에 확인한다.

NAMESPACE="${NAMESPACE:-msa}"

echo "[config] 디플로이먼트 상태"
kubectl -n "${NAMESPACE}" get deployment config-service

echo
echo "[config] 파드 상태"
kubectl -n "${NAMESPACE}" get pods -l app=config-service -o wide

echo
echo "[config] 서비스 상태"
kubectl -n "${NAMESPACE}" get svc config-service

echo
echo "[config] 로그 확인 예시"
echo "kubectl -n ${NAMESPACE} logs deploy/config-service"
