#!/usr/bin/env bash
set -euo pipefail

# 스크립트가 어느 위치에서 실행되든 현재 모듈 폴더로 이동한다.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${MODULE_DIR}"

echo "[apigateway] bootJar 시작"
./gradlew clean bootJar

# plain.jar가 있다면 제외하고 실제 실행용 jar만 보여준다.
JAR_PATH="$(find build/libs -maxdepth 1 -type f -name '*.jar' ! -name '*plain.jar' | head -n 1)"

if [[ -z "${JAR_PATH}" ]]; then
  echo "[apigateway] jar 파일을 찾지 못했습니다."
  exit 1
fi

echo "[apigateway] jar 생성 완료: ${JAR_PATH}"
