properties {

    $projectRoot = $ENV:BHProjectPath

    if(-not $projectRoot) {

        $projectRoot = $PSScriptRoot

    }
    
    $tests           = "$projectRoot/tests"
    $outputDir       = Join-Path -Path $projectRoot -ChildPath 'out'
    $outputModDir    = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
    $manifest        = Import-PowerShellDataFile -Path $env:BHPSModuleManifest    
    $psVersion       = $PSVersionTable.PSVersion.Major
    $pathSeperator   = [IO.Path]::PathSeparator
    $dirSeperator    = [IO.Path]::DirectorySeparatorChar

}

task default -depends Test

task Init {
    Write-Output @"
    STATUS: Testing with PowerShell $psVersion
    
    Build System Details:
    
    $($(Get-Item ENV:BH*) | Out-String)
"@    
    
    'Pester', 'PlatyPS', 'PSScriptAnalyzer' | Foreach-Object {
        if (-not (Get-Module -Name $_ -ListAvailable -Verbose:$false -ErrorAction SilentlyContinue)) {

            Install-Module -Name $_ -Repository PSGallery -Scope CurrentUser -AllowClobber -Confirm:$false -ErrorAction Stop

        }

        Import-Module -Name $_ -Verbose:$false -Force -ErrorAction Stop
    }

} -description 'Initialize build environment'

task Test -Depends Init, Analyze, Pester -description 'Run test suite'

task Analyze -Depends Build {

    $analysis = Invoke-ScriptAnalyzer -Path "$($ENV:BHPSModulePath)\Functions" -Verbose:$false -Recurse
    $errors = $analysis | Where-Object {$_.Severity -eq 'Error'}
    $warnings = $analysis | Where-Object {$_.Severity -eq 'Warning'}

    if (($errors.Count -eq 0) -and ($warnings.Count -eq 0)) {

        Write-Output 'PSScriptAnalyzer passed without errors or warnings'

    }

    if (@($errors).Count -gt 0) {

        Write-Error -Message 'One or more Script Analyzer errors were found. Build cannot continue!'
        $errors | Format-Table

    }

    if (@($warnings).Count -gt 0) {

        Write-Warning -Message 'One or more Script Analyzer warnings were found. These should be corrected.'
        $warnings | Format-Table

    }

} -description 'Run PSScriptAnalyzer'

task Pester -Depends Build {

    if(-not $ENV:BHProjectPath) {
        Set-BuildEnvironment -Path $PSScriptRoot\..
    }

    #Remove and import module for testing
    Write-Output "Importing module from [$($ENV:BHPSModulePath)]..."

    Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue -Verbose:$false
    Import-Module -Name $ENV:BHPSModulePath -Force -Verbose:$false

    $testResultsXml = Join-Path -Path "$($projectRoot)\tests\artifacts\" -ChildPath 'testResults.xml'
    $testResults    = Invoke-Pester -Path $tests -PassThru -OutputFile $testResultsXml -OutputFormat NUnitXml

    #Upload test artifacts to AppVeyor
    if ($env:APPVEYOR_JOB_ID) {

        $wc = New-Object 'System.Net.WebClient'
        $wc.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", $testResultsXml)

    }
    
    if ($testResults.FailedCount -gt 0) {

        $testResults | Format-List
        
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'

    }

    $env:PSModulePath = $origModulePath

    Remove-Item -Path $testResultsXml -Force

} -description 'Run Pester tests'

task CreateMarkdownHelp {

    #Get functions
    Import-Module -Name $ENV:BHPSModulePath -Force -Verbose:$false -Global
    $mdHelpPath = Join-Path -Path $projectRoot -ChildPath 'docs/reference/functions'
    $mdFiles    = New-MarkdownHelp -Module $env:BHProjectName -OutputFolder $mdHelpPath -WithModulePage -Force

    Write-Output "Module markdown help created at [$mdHelpPath]"

    @($env:BHProjectName).ForEach({

        Remove-Module -Name $_ -Verbose:$false

    })

} -description 'Create initial markdown help files'

task UpdateMarkdownHelp  {

    Import-Module -Name $ENV:BHPSModulePath -Force -Verbose:$false
    $mdHelpPath = Join-Path -Path $projectRoot -ChildPath 'docs/reference/functions'
    $mdFiles = Update-MarkdownHelpModule -Path $mdHelpPath -Verbose:$false

    Write-Output `t"Markdown help updated at [$mdHelpPath]"

} -description 'Update markdown help files'

task CreateExternalHelp -Depends CreateMarkdownHelp {

    New-ExternalHelp "$projectRoot\docs\reference\functions" -OutputPath "$($ENV:BHPSModulePath)\en-US" -Force

} -description 'Create module help from markdown files'

Task RegenerateHelp -Depends UpdateMarkdownHelp, CreateExternalHelp

#CreateMarkdownHelp (add back to build)
task Build -depends CreateMarkdownHelp, CreateExternalHelp {

    # External help    
    $helpXml = New-ExternalHelp "$projectRoot\docs\reference\functions" -OutputPath (Join-Path -Path $ENV:BHPSModulePath -ChildPath 'en-US') -Force
    
    Write-Output "Module XML help created at [.helpXml]"

}

Task Publish -Depends Test {

    Write-Output "Running PSDeploy for version [$($manifest.ModuleVersion)]..."
    
    Invoke-PSDeploy -Path $projectRoot -Force

}