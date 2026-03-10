#!/usr/bin/env bash
set -euo pipefail

# discovery 상태를 한 번에 확인한다.

NAMESPACE="${NAMESPACE:-msa}"

echo "[discovery] 디플로이먼트 상태"
kubectl -n "${NAMESPACE}" get deployment discovery

echo
echo "[discovery] 파드 상태"
kubectl -n "${NAMESPACE}" get pods -l app=discovery -o wide

echo
echo "[discovery] 서비스 상태"
kubectl -n "${NAMESPACE}" get svc discovery

echo
echo "[discovery] 로그 확인 예시"
echo "kubectl -n ${NAMESPACE} logs deploy/discovery"
