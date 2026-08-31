# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Versioning is **repo-wide**: one tag covers every module. See
[ADR 0001](docs/decisions/0001-repo-wide-versioning.md).

## [Unreleased]

### Added
- Repository scaffold: layout conventions, credential-free CI (`fmt`, `validate`,
  `tflint`, `terraform test`, `trivy config`, `terraform-docs` drift check) and a
  single Terratest example.
- `naming` module — deterministic Azure resource naming and tagging with no
  provider and no API calls; `.tftest.hcl` behaviour and input-validation suites.
