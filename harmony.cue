package main

import (
  "dagger.io/dagger"
  "github.com/hofstadter-io/harmony"

  "github.com/hofstadter-io/harmony-cue/registry"
  "github.com/hofstadter-io/harmony-cue/testers"
)

// A dagger plan is used as the driver for testing
dagger.#Plan

// add actions from Harmony
actions: harmony.Harmony

// project specific configuration follows

// for docker-in-docker, also required for dagger-in-dagger
client: network: "unix:///var/run/docker.sock": connect: dagger.#Socket

actions: {

  // global version config for this harmony
  versions: testers.Versions

  // the registry of downstream projects
  "registry": registry.Registry

  // the image test cases are run in
  // here we have a custom / parameterized base image
  runner: build.output
  build: testers.Image & {
    "versions": versions
  }

  // where downstream project code is checked out
  workdir: "/work" 
      
  extra: run: {
    mounts: {
      // for dagger-in-dagger, and docker-in-docker
      docker: {
        contents: client.network."unix:///var/run/docker.sock".connect
        dest:     "/var/run/docker.sock"
      }
    }
  }
}
