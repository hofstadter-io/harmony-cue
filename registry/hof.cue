package registry

Registry: hof: #Registration & {
  remote: "github.com/hofstadter-io/hof"
  ref: "_dev"

  cases: {
    build: { _goapi: "go run ./cmd/hof", workdir: "/work" }
  }
}
