#!/usr/bin/env bash
set -euo pipefail

# config-service를 한 번에 처리한다.
# 순서:
# 1) jar 생성
# 2) Docker 이미지 생성
# 3) 쿠버네티스 리소스 등록
# 4) 쿠버네티스 실행
# 5) 상태 확인

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "[config] 1/5 jar 생성"
./build_jar.sh

echo "[config] 2/5 도커 이미지 생성"
./build_docker.sh

echo "[config] 3/5 쿠버네티스 리소스 등록"
./register_k8s.sh

echo "[config] 4/5 쿠버네티스 실행"
./run_k8s.sh

echo "[config] 5/5 상태 확인"
./check_k8s.sh
