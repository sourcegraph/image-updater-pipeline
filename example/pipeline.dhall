let ImageUpdater = ./image-updater-pipeline.dhall

let Config = ImageUpdater.Config

let c =
      Config::{
      , repositoryName = "image-updater-pipeline"
      , scriptsFolder = env:SCRIPTS_DIR as Text ? ".buildkite/image-updater"
      }

let Pipeline = ImageUpdater.MakePipeline c

in  Pipeline
