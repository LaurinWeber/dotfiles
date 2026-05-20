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
# Launch Rider
# ------------------------------------------------------------

function rider {

    param(
        [string]$Path = "."
    )

    $fullPath = Resolve-Path $Path

    $exe = "C:\Users\WeberLaurin\AppData\Local\Programs\Rider\bin\rider64.exe"

    if (Test-Path $exe) {

        Start-Process $exe $fullPath
    }
    else {

        Write-Warning "Rider executable not found."
    }
}

function prompt {
    $path = Split-Path -Leaf (Get-Location)

    # Tell WezTerm where we are (OSC 7) — fixes path + git in the status bar
    $cwd = (Get-Location).Path -replace '\\', '/'
    Write-Host -NoNewline "`e]7;file://${env:COMPUTERNAME}/${cwd}`e\"

    return "$path > "
}

# ------------------------------------------------------------
# Optional: Useful Aliases
# ------------------------------------------------------------

Set-Alias ll Get-ChildItem
Set-Alias g git

# ------------------------------------------------------------
# Claude Code: Multiple Subscription Profiles
# ------------------------------------------------------------

# ------------------------------------------------------------
# WezTerm: tell the bottom status bar which Claude profile is active
# ------------------------------------------------------------
function Set-WezTermClaudeProfile {
    param([string]$Profile)
    $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Profile))
    Write-Host -NoNewline "`e]1337;SetUserVar=claude_profile=$b64`e\"
}

function claudew {
    $env:CLAUDE_CONFIG_DIR = "$HOME\.claude-work"
    $host.UI.RawUI.WindowTitle = "[Claude Work]"
    Set-WezTermClaudeProfile "work"
    try {
        claude @args
    }
    finally {
        Set-WezTermClaudeProfile ""
        Remove-Item Env:\CLAUDE_CONFIG_DIR -ErrorAction SilentlyContinue
    }
    [console]::beep(1400,300)
}

function claudep {
    $env:CLAUDE_CONFIG_DIR = "$HOME\.claude-private"
    $host.UI.RawUI.WindowTitle = "[Claude Private]"
    Set-WezTermClaudeProfile "private"
    try {
        claude @args
    }
    finally {
        Set-WezTermClaudeProfile ""
        Remove-Item Env:\CLAUDE_CONFIG_DIR -ErrorAction SilentlyContinue
    }
    [console]::beep(800,300)
}

# ============================================================
# End of Profile
# ============================================================