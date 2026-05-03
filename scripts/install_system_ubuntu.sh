#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APT_LIST="${ROOT_DIR}/packages/system_apt.txt"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found. This installer is intended for Ubuntu/Debian systems." >&2
  exit 1
fi

mapfile -t APT_PACKAGES < <(sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "${APT_LIST}" | awk 'NF')

if [ "${#APT_PACKAGES[@]}" -eq 0 ]; then
  echo "No apt packages listed in ${APT_LIST}"
  exit 0
fi

sudo apt-get update
sudo apt-get install -y "${APT_PACKAGES[@]}"
