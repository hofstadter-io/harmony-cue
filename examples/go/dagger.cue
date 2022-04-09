package go

import (
  "github.com/hofstadter-io/harmony-cue/testers"
)

testers.CueGoApiPlan & {
  actions: glob: "testdata/*.txt"
}

