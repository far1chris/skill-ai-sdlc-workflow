param(
    [Parameter(Position = 0)]
    [string]$FeatureSlug,
    [ValidateSet("feat", "fix", "refactor", "chore", "docs", "test")]
    [string]$Type = "feat",
    [switch]$DryRun,
    [switch]$Push,
    [switch]$Pr,
    [switch]$AllowNoSpec,
    [switch]$Force
)

$ErrorActionPreference = "Continue"

function Fail-Ship {
    param([string]$Message, [int]$Code = 1)
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit $Code
}

if ([string]::IsNullOrWhiteSpace($FeatureSlug)) {
    Fail-Ship "FeatureSlug is required (e.g. .\ship-pr.ps1 discount-coupons)"
}

if ($FeatureSlug -notmatch '^[a-z0-9][a-z0-9-]*$') {
    Fail-Ship "Invalid FeatureSlug '$FeatureSlug'. Use lowercase letters, numbers, and hyphens only."
}

if ($Pr) { $Push = $true }

git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
    Fail-Ship "Current directory is not inside a git repository."
}

$unmerged = (git ls-files --unmerged) -join "`n"
if (-not [string]::IsNullOrWhiteSpace($unmerged)) {
    Fail-Ship "Unresolved merge conflicts detected. Resolve them before running ship-pr."
}

$specDir = Join-Path "specs" $FeatureSlug
$specPath = Join-Path $specDir "spec.md"
$walkthroughPath = Join-Path $specDir "walkthrough.md"
$tasksPath = Join-Path $specDir "tasks.md"

if (-not $AllowNoSpec) {
    if (-not (Test-Path $specPath) -or -not (Test-Path $walkthroughPath)) {
        Fail-Ship "Missing Gate artifacts ($specPath and/or $walkthroughPath). Complete Stage 1 and Stage 4 before shipping, or pass -AllowNoSpec."
    }
    if ((-not $Force) -and (Test-Path $tasksPath)) {
        $unchecked = Select-String -Path $tasksPath -Pattern '^\s*-\s*\[ \]'
        if ($unchecked) {
            Fail-Ship "$tasksPath still has unchecked '- [ ]' tasks. Complete all tasks first or pass -Force."
        }
    }
}

$porcelain = @(git status --porcelain | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
$sensitiveHits = @()
foreach ($line in $porcelain) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $filePart = $line.Substring(3).Trim().Trim('"')
    if ($filePart -match ' -> ') { $filePart = ($filePart -split ' -> ')[-1].Trim('"') }
    $isEnvFile = ($filePart -match '(^|[\\/])\.env($|\.)') -and ($filePart -notmatch '\.(example|sample|template)$')
    $isSecretExt = ($filePart -match '\.(pem|key|p12|pfx)$') -or ($filePart -match '(^|[\\/])id_rsa') -or ($filePart -match 'credentials.*\.json$')
    if ($isEnvFile -or $isSecretExt) {
        $sensitiveHits += $filePart
    }
}
if ($sensitiveHits.Count -gt 0) {
    Fail-Ship ("Potential secret/credential files detected in working tree:`n" + ($sensitiveHits -join "`n") + "`nRemove or add them to .gitignore before committing.")
}

$branchName = "feature/$FeatureSlug"
$commitMsg = "${Type}(${FeatureSlug}): implement verified changes per spec"

if ($DryRun) {
    Write-Host "[DRY-RUN] Target branch : $branchName"
    Write-Host "[DRY-RUN] Commit message: $commitMsg"
    Write-Host "[DRY-RUN] Pending workspace changes:"
    git status --short
    exit 0
}

if ($porcelain.Count -eq 0) {
    Fail-Ship "Working tree is clean; nothing to commit."
}

$currentBranch = ""
try { $currentBranch = (git symbolic-ref --short HEAD 2>$null).Trim() } catch {}
if ($currentBranch -ne $branchName) {
    git show-ref --verify --quiet "refs/heads/$branchName"
    if ($LASTEXITCODE -eq 0) {
        git checkout $branchName
    } else {
        git checkout -b $branchName
    }
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

git add -A
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Fail-Ship "Nothing staged for commit after git add -A."
}

Write-Host "Staged changes summary:"
git diff --cached --stat

git commit -m $commitMsg
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Committed to branch: $branchName" -ForegroundColor Green

if ($Push) {
    git push -u origin $branchName
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    if ($Pr) {
        if (Get-Command gh -ErrorAction SilentlyContinue) {
            if (Test-Path $walkthroughPath) {
                gh pr create --title $commitMsg --body-file $walkthroughPath
            } else {
                gh pr create --title $commitMsg --fill
            }
            if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        } else {
            Write-Warning "'gh' CLI not found. Push succeeded; open the PR from your Git host UI."
        }
    }
} else {
    Write-Host ""
    Write-Host "Next commands to push / open Pull Request:"
    Write-Host "  git push -u origin $branchName"
    if (Test-Path $walkthroughPath) {
        Write-Host "  gh pr create --title `"$commitMsg`" --body-file `"$walkthroughPath`""
    } else {
        Write-Host "  gh pr create --title `"$commitMsg`" --fill"
    }
}
