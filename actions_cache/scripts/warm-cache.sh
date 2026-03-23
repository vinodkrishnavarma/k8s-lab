#!/usr/bin/env bash
# warm-cache.sh – downloads action archives and populates the action archive cache.
#
# Required env vars:
#   ACTIONS_RUNNER_ACTION_ARCHIVE_CACHE  – target directory (mounted PVC path)
#   ACTIONS_LIST_FILE                    – path to the newline-delimited list of
#                                          owner/repo entries to cache
#
# Proxy env vars (HTTP_PROXY / HTTPS_PROXY / NO_PROXY) should be set by the
# calling environment (runner pod or CronJob container spec).
set -euo pipefail

CACHE_DIR="${ACTIONS_RUNNER_ACTION_ARCHIVE_CACHE:-/home/runner/action-archive-cache}"
ACTIONS_LIST="${ACTIONS_LIST_FILE:-/warmer/actions-list.txt}"
WORK_DIR=$(mktemp -d)

cleanup() { rm -rf "${WORK_DIR}"; }
trap cleanup EXIT

echo "[warmer] ============================================================="
echo "[warmer] Cache target : ${CACHE_DIR}"
echo "[warmer] Actions list : ${ACTIONS_LIST}"
echo "[warmer] Work dir     : ${WORK_DIR}"
echo "[warmer] ============================================================="

mkdir -p "${CACHE_DIR}"
cd "${WORK_DIR}"

# ── Download the action-versions helper scripts from github.com ───────────────
echo "[warmer] Downloading action-versions scripts ..."
curl -fsSL -o action-versions.zip \
    https://github.com/actions/action-versions/archive/refs/heads/main.zip
unzip -q action-versions.zip
cd action-versions-main/script

# ── Register / update each action from the list ──────────────────────────────
echo "[warmer] Processing actions list ..."
while IFS= read -r action || [[ -n "${action}" ]]; do
    # skip blank lines and comments
    [[ "${action}" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${action//[[:space:]]/}" ]]  && continue

    echo "[warmer]   -> ${action}"
    # add-action.sh exits non-zero when action already exists; fall back to update.
    if ! ./add-action.sh "${action}" 2>/dev/null; then
        ./update-action.sh "${action}"
    fi
done < "${ACTIONS_LIST}"

# ── Build the tarball archives (.tar.gz per SHA) ──────────────────────────────
echo "[warmer] Building archive cache (downloading SHAs from GitHub API) ..."
./build.sh

# ── Atomically sync to the PVC-backed cache directory ─────────────────────────
TARBALL_DIR="${WORK_DIR}/action-versions-main/_layout_tarball"
echo "[warmer] Syncing ${TARBALL_DIR} -> ${CACHE_DIR} ..."
rsync -a --delete "${TARBALL_DIR}/" "${CACHE_DIR}/"

echo "[warmer] ✓ Cache warm complete."
echo "[warmer] Cache size: $(du -sh "${CACHE_DIR}" | cut -f1)"
echo "[warmer] Cached actions:"
ls "${CACHE_DIR}"
