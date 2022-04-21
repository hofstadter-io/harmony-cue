package main

import (
  "dagger.io/dagger"
  "universe.dagger.io/docker"
  "universe.dagger.io/docker/cli"
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

client: env: DOCKER_USER:  string
client: env: DOCKER_TOKEN: dagger.#Secret

if actions.versions.cue == "local" {
  // get the current dir
  client: filesystem: "\(actions.pathToCUE)": read: {
    // CUE type defines expected content
    contents: dagger.#FS
  }
}

actions: {
  // path to a local copy of CUE
  pathToCUE: string | *"../cue"

  // global version config for this harmony
  versions: testers.Versions

  // the registry of downstream projects
  "registry": registry.Registry

  name: "hofstadter/harmony-cue:latest"

  // the image test cases are run in
  // here we have a custom / parameterized base image
  build: testers.Build & {
    "versions": versions
    if versions.cue == "local" {
      cuesource: client.filesystem["\(actions.pathToCUE)"].read.contents
    }
  }

  load: cli.#Load & {
    image: build.output
    host:  client.network."unix:///var/run/docker.sock".connect
    tag:   name
  }

  push: docker.#Push & {
    image: build.output 
    dest: name
    auth: {
      username: client.env.DOCKER_USER
      secret:   client.env.DOCKER_TOKEN 
    }
  }

  pull: docker.#Pull & {
    source: name
    auth: {
      username: client.env.DOCKER_USER
      secret:   client.env.DOCKER_TOKEN 
    }
  }

  runner: pull.image

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
