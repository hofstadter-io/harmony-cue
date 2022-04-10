package testers

import (
  "strings"

  "dagger.io/dagger"
  "dagger.io/dagger/core"
  "universe.dagger.io/docker"
  "universe.dagger.io/git"
  "universe.dagger.io/go"
)

Base: {
	version: string

	packages: [pkgName=string]: version: string | *""

	// FIXME Basically a copy of alpine.#Build with a different image
	// Should we create a special definition?
	docker.#Build & {
		steps: [
			docker.#Pull & {
				source: "index.docker.io/golang:\(version)-alpine"
			},
			for pkgName, pkg in packages {
				docker.#Run & {
					command: {
						name: "apk"
						args: ["add", "\(pkgName)\(pkg.version)"]
						flags: {
							"-U":         true
							"--no-cache": true
						}
					}
				}
			},
		]
	}
}

Image: {
  // config
  versions: {
    cue: string
    hof: string
    dagger: string
    go: string
    testscript: string
  }
  // provide when cue version is 'local'
  cuesource: dagger.#FS

  // Go based image
  base: Base & {
    version: versions.go 
    packages: {
      bash: {}
      "docker-cli": {}
      gcc: {}
      git: {}
      make: {}
      "musl-dev": {}
      tree: {}
    }
  }

  gotools: {
    [tool=string]: {
      code: git.#Pull & {
        remote: string 
        ref: versions["\(tool)"] 
        keepGitDir: true
      }
      commit: {
        write: docker.#Run & {
          input: base.output
          command: {
            name: "sh"
            args: ["-c", "git rev-parse HEAD > /commit.txt"]
          }
          mounts: source: {
            dest: "/src"
            contents: code.output
          }
          workdir: "/src"
        }
        read: core.#ReadFile & {
          input: write.output.rootfs
          path: "/commit.txt"
        }
      }
      build: go.#Build & {
        container: input: base.output
        source: code.output
        package: "./cmd/\(tool)"
      }
    }

    if versions.cue != "local" {
      cue: code: remote: "https://github.com/cue-lang/cue" 
    }
    cue: build: {
      ldflags: strings.Join([
        "-X cuelang.org/go/cmd/cue/cmd.version=\(versions.cue)",
      ], " ")
    }

    hof: {
      code: remote: "https://github.com/hofstadter-io/hof" 
      build: {
        ldflags: strings.Join([
          "-s",
          "-w",
          "-X github.com/hofstadter-io/hof/cmd/hof/verinfo.Version=\(hof.code.ref)",
          "-X github.com/hofstadter-io/hof/cmd/hof/verinfo.Commit=\(hof.commit.read.contents)",
          // "-X github.com/hofstadter-io/hof/cmd/hof/verinfo.BuildDate={{.Date}}",
          "-X github.com/hofstadter-io/hof/cmd/hof/verinfo.GoVersion=\(versions.go)",
          "-X github.com/hofstadter-io/hof/cmd/hof/verinfo.BuildOS=\(hof.build.os)",
          "-X github.com/hofstadter-io/hof/cmd/hof/verinfo.BuildArch=\(hof.build.arch)",
        ], " ")
      }
    }

    dagger: {
      code: remote: "https://github.com/dagger/dagger" 
      build: {
        ldflags: strings.Join([
          "-X go.dagger.io/dagger/version.Version=\(versions.dagger)",
          "-X go.dagger.io/dagger/version.Revision=\(dagger.commit.read.contents)",
        ], " ")
      }
    }

    testscript: code: remote: "https://github.com/rogpeppe/go-internal" 
  }

  localcue: _
  if versions.cue == "local" {
    localcue: go.#Build & {
      container: input: base.output
      source: cuesource
      package: "./cmd/cue"
    }
  }

  // collect the bins for looping
  bins: [
    gotools.hof.build.output,
    gotools.dagger.build.output,
    gotools.testscript.build.output,
    if versions.cue == "local" { localcue.output },
    if versions.cue != "local" { gotools.cue.build.output },
  ]

  // add the binaries to the base image
  copy: docker.#Build & {
    steps: [{ input: base.output}, ...]
    steps: [
      for bin in bins {
        docker.#Copy & {
          contents: bin 
          dest: "/usr/local/bin"
        }
      },
      if versions.cue == "local" {
        docker.#Copy & {
          contents: cuesource
          dest: "/localcue"
        }
      },
    ]
  }

  // the final image users should reference
  output: docker.#Image & copy.output
}
