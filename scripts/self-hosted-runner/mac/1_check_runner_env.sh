#!/usr/bin/env bash
set -euo pipefail

# self-hosted runner 장비에서 필요한 도구가 준비됐는지 확인한다.
# 등록 전에 한 번, 장애가 날 때 한 번 보면 된다.

# 공통 변수와 공통 함수를 불러온다.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# runner 장비에서 실제로 쓰는 도구들이 모두 있어야 한다.
for cmd in git java docker kubectl minikube curl bash; do
  require_cmd "${cmd}"
done

echo "[runner-check] 도구 버전 확인"
git --version
java -version
docker --version
kubectl version --client
minikube version
curl --version | head -n 1

echo
echo "[runner-check] 로컬 실행 상태 확인"
# Docker, minikube, kubectl이 실제로 동작하는지 같이 확인한다.
docker ps >/dev/null
minikube status
kubectl get ns >/dev/null

echo
echo "[runner-check] 준비 확인 완료"
echo "작업 루트: ${WORKSPACE_ROOT}"
