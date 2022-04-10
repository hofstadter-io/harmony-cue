package versions 

import (
  "github.com/hofstadter-io/harmony-cue/testers"
)

// todo: how do we handle 'local' cue version in a nested (running dagger from a harmony test case)
// testers.VersionPlan
testers.VersionPlan & {
  actions: {
    versions: { ... } // filled with defaults
    builder: testers.Build & { versions: testers.Versions & actions.versions }
    image: builder.output
  }
}
