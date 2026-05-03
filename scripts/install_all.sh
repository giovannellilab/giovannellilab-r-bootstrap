#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "${ROOT_DIR}/scripts/install_system_ubuntu.sh"
Rscript "${ROOT_DIR}/install.R"
Rscript "${ROOT_DIR}/check_install.R"
