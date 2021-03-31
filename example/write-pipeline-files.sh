#!/usr/bin/env bash

cd "$(git rev-parse --show-toplevel)"
set -euxo pipefail

OUTPUT_DIR="${OUTPUT_DIR:-".buildkite"}"
SCRIPTS_DIR="${OUTPUT_DIR}/image-updater"

rm -rf "${SCRIPTS_DIR}" || true
mkdir -p "${SCRIPTS_DIR}"

# write scripts
echo "(./example/image-updater-pipeline.dhall).Scripts" | dhall to-directory-tree --output "${SCRIPTS_DIR}"
fd --extension "sh" . "${SCRIPTS_DIR}" --exec chmod +x '{}'

# write buildkite pipeline
dhall-to-yaml --generated-comment --file=./example/pipeline.dhall --output="${OUTPUT_DIR}/pipeline.yaml"

# format
yarn
yarn prettier
