let ImageUpdater = ../package.dhall

let Config = ImageUpdater.Config

let c =
      Config::{
      , repositoryName = "sourcegraph/image-updater-pipeline"
      , scriptsFolder = env:SCRIPTS_DIR as Text ? ".buildkite/image-updater"
      }

let Pipeline = ImageUpdater.MakePipeline c

in  { Pipeline, Scripts = ImageUpdater.Scripts }
