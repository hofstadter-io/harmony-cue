package versions 

import (
  "github.com/hofstadter-io/harmony-cue/testers"
)

// todo: how do we handle 'local' cue version in a nested (running dagger from a harmony test case)
testers.VersionPlan
// testers.VersionPlan & {
//   actions: image: testers.Image & { versions: testers.Version & actions.versions }
//   actions: versions: { ... }
// }
