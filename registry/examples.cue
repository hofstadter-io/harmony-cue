package registry

Registry: examples: Registration & {
  remote: "github.com/hofstadter-io/harmony-cue"
  ref: "main"

  cases: {
    cue:      { _cue: ["eval", "in.cue"], workdir: "/work/examples/cue" }
    hof:      { _script: "hof -h", workdir: "/work" }
    goapi:    { _goapi: "go run main.go", workdir: "/work/examples/go" }
    dagger:   { _dagger: "run", workdir: "/work/examples/dagger" }
    txtar:    { _testscript: "*.txt", workdir: "/work/examples/txtar" }
    script:   {
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

    "versions-example": { _script: "./list.sh", workdir: "/work/examples/versions" }
    "versions-dagger":  { _dagger: "run --plan ./examples/versions/dagger.cue", workdir: "/work" }
    "versions-script":  {
      workdir: "/work"
      _script: """
        #!/usr/bin/env bash

        go version
        cue version
        dagger version
        hof version
        python3 --version

        tree -d /work/cue.mod
        ls /localcue
        exit 0
      """
    }

    inception:  {
      workdir: "/work"
      _script: """
        #!/usr/bin/env bash
        dagger project update
        mkdir -p cue.mod/pkg/github.com/hofstadter-io
        pushd cue.mod/pkg/github.com/hofstadter-io
        git clone https://github.com/hofstadter-io/harmony
        popd
        ./run.py examples versions-dagger
      """
    }
  }
}
