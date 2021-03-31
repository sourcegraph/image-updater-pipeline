all: check freeze format lint build

build: render-ci-pipeline render-buildkite

render-ci-pipeline:
    ./scripts/render-ci-pipeline.sh

render-buildkite:
    ./example/write-pipeline-files.sh

format: format-dhall prettier format-shfmt

lint: lint-dhall shellcheck

freeze: freeze-dhall

check: check-dhall

prettier:
    yarn run prettier

freeze-dhall:
    ./scripts/dhall-freeze.sh

check-dhall:
    ./scripts/dhall-check.sh

format-dhall:
    ./scripts/dhall-format.sh

lint-dhall:
    ./scripts/dhall-lint.sh

shellcheck:
    ./scripts/shellcheck.sh

format-shfmt:
    shfmt -w .

install:
    just install-asdf
    just install-yarn

install-yarn:
    yarn

install-asdf:
    asdf install
