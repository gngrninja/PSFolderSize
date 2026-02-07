BeforeAll {
    $projectRoot = Resolve-Path "$PSScriptRoot/../../../.."
    $outputModule = Join-Path $projectRoot 'output/PSFolderSize/PSFolderSize.psd1'
    $sourceModule = Join-Path $projectRoot 'PSFolderSize/PSFolderSize.psd1'
    $modulePath = if (Test-Path $outputModule) { $outputModule } else { $sourceModule }
    Get-Module PSFolderSize | Remove-Module -Force
    Import-Module $modulePath -Force
}

Describe 'Get-FolderList' {

    BeforeAll {

        $dirSeparator = [IO.Path]::DirectorySeparatorChar
        $artifactPath = "$PSscriptRoot$($dirSeparator)..$($dirSeparator)..$($dirSeparator)..$($dirSeparator)artifacts"
        $resolvedPath = Resolve-Path -Path $artifactPath

    }

    It 'Lists all folders in a directory' {

        $params = @{
            resolvedPath = $resolvedPath.ToString()
            dirSeparator = $dirSeparator
        }

        InModuleScope PSFolderSize -Parameters $params {
            $folders = $null
            $folders = Get-FolderList -FolderName 'all' -BasePath $resolvedPath
            $folders.Count | Should -Be 2

            $folders.Name | Should -Contain 'folder1'
            $folders.Name | Should -Contain 'folder2'

            $folders | Where-Object {$_.Name -eq 'folder1'} | Should -Be "$($resolvedPath)$($dirSeparator)folder1"
            $folders | Where-Object {$_.Name -eq 'folder2'} | Should -Be "$($resolvedPath)$($dirSeparator)folder2"
        }
    }

    It 'Omits folders if specified' {

        $params = @{
            resolvedPath = $resolvedPath.ToString()
            artifactPath = $artifactPath
            dirSeparator = $dirSeparator
        }

        InModuleScope PSFolderSize -Parameters $params {
            $folderToOmit = "$($resolvedPath)$($dirSeparator)folder2"
            $folders = $null
            $folders = Get-FolderList -FolderName 'all' -BasePath $artifactPath -OmitFolders $folderToOmit

            $folders.Count       | Should -Be 1
            $folders[0].Name     | Should -Be 'folder1'
            $folders[0].FullName | Should -Be "$($resolvedPath)$($dirSeparator)folder1"
            $folders[1]          | Should -BeNullOrEmpty
        }
    }

    It 'Finds file extensions if specified' {

        $params = @{
            resolvedPath = $resolvedPath.ToString()
            dirSeparator = $dirSeparator
        }

        InModuleScope PSFolderSize -Parameters $params {
            $extension = '.file'
            $folders   = $null
            $folders   = Get-FolderList -FolderName 'all' -FindExtension $extension -BasePath $resolvedPath

            $folders.Count | Should -Be 2

            $folders.FullName | Should -Contain "$($resolvedPath)$($dirSeparator)folder2$($dirSeparator)file2.file"
            $folders.FullName | Should -Contain "$($resolvedPath)$($dirSeparator)folder1$($dirSeparator)file1.file"
        }
    }

    It 'Finds specified folder name' {

        $params = @{
            resolvedPath = $resolvedPath.ToString()
        }

        InModuleScope PSFolderSize -Parameters $params {
            $folders   = $null
            $folders   = Get-FolderList -FolderName 'folder1' -BasePath $resolvedPath

            $folders.Count   | Should -Be 1
            $folders[0].Name | Should -Be 'folder1'

            $folders   = $null
            $folders   = Get-FolderList -FolderName 'folder2' -BasePath $resolvedPath

            $folders.Count   | Should -Be 1
            $folders[0].Name | Should -Be 'folder2'
        }
    }

    It 'Finds specified folder name and file extension' {

        $params = @{
            resolvedPath = $resolvedPath.ToString()
            dirSeparator = $dirSeparator
        }

        InModuleScope PSFolderSize -Parameters $params {
            $extension = '.file'

            $folders   = $null
            $folders   = Get-FolderList -FolderName 'folder1' -BasePath $resolvedPath -FindExtension $extension

            $folders.Count   | Should -Be 1
            $folders[0].FullName | Should -Be "$($resolvedPath)$($dirSeparator)folder1$($dirSeparator)file1.file"

            $folders   = $null
            $folders   = Get-FolderList -FolderName 'folder2' -BasePath $resolvedPath -FindExtension $extension

            $folders.Count   | Should -Be 1
            $folders[0].FullName | Should -Be "$($resolvedPath)$($dirSeparator)folder2$($dirSeparator)file2.file"
        }
    }

    It 'Falls back to parent directory lookup when no results' {

        $params = @{
            resolvedPath = $resolvedPath.ToString()
            dirSeparator = $dirSeparator
        }

        InModuleScope PSFolderSize -Parameters $params {
            $folderPath = "$($resolvedPath)$($dirSeparator)folder1"
            $folders = Get-FolderList -FolderName 'nonexistent_name_xyz' -BasePath $folderPath

            $folders | Should -Not -BeNullOrEmpty
            $folders.Name | Should -Contain 'folder1'
        }
    }
}
