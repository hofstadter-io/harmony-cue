package registry

import (
  "strings"

  "universe.dagger.io/docker"
  "github.com/hofstadter-io/harmony"
)

Registration: R=(harmony.Registration & {
  // add our short codes 
  cases: [string]: docker.#Run & {
    _dagger?: string
    if _dagger != _|_ {
      command: {
        name: "bash"
        args: ["-c", _script]
        _script: """
        dagger version
        dagger project update
        dagger do \(_dagger) --with 'actions: versions: cue: "\(R.versions.cue)"'
        """ 
      }
    }

    _cue?: [...string]
    if _cue != _|_ {
      command: {
        name: "bash"
        args: ["-c", _script]
        _script: """
        cue version
        cue \(strings.Join(_cue, " "))
        """ 
      }
    }

    _goapi?: string
    if _goapi != _|_ {
      command: {
        name: "bash"
        args: ["-c", _script]
        _script: """
        set -euo pipefail
        go version
        go get cuelang.org/go@\(R.versions.cue)
        go mod tidy -compat=1.17
        \(_goapi)
        """ 
      }
    }

    _testscript?: string
    if _testscript != _|_ {
      command: {
        name: "bash"
        args: ["-c", _script]
        _script: """
        set -euo pipefail
        for f in `ls \(_testscript)`; do 
          echo $f
          testscript $f
          echo
        done
        """ 
      }
    }

    _script?: string
    if _script != _|_ {
      command: {
        name: "bash"
        args: ["-c", _script]
      }
    }
  }
})
