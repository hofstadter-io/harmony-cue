package testers

import (
	"dagger.io/dagger"
  "universe.dagger.io/docker"
  "universe.dagger.io/go"
)

// reusable Dagger Plans

WorkdirPlan: dagger.#Plan & {
  // get the current dir
  client: filesystem: ".": read: {
    // CUE type defines expected content
    contents: dagger.#FS
  }

  actions: {
    // default versions
    versions: Versions

    // start with a hidden ref to out base image
    image: {}

    // copy in source
    source: docker.#Copy & {
      input: image.output
      contents: client.filesystem.".".read.contents 
      dest: "/work"
    }
    
    // default Run with common config set 
    run: docker.#Run & {
      input: docker.#Image | *source.output
      workdir: "/work"
    }
  }

}

DaggerPlan: WorkdirPlan & {
  actions: run: command: {
    name: "dagger"
    args: _ | *["do", "run"]
  }
}

CuePlan: WorkdirPlan & {
  actions: run: command: {} | *{
    name: "cue"
    args: _ | *["eval"]
  }
}

CueGoApiPlan: WorkdirPlan & {
  actions: {
    // this is set by the unity-dagger driver
    versions: cue: string

    source: go.#Image
    
    cue: docker.#Run & {
      input: source.output 
      command: {
        name: "go"
        args: _ | *["get", "cuelang.org/go@\(versions.cue)"]
      }
    }

    tidy: docker.#Run & {
      input: cue.output 
      command: {
        name: "go"
        args: _ | *["mod", "tidy"]
      }
    }

    run: docker.#Run & {
      input: tidy.output 
      command: {} | *{
        name: "go"
        args: _ | *["mod", "tidy"]
      }
    }
  }
}

VersionPlan: WorkdirPlan & {
  actions: {
    run: {
      command: {
        name: "bash"
        args: ["-c", _script]
        _script: """
        #!/usr/bin/env bash
        set -euo pipefail

        go version
        cue version
        dagger version
        hof version

        set +e
        ls /localcue
        exit 0
        """
      }
    }
  }
}

TestscriptPlan: WorkdirPlan & {
  actions: {
    glob: string
    run: {
      command: {
        name: "sh"
        args: ["-c", _script]
        _script: """
        set -euo pipefail

        # todo, count errors
        for f in `ls \(glob)`; do 
          echo $f
          testscript $f
          echo
        done
        """
      }
    }
  }
}
