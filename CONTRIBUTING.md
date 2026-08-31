# Contributing

## Workflow

1. Branch from `main`.
2. Make the change. Add or update `.tftest.hcl` coverage for any behaviour change.
3. Run the local checks below.
4. Open a PR. CI must be green to merge.
5. Commits follow [Conventional Commits](https://www.conventionalcommits.org/)
   (`feat:`, `fix:`, `docs:`, `chore:`, `test:`, `ci:`, `refactor:`).

## Tooling

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | >= 1.6 | `fmt`, `validate`, `test` |
| tflint | latest | lint + azurerm ruleset |
| terraform-docs | v0.24.x (match CI) | module input/output tables |
| trivy | latest | IaC misconfiguration scan |
| Go | >= 1.23 | Terratest example only |
| pre-commit | optional | runs the above on `git commit` (macOS/Linux, or Windows + Git Bash) |

Windows contributors: `scripts\check.ps1` runs the same checks natively — see below.

## Local checks

Run the same checks CI runs, before pushing.

**Windows** (no bash needed):

```powershell
.\scripts\check.ps1          # check everything
.\scripts\check.ps1 -Fix     # also auto-run `terraform fmt` + regenerate docs
.\scripts\check.ps1 -IncludeTerratest
```

**macOS / Linux** — either the pre-commit hooks:

```bash
pipx install pre-commit   # or: pip install pre-commit
pre-commit install        # then hooks run on every `git commit`
pre-commit run --all-files
```

or by hand:

```bash
terraform fmt -check -recursive
find modules -name '*.tf' -printf '%h\n' | sort -u | while read -r d; do
  terraform -chdir="$d" init -backend=false && terraform -chdir="$d" validate
done
tflint --init && tflint --recursive
find modules -type d -name tests | while read -r t; do terraform -chdir="$(dirname "$t")" test; done
terraform-docs markdown table --output-file README.md --output-mode inject --output-check modules/naming
trivy config --config trivy.yaml .
```

> The `pre-commit` `terraform_*` hooks are bash scripts and need Git Bash on `PATH`.
> On Windows that often collides with the WSL `bash.exe` shim — use `scripts\check.ps1`
> instead. CI still runs `.pre-commit-config.yaml`'s tools via dedicated jobs.

## Adding a module

- `modules/<name>/` with `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`,
  `README.md` (with the `<!-- BEGIN_TF_DOCS -->` / `<!-- END_TF_DOCS -->`
  markers), `examples/<case>/`, and `tests/*.tftest.hcl`.
- Add the module dir to the `docs` job in `.github/workflows/ci.yml`.
- Add a row to the module table in the root `README.md`.
- Note the change in `CHANGELOG.md` under `## [Unreleased]`.

## Releases

Maintainer only: move `## [Unreleased]` to `## [x.y.z] - DATE` in `CHANGELOG.md`,
then tag `vX.Y.Z` on `main` and create a GitHub Release with the changelog notes.
