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

PIPELINES="(./example/pipeline.dhall).Pipelines"

# write image-updater pipeline
echo "${PIPELINES}.ImageUpdater" | dhall-to-yaml --generated-comment --output="${OUTPUT_DIR}/pipeline.yaml"

CRON_IMAGES=(
  "gitserver"
  "indexed-search"
)

# write all cron-tag pipelines
for IMAGE in "${CRON_IMAGES[@]}"; do
  echo "${PIPELINES}.CronTagGenerator \"${IMAGE}\"" | dhall-to-yaml --generated-comment --output="${OUTPUT_DIR}/cron-tag-${IMAGE}.pipeline.yaml"
done

# format
yarn
yarn prettier
