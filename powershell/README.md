# PowerShell 7 Profile

This directory contains the PowerShell 7 profile used by this dotfiles
repository.

The top-level setup script is responsible for installing PowerShell 7.
This README describes how to attach the profile to the correct location.

------------------------------------------------------------------------

## Verify PowerShell 7 Installation

Open a new terminal and run:

``` powershell
pwsh -v
```

Expected output should show PowerShell 7.x.

Also verify:

``` powershell
$PSVersionTable
```

Ensure:

    PSEdition : Core

------------------------------------------------------------------------

## Install Required Tools (First-Time Setup)

Oh My Posh:

``` powershell
winget install JanDeDobbeleer.OhMyPosh -s winget
```

posh-git module:

``` powershell
Install-Module posh-git -Scope CurrentUser -Force
```

------------------------------------------------------------------------

## Install Profile (Copy Method)

Run inside PowerShell 7:

``` powershell
$profileDir = "$HOME\Documents\PowerShell"

New-Item -ItemType Directory -Path $profileDir -Force | Out-Null

Copy-Item `
    ".\powershell\Microsoft.PowerShell_profile.ps1" `
    "$profileDir\Microsoft.PowerShell_profile.ps1" `
    -Force
```

Restart PowerShell 7.

------------------------------------------------------------------------

## Install Profile (Recommended: Symbolic Link)

This keeps the profile directly linked to the repository.

If Developer Mode is enabled, no admin rights are required.

``` powershell
$repoPath = "<absolute-path-to-dotfiles>"

$profileDir = "$HOME\Documents\PowerShell"
New-Item -ItemType Directory -Path $profileDir -Force | Out-Null

New-Item -ItemType SymbolicLink `
    -Path "$profileDir\Microsoft.PowerShell_profile.ps1" `
    -Target "$repoPath\powershell\Microsoft.PowerShell_profile.ps1" `
    -Force
```

Restart PowerShell 7.

------------------------------------------------------------------------

## Reload Profile Without Restart

``` powershell
. $PROFILE
```

------------------------------------------------------------------------

## Profile Location

PowerShell 7 loads the profile from:

    $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

You can verify the active path with:

``` powershell
$PROFILE
```

------------------------------------------------------------------------

## CI Safety

The profile automatically skips UI enhancements when:

    $env:CI = "true"

This ensures safe usage in automation and pipeline environments.

------------------------------------------------------------------------

## Troubleshooting

If the prompt theme does not load:

``` powershell
Get-Command oh-my-posh
```

If posh-git is not available:

``` powershell
Get-Module -ListAvailable posh-git
```

If profile errors occur:

``` powershell
pwsh -NoProfile
```

Then manually inspect:

``` powershell
notepad $PROFILE
```

------------------------------------------------------------------------

## Notes

-   Designed for PowerShell 7+
-   No support for Windows PowerShell 5.1
-   Idempotent and safe for repeated execution
