package dagger

import (
  "github.com/hofstadter-io/harmony-cue/testers"
)

// todo: how do we handle 'local' cue version in a nested (running dagger from a harmony test case)
// also workdir?
testers.TestscriptPlan & {
  actions: glob: "testdata/*.txt"
  // shouldn't really need this?
  actions: {
    versions: { ... } // filled with defaults
    builder: testers.Build & { versions: testers.Versions & actions.versions }
    image: builder.output
  }
}
