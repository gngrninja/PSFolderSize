BeforeAll {
    $projectRoot = Resolve-Path "$PSScriptRoot/../../../.."
    $outputModule = Join-Path $projectRoot 'output/PSFolderSize/PSFolderSize.psd1'
    $sourceModule = Join-Path $projectRoot 'PSFolderSize/PSFolderSize.psd1'
    $modulePath = if (Test-Path $outputModule) { $outputModule } else { $sourceModule }
    Get-Module PSFolderSize | Remove-Module -Force
    Import-Module $modulePath -Force
}

Describe 'Get-FolderSize' {

    BeforeAll {

        $dirSeparator = [IO.Path]::DirectorySeparatorChar
        $artifactPath = "$PSScriptRoot$($dirSeparator)..$($dirSeparator)..$($dirSeparator)..$($dirSeparator)artifacts"
        $resolvedPath = Resolve-Path -Path $artifactPath

    }

    It 'Works with no path specified' {

        Push-Location

        Set-Location $resolvedPath

        $folderSize = $null
        $folderSize = Get-FolderSize

        Pop-Location

        $folderSize | Should -Not -BeNullOrEmpty

        $folderSize.FolderName | Should -Contain 'folder2'
        $folderSize.FolderName | Should -Contain 'folder1'

        ($folderSize | Where-Object {$_.FolderName -eq 'folder2'}).SizeBytes | Should -Be 60
        ($folderSize | Where-Object {$_.FolderName -eq 'folder1'}).SizeBytes | Should -Be 38

    }

    It 'Works with path specified' {

        $folderSize = $null
        $folderSize = Get-FolderSize -Path $resolvedPath

        $folderSize | Should -Not -BeNullOrEmpty

        $folderSize.FolderName | Should -Contain 'folder2'
        $folderSize.FolderName | Should -Contain 'folder1'

        ($folderSize | Where-Object {$_.FolderName -eq 'folder2'}).SizeBytes | Should -Be 60
        ($folderSize | Where-Object {$_.FolderName -eq 'folder1'}).SizeBytes | Should -Be 38

    }

    It 'Allows folder omission' {

        $folderSize = $null
        $folderSize = Get-FolderSize -Path $resolvedPath -OmitFolders "$($resolvedPath)$($dirSeparator)folder1"

        $folderSize | Should -Not -BeNullOrEmpty

        $folderSize.FolderName | Should -Contain 'folder2'
        $folderSize.FolderName | Should -Not -Contain 'folder1'

        ($folderSize | Where-Object {$_.FolderName -eq 'folder2'}).SizeBytes | Should -Be 60

    }

    It 'Reports zero for an empty folder instead of a stale or blank value' {

        $root = Join-Path $TestDrive 'empty-case'
        $null = New-Item -Path (Join-Path $root 'aaa_full/data.bin') -ItemType File -Value ('x' * 4096) -Force
        $null = New-Item -Path (Join-Path $root 'zzz_empty')         -ItemType Directory -Force

        $folderSize = Get-FolderSize -Path $root -AddFileTotals
        $empty      = $folderSize | Where-Object { $_.FolderName -eq 'zzz_empty' }

        $empty.SizeBytes | Should -Be 0
        $empty.SizeKB    | Should -Be 0
        $empty.SizeMB    | Should -Be 0
        $empty.SizeGB    | Should -Be 0
        $empty.FileCount | Should -Be 0

    }

    It 'Allows folder omission by name' {

        $folderSize = Get-FolderSize -Path $resolvedPath -OmitFolders 'folder1'

        $folderSize.FolderName | Should -Contain 'folder2'
        $folderSize.FolderName | Should -Not -Contain 'folder1'

    }

    It 'Filters by FolderName' {

        $folderSize = Get-FolderSize -Path $resolvedPath -FolderName 'folder1'

        $folderSize | Should -Not -BeNullOrEmpty
        $folderSize.FolderName | Should -Contain 'folder1'
        $folderSize.FolderName | Should -Not -Contain 'folder2'

    }

    It 'Adds grand total when AddTotal specified' {

        $folderSize = Get-FolderSize -Path $resolvedPath -AddTotal

        $folderSize | Should -Not -BeNullOrEmpty

        $totalRow = $folderSize | Where-Object { $_.FolderName -match 'GrandTotal' }
        $totalRow | Should -Not -BeNullOrEmpty
        $totalRow.SizeBytes | Should -Be 98

    }

    It 'Adds file totals when AddFileTotals specified' {

        $folderSize = Get-FolderSize -Path $resolvedPath -AddFileTotals

        $folderSize | Should -Not -BeNullOrEmpty

        $folder1 = $folderSize | Where-Object { $_.FolderName -eq 'folder1' }
        $folder1.FileCount | Should -Not -BeNullOrEmpty
        $folder1.FileCount | Should -BeGreaterThan 0

    }

    It 'Defaults OutputSort to SizeBytes' {

        $folderSize = Get-FolderSize -Path $resolvedPath

        $folderSize | Should -Not -BeNullOrEmpty
        $folderSize[0].SizeBytes | Should -BeGreaterOrEqual $folderSize[1].SizeBytes

    }

    It 'Exports results to CSV' {

        $csvFile = Join-Path $TestDrive 'folder-output.csv'
        Get-FolderSize -Path $resolvedPath -OutputFile $csvFile

        $csvFile | Should -Exist
        $content = Import-Csv -Path $csvFile
        $content.Count | Should -Be 2

    }
}
