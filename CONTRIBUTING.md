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
| terraform-docs | >= 0.19 | module input/output tables |
| trivy | latest | IaC misconfiguration scan |
| Go | >= 1.23 | Terratest example only |
| pre-commit | optional | runs the above on `git commit` |

## Local checks

```bash
terraform fmt -recursive
find modules -name '*.tf' -printf '%h\n' | sort -u | while read -r d; do
  terraform -chdir="$d" init -backend=false && terraform -chdir="$d" validate
done
tflint --recursive
terraform -chdir=modules/naming test
terraform-docs markdown table --output-file README.md --output-mode inject modules/naming
trivy config .
```

Or install the hooks once: `pip install pre-commit && pre-commit install`.

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
