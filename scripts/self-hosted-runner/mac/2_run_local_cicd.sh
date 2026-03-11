#!/usr/bin/env bash
set -euo pipefail

# self-hosted runner에서 호출할 로컬 배포 스크립트
# 순서:
# 1) minikube 시작
# 2) config-service 배포
# 3) discovery 배포
# 4) apigateway 배포
# 5) member-service 배포

# 공통 변수와 공통 함수를 불러온다.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# 이 스크립트는 minikube, kubectl, docker를 모두 사용한다.
for cmd in minikube kubectl docker bash; do
  require_cmd "${cmd}"
done

echo "[runner-deploy] minikube 시작"
# 로컬 Kubernetes 클러스터가 꺼져 있으면 먼저 올린다.
minikube start --driver="${MINIKUBE_DRIVER}"

# 의존 순서대로 인프라를 먼저 올리고 마지막에 member-service를 올린다.
run_module "${MSA_DIR}/config" "config-service"
run_module "${MSA_DIR}/discovery" "discovery"
run_module "${MSA_DIR}/apigateway" "apigateway"
run_module "${MEMBER_DIR}" "member-service"

echo
echo "[runner-deploy] 배포 완료"
# 실제 상태와 Swagger 확인은 다음 스크립트로 분리했다.
echo "상태 확인은 3_check_local_cicd.sh로 진행하세요."
