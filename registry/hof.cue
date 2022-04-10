package registry

Registry: hof: Registration & {
  remote: "github.com/hofstadter-io/hof"
  ref: "_dev"

  cases: {
    build: { 
      workdir: "/work"
      _goapi: """
        go install ./cmd/hof
        hof -h
      """
    }
  }
}
