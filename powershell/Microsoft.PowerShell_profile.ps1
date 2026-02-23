# ============================================================
# PowerShell 7 Profile
# ============================================================

# ------------------------------------------------------------
# Skip UI enhancements in CI environments
# ------------------------------------------------------------
if ($env:CI -eq "true") {
    return
}

# ------------------------------------------------------------
# Oh My Posh (Powerlevel10k Rainbow Theme)
# ------------------------------------------------------------
$ompTheme = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes\powerlevel10k_rainbow.omp.json"

$omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue
if ($omp -and (Test-Path $ompTheme)) {
    oh-my-posh init pwsh --config $ompTheme | Invoke-Expression
}

# ------------------------------------------------------------
# posh-git (if installed for pwsh)
# ------------------------------------------------------------
if (Get-Module -ListAvailable posh-git) {
    Import-Module posh-git
}

# ------------------------------------------------------------
# PSReadLine Enhancements
# ------------------------------------------------------------
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine

    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

# ------------------------------------------------------------
# GitKraken launcher
# ------------------------------------------------------------
function kraken {
    $repo = git rev-parse --show-toplevel 2>$null
    if (-not $repo) {
        Write-Warning "Not inside a Git repository."
        return
    }

    $exe = Get-ChildItem "$env:LOCALAPPDATA\gitkraken\app-*\gitkraken.exe" -ErrorAction SilentlyContinue |
           Sort-Object LastWriteTime |
           Select-Object -Last 1

    if ($exe) {
        Start-Process $exe.FullName "--path `"$repo`""
    }
    else {
        Write-Warning "GitKraken executable not found."
    }
}

# ------------------------------------------------------------
# Git clean helper
# ------------------------------------------------------------
function gitclean {
    git clean -d -x -f -f -e .vs -e *.user
}

# ------------------------------------------------------------
# Launch Total Commander in current directory
# ------------------------------------------------------------
function t {
    $tc = "C:\Program Files\totalcmd\TOTALCMD64.EXE"
    if (Test-Path $tc) {
        $path = (Get-Location).Path
        Start-Process $tc "/O /L=$path"
    }
}

# ------------------------------------------------------------
# Launch Notepad++
# ------------------------------------------------------------
function npp {
    $exe = "C:\Program Files (x86)\Notepad++\notepad++.exe"

    if (Test-Path $exe) {
        if ($args.Count -eq 0) {
            Start-Process $exe
        }
        else {
            Start-Process $exe -ArgumentList $args
        }
    }
}

# ------------------------------------------------------------
# Optional: Useful Aliases
# ------------------------------------------------------------
Set-Alias ll Get-ChildItem
Set-Alias g git

# ============================================================
# End of Profile
# ============================================================