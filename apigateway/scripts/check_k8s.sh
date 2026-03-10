#!/usr/bin/env bash
set -euo pipefail

# apigateway 상태를 한 번에 확인한다.

NAMESPACE="${NAMESPACE:-msa}"

echo "[apigateway] 디플로이먼트 상태"
kubectl -n "${NAMESPACE}" get deployment apigateway

echo
echo "[apigateway] 파드 상태"
kubectl -n "${NAMESPACE}" get pods -l app.kubernetes.io/name=apigateway -o wide

echo
echo "[apigateway] 서비스 상태"
kubectl -n "${NAMESPACE}" get svc apigateway

echo
echo "[apigateway] 로그 확인 예시"
echo "kubectl -n ${NAMESPACE} logs deploy/apigateway"
echo "kubectl -n ${NAMESPACE} port-forward svc/apigateway 8000:8000"
echo "http://localhost:8000/swagger-ui/index.html"
