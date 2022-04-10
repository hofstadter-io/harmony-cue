# harmony-cue

`harmony-cue` is built on [harmony](https://github.com/hofstadter-io/harmony)
and enables testing CUE projects against any release or commit.

Supports tests using

- `cue` cli
- CUE's GoAPI
- [Dagger](https://dagger.io)
- Testscript (txtar files)
- Bash scripts

You can see all available tools in
[testers/image.cue](./testers/image.cue)

## Add a project

To add your project to `harmony-cue`,
open a pull request to add a file to `registry/<name>.cue`.

```cue
package registry

Registry: <name>: Registration & {
  remote: "github.com/org/repo"
  ref: "main" // branch, tag, or commit

  // examples using the available short codes
  cases: {
    cue:    { _cue: ["eval", "in.cue"], workdir: "/work/examples/cue" }
    hof:    { _script: "./test.sh", workdir: "/work/examples/hof" }
    goapi:  { _goapi: "go run main.go", workdir: "/work/examples/go" }
    dagger: { _dagger: "run", workdir: "/work/examples/dagger" }
    txtar:  { _testscript: "*.txt", workdir: "/work/examples/txtar" }
    script: {
      workdir: "/work/examples/script"
      _script: """
      #!/usr/bin/env bash
      set -euo pipefail

      echo "a bash script"
      pwd
      ls
      ./run.sh
      """
    }
  }
}
```

Test your project with `dagger do <name> <case>` or `./run.py <name> <case>`.
The python script makes it easier to inject versions and will run cases sequentially.
