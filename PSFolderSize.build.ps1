<#
.SYNOPSIS
    Invoke-Build script for PSFolderSize module.
#>

param(
    [string]$NuGetApiKey
)

$ModuleName = 'PSFolderSize'
$SourcePath = "$PSScriptRoot/$ModuleName"
$OutputPath = "$PSScriptRoot/output/$ModuleName"

task Clean {
    if (Test-Path -Path "$PSScriptRoot/output") {
        Remove-Item -Path "$PSScriptRoot/output" -Recurse -Force
    }
}

task Build {
    # Create output directory structure
    $null = New-Item -Path $OutputPath -ItemType Directory -Force

    # Gather source files
    $privateFunctions = @(Get-ChildItem -Path "$SourcePath/Functions/Private/*.ps1" -ErrorAction SilentlyContinue)
    $publicFunctions  = @(Get-ChildItem -Path "$SourcePath/Functions/Public/*.ps1" -ErrorAction SilentlyContinue)

    # Build compiled .psm1 by concatenating private then public functions
    $psm1Content = @()
    foreach ($file in $privateFunctions) {
        $psm1Content += Get-Content -Path $file.FullName -Raw
        $psm1Content += ""
    }
    foreach ($file in $publicFunctions) {
        $psm1Content += Get-Content -Path $file.FullName -Raw
        $psm1Content += ""
    }

    # Add Export-ModuleMember for public functions
    $publicNames = $publicFunctions | ForEach-Object { $_.BaseName }
    $exportLine = "Export-ModuleMember -Function @('{0}')" -f ($publicNames -join "','")
    $psm1Content += $exportLine

    $psm1Content -join "`n" | Set-Content -Path "$OutputPath/$ModuleName.psm1" -Encoding utf8 -Force

    # Copy manifest and format file
    Copy-Item -Path "$SourcePath/$ModuleName.psd1" -Destination $OutputPath -Force
    Copy-Item -Path "$SourcePath/$ModuleName.Format.ps1xml" -Destination $OutputPath -Force

    Write-Build Green "Module built to $OutputPath"
}

task Analyze {
    $analysis = Invoke-ScriptAnalyzer -Path "$SourcePath/Functions" -Recurse -Verbose:$false
    $errors   = $analysis | Where-Object { $_.Severity -eq 'Error' }
    $warnings = $analysis | Where-Object { $_.Severity -eq 'Warning' }

    if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
        Write-Build Green 'PSScriptAnalyzer passed without errors or warnings'
    }

    if (@($warnings).Count -gt 0) {
        Write-Build Yellow 'PSScriptAnalyzer warnings:'
        $warnings | Format-Table -AutoSize
    }

    if (@($errors).Count -gt 0) {
        $errors | Format-Table -AutoSize
        throw 'PSScriptAnalyzer found errors. Build cannot continue.'
    }
}

task Test {
    $pesterConfig = New-PesterConfiguration
    $pesterConfig.Run.Path = "$PSScriptRoot/tests"
    $pesterConfig.Run.Exit = $true
    $pesterConfig.TestResult.Enabled = $true
    $pesterConfig.TestResult.OutputPath = "$PSScriptRoot/output/testResults.xml"
    $pesterConfig.TestResult.OutputFormat = 'NUnitXml'
    $pesterConfig.Output.Verbosity = 'Detailed'

    Invoke-Pester -Configuration $pesterConfig
}

task Publish {
    if (-not $NuGetApiKey) {
        throw 'NuGetApiKey is required to publish. Pass -NuGetApiKey or set $env:PSGALLERY_API_KEY.'
    }

    Publish-Module -Path $OutputPath -NuGetApiKey $NuGetApiKey -Repository PSGallery -Force
    Write-Build Green "Module published to PSGallery"
}

# Default task
task . Clean, Build, Analyze, Test
