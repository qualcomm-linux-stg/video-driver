#!/usr/bin/env bash
set -euo pipefail

VIDEO_DRIVER_DIR="${1:-$(pwd)}"
META_QCOM_DIR="${2:-$(dirname "$VIDEO_DRIVER_DIR")/meta-qcom}"
PR_REPO="${3:-}"

RECIPE_PATH="${META_QCOM_DIR}/recipes-kernel/iris-video-module/iris-video-dlkm_git.bb"
DEFAULT_REPO="qualcomm-linux/video-driver"

echo "VIDEO_DRIVER_DIR=${VIDEO_DRIVER_DIR}"
echo "META_QCOM_DIR=${META_QCOM_DIR}"
echo "PR_REPO=${PR_REPO:-<empty>}"
echo "RECIPE_PATH=${RECIPE_PATH}"

if [ ! -d "${VIDEO_DRIVER_DIR}/.git" ]; then
  echo "❌ video-driver repo not found: ${VIDEO_DRIVER_DIR}"
  exit 1
fi

if [ ! -f "${RECIPE_PATH}" ]; then
  echo "❌ Recipe file not found: ${RECIPE_PATH}"
  exit 1
fi

VIDEO_DRIVER_SHA=$(git -C "${VIDEO_DRIVER_DIR}" rev-parse HEAD)
echo "✅ Using video-driver SHA: ${VIDEO_DRIVER_SHA}"

if grep -q '^[[:space:]]*SRCREV[[:space:]]*=' "${RECIPE_PATH}"; then
  sed -i -E "s|^[[:space:]]*SRCREV[[:space:]]*=.*$|SRCREV = \"${VIDEO_DRIVER_SHA}\"|" "${RECIPE_PATH}"
else
  echo "SRCREV = \"${VIDEO_DRIVER_SHA}\"" >> "${RECIPE_PATH}"
fi

if [ -n "${PR_REPO}" ] && [ "${PR_REPO}" != "${DEFAULT_REPO}" ]; then
  echo "🔁 PR repo differs from default repo, patching SRC_URI to ${PR_REPO}"

  perl -0pi -e 's#(SRC_URI\s*=\s*")[^"]*github\.com/[^";]+#${1}git://github.com/'"${PR_REPO}"'#g' "${RECIPE_PATH}"
else
  echo "ℹ️ SRC_URI patch not needed"
fi

echo "=== Patched recipe preview ==="
grep -nE 'SRC_URI|SRCREV' "${RECIPE_PATH}" || true