param(
    [switch]$AllowEmpty
)

$ErrorActionPreference = "Continue"
$script:ChecksRun = 0

function Invoke-VerifyStep {
    param(
        [string]$Label,
        [string]$Command
    )
    if ([string]::IsNullOrWhiteSpace($Command)) {
        Write-Host "[SKIP] ${Label}: not configured"
        return
    }
    Write-Host ">>> ${Label}: ${Command}"
    cmd.exe /c $Command
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: ${Label} failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
    $script:ChecksRun++
}

function Get-NodePackageManager {
    if (Test-Path "pnpm-lock.yaml") { return "pnpm" }
    if (Test-Path "yarn.lock") { return "yarn" }
    if ((Test-Path "bun.lockb") -or (Test-Path "bun.lock")) { return "bun" }
    return "npm"
}

function Get-PkgScript {
    param([string]$ScriptName)
    if (-not (Test-Path "package.json")) { return "" }
    try {
        $pkg = Get-Content -Raw -Path "package.json" | ConvertFrom-Json
        if ($null -ne $pkg.scripts -and ($pkg.scripts.PSObject.Properties.Name -contains $ScriptName)) {
            return [string]$pkg.scripts.$ScriptName
        }
    } catch {}
    return ""
}

$TypecheckCmd = $env:VERIFY_TYPECHECK_CMD
$LintCmd      = $env:VERIFY_LINT_CMD
$TestCmd      = $env:VERIFY_TEST_CMD

if ((Test-Path "package.json") -and [string]::IsNullOrWhiteSpace("$TypecheckCmd$LintCmd$TestCmd")) {
    $pm = Get-NodePackageManager

    foreach ($candidate in @("typecheck", "type-check", "check-types")) {
        if (-not [string]::IsNullOrWhiteSpace((Get-PkgScript $candidate))) {
            $TypecheckCmd = "$pm run $candidate"
            break
        }
    }
    if ([string]::IsNullOrWhiteSpace($TypecheckCmd) -and (Test-Path "tsconfig.json") -and (Test-Path ".\node_modules\.bin\tsc.cmd")) {
        $TypecheckCmd = ".\node_modules\.bin\tsc.cmd --noEmit"
    }

    if (-not [string]::IsNullOrWhiteSpace((Get-PkgScript "lint"))) {
        $LintCmd = "$pm run lint"
    }

    $rawTest = Get-PkgScript "test"
    if (-not [string]::IsNullOrWhiteSpace($rawTest) -and ($rawTest -notmatch "no test specified")) {
        $env:CI = "true"
        if (($rawTest -match "jest|react-scripts") -and ($rawTest -notmatch "watchAll")) {
            if ($pm -eq "npm") { $TestCmd = "npm test -- --watchAll=false" } else { $TestCmd = "$pm test --watchAll=false" }
        } elseif (($rawTest -match "vitest") -and ($rawTest -notmatch "vitest run|--run|--watch=false")) {
            if ($pm -eq "npm") { $TestCmd = "npm test -- --run" } else { $TestCmd = "$pm test --run" }
        } else {
            $TestCmd = "$pm test"
        }
    }
} elseif ([string]::IsNullOrWhiteSpace("$TypecheckCmd$LintCmd$TestCmd")) {
    if ((Test-Path "pyproject.toml") -or (Test-Path "pytest.ini") -or (Test-Path "requirements.txt")) {
        $hasMypyConfig = (Test-Path "mypy.ini") -or ((Test-Path "pyproject.toml") -and ((Get-Content -Raw "pyproject.toml") -match "\[tool\.mypy\]"))
        if ($hasMypyConfig -and (Get-Command mypy -ErrorAction SilentlyContinue)) {
            $TypecheckCmd = "mypy ."
        }
        if (Get-Command ruff -ErrorAction SilentlyContinue) {
            $LintCmd = "ruff check ."
        } elseif (Get-Command flake8 -ErrorAction SilentlyContinue) {
            $LintCmd = "flake8 ."
        }
        if (Get-Command pytest -ErrorAction SilentlyContinue) {
            $TestCmd = "pytest"
        } elseif ((Test-Path "tests") -and (Get-Command python -ErrorAction SilentlyContinue)) {
            $TestCmd = "python -m unittest discover -s tests"
        }
    } elseif (Test-Path "go.mod") {
        $TypecheckCmd = "go vet ./..."
        if (Get-Command golangci-lint -ErrorAction SilentlyContinue) {
            $LintCmd = "golangci-lint run"
        }
        $TestCmd = "go test ./..."
    } elseif (Test-Path "Cargo.toml") {
        $TypecheckCmd = "cargo check"
        $TestCmd = "cargo test"
    }
}

Write-Host "========================================"
Write-Host "AI-SDLC Verification Gate"
Write-Host "========================================"

Invoke-VerifyStep "[1/3] Type Check" $TypecheckCmd
Invoke-VerifyStep "[2/3] Linter"     $LintCmd
Invoke-VerifyStep "[3/3] Tests"      $TestCmd

if (($script:ChecksRun -eq 0) -and (-not $AllowEmpty)) {
    Write-Host "ERROR: No typecheck, lint, or test runner was detected (0 checks ran)." -ForegroundColor Red
    Write-Host "Configure scripts in package.json (typecheck/lint/test) or set VERIFY_TYPECHECK_CMD / VERIFY_LINT_CMD / VERIFY_TEST_CMD."
    exit 2
}

Write-Host "ALL CHECKS PASSED! ($($script:ChecksRun) check(s) succeeded)" -ForegroundColor Green
exit 0
