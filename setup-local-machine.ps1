# Developer Setup Script for Windows
# Run this script as Administrator (required for some installs like Docker)

# List of apps to install via Winget
$apps = @(
    "Microsoft.VisualStudioCode",
    "Git.Git",
    "Docker.DockerDesktop",
    "PuTTY.PuTTY",
    "OpenJS.NodeJS",
    "Microsoft.DotNet.SDK.8",
    "Microsoft.DotNet.SDK.9",
    "Bruno.Bruno",
    "JGraph.Draw",
    "Google.Chrome",
    "Mozilla.Firefox",
    "Bitdefender.Bitdefender",
    "Bitwarden.Bitwarden"
    )

foreach ($app in $apps) {
    Write-Host "`nInstalling: $app"
    winget install --id=$app --silent --accept-package-agreements --accept-source-agreements
}

# Install JetBrains Toolbox (used to install Rider)
Write-Host "`nInstalling JetBrains Toolbox (for Rider)..."
winget install JetBrains.Toolbox --silent --accept-package-agreements --accept-source-agreements

Write-Host "`nPlease install JetBrains Rider manually via the Toolbox app once it's installed."

# Install Next.js globally via npm
Write-Host "`nInstalling Next.js via npm..."
npm install -g create-next-app

# Adobe Creative Cloud notice
Write-Host "`nAdobe Creative Cloud must be installed manually:"
Write-Host "Download it here: https://creativecloud.adobe.com/apps/download/creative-cloud"

# Final message
Write-Host "`n✅ Setup complete. A system restart is recommended"