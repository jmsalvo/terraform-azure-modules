# Working with Claude in this repo

Guidance for Claude Code (or any AI agent) working in this repo. Human-
contributor mechanics — workflow, tooling, local checks, how to add a module —
are in `CONTRIBUTING.md`; don't duplicate that here.

## What this repo is

The "warm-up" supporting repo in a multi-repo portfolio: versioned, tested
Azure Terraform modules (`naming`, `networking`, `key-vault`, `aks`),
consumed by the flagship `secure-azure-platform` repo (a sibling directory,
`../secure-azure-platform`) via `source =
"github.com/jmsalvo/terraform-azure-modules//modules/<name>?ref=vX.Y.Z"`.
**Done and tagged `v0.1.0`, public.** Cross-repo project status lives in
another sibling, `../plan/docs/status.md` and
`../plan/docs/next-session-prompt.md` — read those for what's currently
active across the whole portfolio.

## Permission boundary

Much lighter than the flagship repo: **CI here is entirely credential-free**
(fmt/validate/tflint/`terraform test`/terraform-docs-drift/trivy/terratest —
no `apply` job exists, nothing here ever touches a live Azure subscription).
Still ask before:
- **Creating a new git tag / GitHub Release** — it's a public, external-
  facing action (visible in the portfolio).
- **Pushing directly to `main`** outside the normal PR flow.

## The module-consumption lag — the thing to remember

A change merged here has **no effect on the flagship until two more things
happen**: (1) a new version tag is cut, and (2) the flagship's `?ref=` pin
is bumped and applied. This project already hit this as a real dependency:
`v0.2` Hardened AKS needed the `aks` module extended
(`api_server_authorized_ip_ranges`, a second node pool) *before* the flagship
stack could be written — confirmed by reading the actually-pinned module
source, not assumed. When a flagship milestone's brainstorm surfaces a need
here, treat "small additive module PR + new tag" as a prerequisite task,
not an afterthought — check the pinned module's real `variables.tf`/`main.tf`
against what the milestone needs before writing the flagship-side Terraform.

## Gotchas

- **Module README tables are generated, not hand-written.** Everything
  between `<!-- BEGIN_TF_DOCS -->` / `<!-- END_TF_DOCS -->` comes from
  `terraform-docs`; CI's `docs` job fails the build on drift. Run
  `terraform-docs markdown table --output-file README.md --output-mode
  inject modules/<name>` (or `scripts\check.ps1 -Fix`) after changing
  `variables.tf`/`outputs.tf`, don't edit the table by hand.
- **Local/CI Terraform version skew is a real bug source, not just a lint
  nag.** A validation that passes locally on a newer Terraform can fail
  differently on CI's pinned version (a `null >= 1` comparison once
  evaluated on one version and not the other). If a check behaves
  differently locally vs. CI, check `TERRAFORM_VERSION` in `ci.yml` against
  the local version before assuming it's a config bug.
- **The `pre-commit` git hook can break `.tf` commits on Windows** (its
  `terraform_*` hooks are bash scripts that can collide with a WSL
  `bash.exe` shim on `PATH`). `scripts\check.ps1` is the reliable
  Windows-native path — prefer it over `pre-commit run` when working from
  this environment.
- **This repo is public.** No secrets ever belong here (there's no live
  Azure config to leak from — modules are all provider-agnostic definitions
  tested with `mock_provider`/no-provider `.tftest.hcl` suites), but treat
  commit messages, code comments, and anything committed as visible to
  anyone, same bar as the flagship once it goes public too.
