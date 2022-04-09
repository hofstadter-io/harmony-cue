package dagger

import (
  "github.com/hofstadter-io/harmony-cue/testers"
)

testers.TestscriptPlan & {
  actions: glob: "testdata/*.txt"
  // this is needed so the versions are dynamic (from the driver)
  actions: image: testers.Image & { versions: actions.versions }
  actions: versions: { ... }
}
