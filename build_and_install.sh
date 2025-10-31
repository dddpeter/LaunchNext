#!/bin/bash

# -------------------------------------------------------------
# 构建并安装 LaunchNext.app 到当前用户的 ~/Applications 目录
# -------------------------------------------------------------
# 依赖：
#   - Xcode 15+ (含 xcodebuild)
#   - macOS 14+
#
# 用法：
#   ./build_and_install.sh [Release|Debug]
# -------------------------------------------------------------

set -euo pipefail

function usage() {
  local script_name
  script_name=$(basename "$0")
  cat <<EOF
用法：
  ${script_name} [Release|Debug]

说明：
  - 默认使用 Release 构建配置。
  - 构建输出将复制到 ~/Applications/LaunchNext.app。
EOF
}

function terminate_running_app() {
  local bundle_name="LaunchNext"

  if pgrep -x "${bundle_name}" >/dev/null 2>&1; then
    echo "⏹️  正在尝试关闭已运行的 ${bundle_name}"
    osascript -e "tell application \"${bundle_name}\" to quit" >/dev/null 2>&1 || true

    local attempts=0
    local max_attempts=10
    while pgrep -x "${bundle_name}" >/dev/null 2>&1 && [[ ${attempts} -lt ${max_attempts} ]]; do
      sleep 0.5
      attempts=$((attempts + 1))
    done

    if pgrep -x "${bundle_name}" >/dev/null 2>&1; then
      echo "⚠️  应用未在预期时间内退出，尝试强制终止"
      pkill -x "${bundle_name}" >/dev/null 2>&1 || true
    fi
  fi
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

CONFIGURATION=${1:-Release}

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_PATH="${SCRIPT_DIR}/LaunchNext.xcodeproj"
SCHEME="LaunchNext"
DERIVED_DATA_PATH="${SCRIPT_DIR}/build"
BUILD_OUTPUT="${DERIVED_DATA_PATH}/Build/Products/${CONFIGURATION}/LaunchNext.app"
DEST_DIR="${HOME}/Applications"
DEST_PATH="${DEST_DIR}/LaunchNext.app"

echo "➡️  使用配置：${CONFIGURATION}"
echo "➡️  项目路径：${PROJECT_PATH}"
echo "➡️  构建目录：${DERIVED_DATA_PATH}"

if [[ ! -d "${PROJECT_PATH}" ]]; then
  echo "❌ 未找到 Xcode 项目：${PROJECT_PATH}" >&2
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "❌ 未检测到 xcodebuild，请安装 Xcode 命令行工具。" >&2
  exit 1
fi

echo "🏗️  正在构建 LaunchNext (${CONFIGURATION})..."
if command -v xcpretty >/dev/null 2>&1; then
  xcodebuild \
    -project "${PROJECT_PATH}" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    clean build | xcpretty
else
  xcodebuild \
    -project "${PROJECT_PATH}" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    clean build
fi

if [[ ! -d "${BUILD_OUTPUT}" ]]; then
  echo "❌ 未找到构建产物：${BUILD_OUTPUT}" >&2
  exit 1
fi

terminate_running_app

mkdir -p "${DEST_DIR}"

if [[ -d "${DEST_PATH}" ]]; then
  echo "🧹 移除现有的 ${DEST_PATH}"
  rm -rf "${DEST_PATH}"
fi

echo "📦 拷贝 LaunchNext.app 到 ${DEST_PATH}"
cp -R "${BUILD_OUTPUT}" "${DEST_PATH}"

echo "✅ 安装完成：${DEST_PATH}"


