<#
.SYNOPSIS
    Bootstrap script that installs build dependencies and invokes the build.
.PARAMETER Task
    The Invoke-Build task(s) to run. Defaults to the default task (Clean, Build, Analyze, Test).
.PARAMETER NuGetApiKey
    API key for publishing to the PowerShell Gallery.
#>
[CmdletBinding()]
param(
    [string[]]$Task,

    [string]$NuGetApiKey = $env:PSGALLERY_API_KEY
)

# Ensure PSResourceGet is available for dependency installation
if (-not (Get-Command 'Install-PSResource' -ErrorAction SilentlyContinue)) {
    Write-Host 'Installing Microsoft.PowerShell.PSResourceGet...' -ForegroundColor Cyan
    Install-Module -Name Microsoft.PowerShell.PSResourceGet -Force -Scope CurrentUser -AllowClobber
}

# Install required modules from RequiredModules.psd1
$requiredModules = Import-PowerShellDataFile -Path "$PSScriptRoot/RequiredModules.psd1"

foreach ($moduleName in $requiredModules.Keys) {
    $requiredVersion = $requiredModules[$moduleName]
    $installed = Get-Module -Name $moduleName -ListAvailable |
        Where-Object { $_.Version -ge [version]$requiredVersion }

    if (-not $installed) {
        Write-Host "Installing $moduleName $requiredVersion..." -ForegroundColor Cyan
        Install-PSResource -Name $moduleName -Version $requiredVersion -Scope CurrentUser -TrustRepository
    }

    Import-Module -Name $moduleName -MinimumVersion $requiredVersion -Force
}

# Run Invoke-Build
$ibParams = @{}
if ($Task)        { $ibParams['Task'] = $Task }
if ($NuGetApiKey) { $ibParams['NuGetApiKey'] = $NuGetApiKey }

Invoke-Build @ibParams -File "$PSScriptRoot/PSFolderSize.build.ps1"
