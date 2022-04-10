package dagger

import (
  "github.com/hofstadter-io/harmony-cue/testers"
)

// todo: how do we handle 'local' cue version in a nested (running dagger from a harmony test case)
// also workdir?
testers.TestscriptPlan & {
  actions: glob: "testdata/*.txt"

  // this is needed so the versions are dynamic (from the driver)
  actions: image: testers.Image & { versions: testers.Version & actions.versions }
  actions: versions: { ... }
}
