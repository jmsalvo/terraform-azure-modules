# test

Terratest suite for this repository.

Native `terraform test` (in `modules/<name>/tests/`) is the primary test approach
here. This Go suite is a single, deliberate example of a Terratest-style
integration check so the repo demonstrates both tools.

## Running

```bash
cd test
go test -v -timeout 30m ./...
```

`TestNamingBasicExample` exercises `modules/naming/examples/basic`. The naming
module declares no providers, so the test needs **no Azure credentials** and
creates nothing. Terratest examples added for provider-backed modules later will
require credentials and will be tagged so CI can skip them.

## `go.sum`

Not yet committed — no Go toolchain was available on the machine that scaffolded
this repo. CI runs `go mod tidy` before `go test`. Run `go mod tidy` locally and
commit `go.sum` on the first change from a machine with Go installed.
