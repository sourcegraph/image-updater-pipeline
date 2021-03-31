let PipelineConfig =
      { Type =
          { baseBranch : Text, repositoryName : Text, scriptsFolder : Text }
      , default =
        { baseBranch = "main", scriptsFolder = ".buildkite/image-updater" }
      }

in  PipelineConfig
