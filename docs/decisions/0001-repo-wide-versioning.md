# 0001 — Repo-wide versioning for the module collection

- **Status:** Accepted
- **Date:** 2026-08-30

## Context

This repo holds several Terraform modules in one Git repository. Consumers
reference them by Git source with a `?ref=` pin:

```
source = "github.com/jmsalvo/terraform-azure-modules//modules/naming?ref=<ref>"
```

Git tags are repo-global, so a versioning scheme has to be chosen deliberately.
Two options:

1. **Repo-wide semver** — one tag (`vX.Y.Z`) is one internally consistent
   snapshot of every module.
2. **Per-module tags** — `naming/vX.Y.Z`, `networking/vX.Y.Z`, independent
   version streams per module.

## Decision

Use **repo-wide semver**. One `CHANGELOG.md`, one tag, one GitHub Release per
version. Consumers pin every module `source` to the same `?ref=`.

## Rationale

- The repo has a handful of modules maintained by one person, and several of them
  (`networking`, `key-vault`, `aks`) will depend on `naming`. They change
  together more often than not; a single tag removes the compatibility-matrix
  bookkeeping that independent versions would create.
- One flat `git tag` list and one Releases page keep "what state is this repo in"
  answerable at a glance.
- Release mechanics stay trivial: bump `CHANGELOG.md`, tag, release. No
  per-module changelog or release-automation tooling.

## Alternative: per-module tags

Stronger when it applies — and it is how the author has versioned modules in
production — but the conditions that make it worth the overhead are not present
here:

- **Registry distribution** (Artifactory, Terraform Cloud private registry). The
  registry protocol is inherently per-module; independent versions are mandatory
  there, not a choice.
- **Many modules, many independent consumers**, where a patch to one module must
  ship without every other consumer re-evaluating.
- **Divergent maturity** — a stable module at v6 and a new one at v0 should not
  share a number.

## Consequences

- A change to any module can bump the repo version; consumers of an untouched
  module still see the new tag. Acceptable at this scale.
- `CHANGELOG.md` entries name the affected module.

## Revisit when

Any of: module count grows past roughly six; external teams consume the modules;
a module's interface stabilises far ahead of the others; or the repo starts
publishing to a module registry. At that point, move to per-module tags
(`<module>/vX.Y.Z`) or registry publishing and supersede this ADR.
