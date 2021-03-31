#!/usr/bin/env bash

cd "$(git rev-parse --show-toplevel)"
set -euxo pipefail

export OUTPUT_DIR="${OUTPUT_DIR:-".buildkite/image-updater"}"
export SCRIPTS_DIR="${OUTPUT_DIR}/scripts"

rm -rf "${OUTPUT_DIR}" || true
mkdir -p "${SCRIPTS_DIR}"

# write scripts
echo "(./example/pipeline.dhall).Scripts" | dhall to-directory-tree --output "${SCRIPTS_DIR}"
fd --extension "sh" . "${SCRIPTS_DIR}" --exec chmod +x '{}'

# write buildkite pipeline
echo "(./example/pipeline.dhall).Pipeline" | dhall-to-yaml --generated-comment --output="${OUTPUT_DIR}/pipeline.yaml"

# format
yarn
yarn prettier
