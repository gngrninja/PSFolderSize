BeforeAll {
    $projectRoot = Resolve-Path "$PSScriptRoot/../../../.."
    $outputModule = Join-Path $projectRoot 'output/PSFolderSize/PSFolderSize.psd1'
    $sourceModule = Join-Path $projectRoot 'PSFolderSize/PSFolderSize.psd1'
    $modulePath = if (Test-Path $outputModule) { $outputModule } else { $sourceModule }
    Get-Module PSFolderSize | Remove-Module -Force
    Import-Module $modulePath -Force
}

Describe 'Get-FileReport' {

    BeforeAll {

        $dirSeparator = [IO.Path]::DirectorySeparatorChar
        $artifactPath = "$PSScriptRoot$($dirSeparator)..$($dirSeparator)..$($dirSeparator)..$($dirSeparator)artifacts"
        $resolvedPath = Resolve-Path -Path $artifactPath

    }

    It 'Returns file results with custom extension' {

        $results = Get-FileReport -BasePath $resolvedPath -FindExtension '.file'

        $results | Should -Not -BeNullOrEmpty
        $results.Count | Should -Be 2

        $results[0].PSObject.TypeNames | Should -Contain 'PS.File.List.Result'

        $results.FileName | Should -Contain 'file1'
        $results.FileName | Should -Contain 'file2'

    }

    It 'Works with default BasePath (Get-Location)' {

        Push-Location
        Set-Location $resolvedPath

        $results = Get-FileReport -FindExtension '.file'

        Pop-Location

        $results | Should -Not -BeNullOrEmpty
        $results.FileName | Should -Contain 'file1'
        $results.FileName | Should -Contain 'file2'

    }

    It 'Filters by FolderName' {

        $results = Get-FileReport -BasePath $resolvedPath -FindExtension '.file' -FolderName 'folder1'

        $results | Should -Not -BeNullOrEmpty
        $results.FileName | Should -Contain 'file1'
        $results.FileName | Should -Not -Contain 'file2'

    }

    It 'Omits folders when specified' {

        $folderToOmit = "$($resolvedPath)$($dirSeparator)folder1$($dirSeparator)file1.file"
        $results = Get-FileReport -BasePath $resolvedPath -FindExtension '.file' -OmitFolders $folderToOmit

        $results | Should -Not -BeNullOrEmpty
        $results.FileName | Should -Contain 'file2'
        $results.FileName | Should -Not -Contain 'file1'

    }

    It 'Adds grand total when AddTotal specified' {

        $results = Get-FileReport -BasePath $resolvedPath -FindExtension '.file' -AddTotal

        $results | Should -Not -BeNullOrEmpty
        $results.Count | Should -Be 3

        $totalRow = $results | Where-Object { $_.FileName -match 'GrandTotal' }
        $totalRow | Should -Not -BeNullOrEmpty
        $totalRow.SizeBytes | Should -Be 98

    }

    It 'Does not add total for single file result' {

        $results = Get-FileReport -BasePath $resolvedPath -FindExtension '.file' -FolderName 'folder1' -AddTotal

        $results | Should -Not -BeNullOrEmpty
        $results.Count | Should -Be 1

        $totalRow = $results | Where-Object { $_.FileName -match 'GrandTotal' }
        $totalRow | Should -BeNullOrEmpty

    }

    It 'Exports results to CSV' {

        $csvFile = Join-Path $TestDrive 'test-output.csv'
        Get-FileReport -BasePath $resolvedPath -FindExtension '.file' -OutputFile $csvFile

        $csvFile | Should -Exist
        $content = Import-Csv -Path $csvFile
        $content.Count | Should -Be 2

    }

    It 'Exports results to JSON' {

        $jsonFile = Join-Path $TestDrive 'test-output.json'
        Get-FileReport -BasePath $resolvedPath -FindExtension '.file' -OutputFile $jsonFile

        $jsonFile | Should -Exist
        $content = Get-Content -Path $jsonFile -Raw | ConvertFrom-Json
        $content.Count | Should -Be 2

    }

    It 'Exports results to XML' {

        $xmlFile = Join-Path $TestDrive 'test-output.xml'
        Get-FileReport -BasePath $resolvedPath -FindExtension '.file' -OutputFile $xmlFile

        $xmlFile | Should -Exist
        $content = Import-Clixml -Path $xmlFile
        $content.Count | Should -Be 2

    }

    It 'Uses OutputFile when specified' {

        $csvFile = Join-Path $TestDrive 'custom-name.csv'
        Get-FileReport -BasePath $resolvedPath -FindExtension '.file' -OutputFile $csvFile

        $csvFile | Should -Exist

    }

    It 'Returns results sorted by SizeBytes descending' {

        $results = Get-FileReport -BasePath $resolvedPath -FindExtension '.file'

        $results.Count | Should -Be 2
        $results[0].SizeBytes | Should -BeGreaterOrEqual $results[1].SizeBytes

    }
}
