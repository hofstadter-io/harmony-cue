package registry

Registry: cuetorials: Registration & {
  remote: "github.com/hofstadter-io/cuetorials.com"
  ref: "main"

  cases: {
    verify: { _script: "make verify_code && make verify_diff", workdir: "/work" }
  }
}
