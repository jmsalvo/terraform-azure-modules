<#
.SYNOPSIS
    Runs the credential-free CI checks locally on Windows, no bash required.

.DESCRIPTION
    Mirrors the jobs in .github/workflows/ci.yml: terraform fmt, terraform
    validate (every module and example), tflint, terraform test, the
    terraform-docs drift check, and the trivy config scan. Run it before
    pushing a branch.

    Every tool is a native Windows binary (install with:
      scoop install terraform tflint terraform-docs trivy go
    ). This script exists because the pre-commit `terraform_*` hooks are bash
    scripts and need Git Bash on PATH; .pre-commit-config.yaml is still the
    path for CI and macOS/Linux contributors.

.PARAMETER Fix
    Auto-fix what can be: rewrite formatting with `terraform fmt` and
    regenerate the terraform-docs tables, instead of only checking.

.PARAMETER IncludeTerratest
    Also run the Go/Terratest suite in test/ (needs Go). Off by default.

.EXAMPLE
    .\scripts\check.ps1

.EXAMPLE
    .\scripts\check.ps1 -Fix
#>
[CmdletBinding()]
param(
    [switch]$Fix,
    [switch]$IncludeTerratest
)

$ErrorActionPreference = 'Stop'
$global:LASTEXITCODE = 0

$RepoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $RepoRoot
try {
    $failures = New-Object System.Collections.Generic.List[string]

    function Test-Tool {
        param([string]$Name)
        return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
    }

    function Invoke-Step {
        param(
            [string]$Name,
            [scriptblock]$Body
        )
        Write-Host ''
        Write-Host "==> $Name" -ForegroundColor Cyan
        & $Body
        if ($LASTEXITCODE -ne 0) {
            Write-Host "    FAILED: $Name" -ForegroundColor Red
            $failures.Add($Name)
        }
        else {
            Write-Host '    ok' -ForegroundColor Green
        }
    }

    # --- tool presence ---------------------------------------------------------
    $missing = @('terraform', 'tflint', 'terraform-docs', 'trivy') | Where-Object { -not (Test-Tool $_) }
    if ($missing) {
        Write-Host "Missing tools: $($missing -join ', ')" -ForegroundColor Red
        Write-Host "Install with: scoop install $($missing -join ' ')" -ForegroundColor Yellow
        exit 1
    }

    # --- directories ---------------------------------------------------------
    $tfDirs = Get-ChildItem -Path 'modules' -Recurse -Filter '*.tf' -File |
        Where-Object { $_.FullName -notmatch '\\\.terraform\\' } |
        ForEach-Object { $_.DirectoryName } |
        Select-Object -Unique | Sort-Object

    $testDirs = Get-ChildItem -Path 'modules' -Recurse -Directory -Filter 'tests' |
        ForEach-Object { $_.Parent.FullName } |
        Select-Object -Unique | Sort-Object

    $moduleDirs = Get-ChildItem -Path 'modules' -Directory |
        ForEach-Object { $_.FullName } | Sort-Object

    # --- fmt ---------------------------------------------------------
    if ($Fix) {
        Invoke-Step 'terraform fmt (rewrite)' { terraform fmt -recursive | Out-Host }
    }
    else {
        Invoke-Step 'terraform fmt -check' { terraform fmt -check -recursive -diff | Out-Host }
    }

    # --- validate ---------------------------------------------------------
    foreach ($dir in $tfDirs) {
        $rel = Resolve-Path -Relative $dir
        Invoke-Step "terraform validate $rel" {
            terraform "-chdir=$dir" init -backend=false -input=false -no-color | Out-Host
            if ($LASTEXITCODE -eq 0) {
                terraform "-chdir=$dir" validate -no-color | Out-Host
            }
        }
    }

    # --- tflint ---------------------------------------------------------
    Invoke-Step 'tflint --init' { tflint --init | Out-Host }
    Invoke-Step 'tflint --recursive' { tflint --recursive --no-color | Out-Host }

    # --- terraform test ---------------------------------------------------------
    foreach ($dir in $testDirs) {
        $rel = Resolve-Path -Relative $dir
        Invoke-Step "terraform test $rel" {
            terraform "-chdir=$dir" init -backend=false -input=false -no-color | Out-Host
            if ($LASTEXITCODE -eq 0) {
                terraform "-chdir=$dir" test -no-color | Out-Host
            }
        }
    }

    # --- terraform-docs ---------------------------------------------------------
    foreach ($dir in $moduleDirs) {
        $rel = Resolve-Path -Relative $dir
        if ($Fix) {
            Invoke-Step "terraform-docs (rewrite) $rel" {
                terraform-docs markdown table --output-file README.md --output-mode inject "$dir" | Out-Host
            }
        }
        else {
            Invoke-Step "terraform-docs --output-check $rel" {
                terraform-docs markdown table --output-file README.md --output-mode inject --output-check "$dir" | Out-Host
            }
        }
    }

    # --- trivy ---------------------------------------------------------
    Invoke-Step 'trivy config' { trivy config --config trivy.yaml . | Out-Host }

    # --- terratest (optional) ------------------------------------------------
    if ($IncludeTerratest) {
        if (Test-Tool 'go') {
            Invoke-Step 'go test ./test/...' {
                Push-Location (Join-Path $RepoRoot 'test')
                try {
                    go mod tidy | Out-Host
                    if ($LASTEXITCODE -eq 0) {
                        go test -v -timeout 30m ./... | Out-Host
                    }
                }
                finally { Pop-Location }
            }
        }
        else {
            Write-Host ''
            Write-Host '==> go test ./test/... : SKIPPED (go not installed)' -ForegroundColor Yellow
        }
    }

    # --- summary ---------------------------------------------------------
    Write-Host ''
    if ($failures.Count -gt 0) {
        Write-Host "FAILED ($($failures.Count)):" -ForegroundColor Red
        $failures | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
        exit 1
    }
    Write-Host 'All checks passed.' -ForegroundColor Green
    exit 0
}
finally {
    Pop-Location
}
