let List/unpackOptionals =
      https://prelude.dhall-lang.org/v20.1.0/List/unpackOptionals.dhall sha256:0cbaa920f429cf7fc3907f8a9143203fe948883913560e6e1043223e6b3d05e4

let bk = (./imports.dhall).Buildkite

let Steps = bk.Steps

let PR_BRANCH = "update-docker-images/images"

let Config = ./config.dhall

let Pipeline = { Type = { steps : List Steps }, default = {=} }

let GenPipeline
    : ∀(c : Config.Type) → Pipeline.Type
    = λ(c : Config.Type) →
        let concurrencyGroup = "${c.repositoryName}/update-images"

        let common =
              { retry = Some
                  ( bk.Retry.Manual
                      { manual =
                        { allowed = Some False
                        , reason = Some
                            "Sorry, queue up a new build instead (we don't want to build from outdated commits)."
                        , permit_on_passed = Some False
                        }
                      }
                  )
              , concurrency_group = Some concurrencyGroup
              , concurrency = Some 1
              }

        let runScript = λ(name : Text) → "${c.scriptsFolder}/${name}"

        let cleanup =
                bk.Command::{
                , label = Some ":broom: :git: cleanup old branch"
                , commands = [ runScript "clean-branch-if-exists.sh" ]
                , key = Some "start_gate"
                , env = Some (toMap { TARGET_BRANCH = PR_BRANCH })
                }
              ⫽ common

        let targetCommit =
              "\${TARGET_COMMIT?is not set. Please specify the sourcegraph/sourcegraph commit that you would like to be deployed.}"

        let title = "Update Docker images to ${targetCommit}"

        let urls =
              { sourcegraph =
                { commit =
                    "https://sourcegraph.com/github.com/sourcegraph/sourcegraph/-/commit/${targetCommit}"
                , tree =
                    "https://sourcegraph.com/github.com/sourcegraph/sourcegraph@${targetCommit}"
                }
              , github =
                { commit =
                    "https://github.com/sourcegraph/sourcegraph/commit/${targetCommit}"
                , tree =
                    "https://github.com/sourcegraph/sourcegraph/tree/${targetCommit}"
                }
              }

        let commitMessage =
              ''
              ${title}

              Links:

              [Commit]
              - sourcegraph: ${urls.sourcegraph.commit}
              - github: ${urls.github.commit}

              [Tree]
              - sourcegraph: ${urls.sourcegraph.tree}
              - github: ${urls.github.tree}
              ''

        let srcimage =
                bk.Command::{
                , label = Some ":bash: :k8s: commit 'srcimg' changes"
                , commands = [ runScript "update-all-images.sh" ]
                , key = Some "stage-srcimg"
                , depends_on = Some (List/unpackOptionals Text [ cleanup.key ])
                , plugins = Some
                  [ toMap
                      { `thedyrt/git-commit#v0.3.0` = toMap
                          { add = "."
                          , branch = PR_BRANCH
                          , create-branch = "true"
                          , message = commitMessage
                          , remote = "origin"
                          }
                      }
                  ]
                }
              ⫽ common

        let createPR =
                bk.Command::{
                , label = Some ":github: Open Pull Request"
                , commands = [ runScript "create-pr.sh" ]
                , key = Some "stage-create-pr"
                , depends_on = Some (List/unpackOptionals Text [ srcimage.key ])
                , env = Some
                    ( toMap
                        { HEAD = PR_BRANCH
                        , TITLE = title
                        , BODY = commitMessage
                        }
                    )
                }
              ⫽ common

        let out =
              Pipeline::{
              , steps =
                [ Steps.Command cleanup
                , bk.wait
                , Steps.Command srcimage
                , bk.wait
                , Steps.Command createPR
                ]
              }

        in  out

in  GenPipeline
