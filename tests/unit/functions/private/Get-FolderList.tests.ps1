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

            ($folders | Where-Object {$_.Name -eq 'folder1'}).FullName | Should -Be "$($resolvedPath)$($dirSeparator)folder1"
            ($folders | Where-Object {$_.Name -eq 'folder2'}).FullName | Should -Be "$($resolvedPath)$($dirSeparator)folder2"
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

}

Describe 'Get-FolderList wildcard matching' {

    BeforeAll {

        $wildcardRoot = Join-Path $TestDrive 'wildcard'

        foreach ($name in 'Notepad++', 'AGee', 'CMagee', 'Peter', 'Peter123', '123Peter', 'all') {
            $null = New-Item -Path (Join-Path $wildcardRoot $name) -ItemType Directory -Force
        }

        $null = New-Item -Path (Join-Path $wildcardRoot 'Notepad++/plugin.exe') -ItemType File -Force
        $null = New-Item -Path (Join-Path $wildcardRoot 'CMagee/other.exe')     -ItemType File -Force

    }

    It 'Matches a name containing regex characters without throwing (issue #24)' {

        InModuleScope PSFolderSize -Parameters @{ root = $wildcardRoot } {
            $folders = $null
            { $folders = Get-FolderList -FolderName 'Notepad++' -BasePath $root } | Should -Not -Throw
            $folders = Get-FolderList -FolderName 'Notepad++' -BasePath $root
            @($folders).Count | Should -Be 1
            $folders.Name     | Should -Be 'Notepad++'
        }
    }

    It 'Matches exactly rather than as a substring (issue #26)' {

        InModuleScope PSFolderSize -Parameters @{ root = $wildcardRoot } {
            $folders = Get-FolderList -FolderName 'AGee' -BasePath $root
            @($folders).Count | Should -Be 1
            $folders.Name     | Should -Be 'AGee'
        }
    }

    It 'Supports wildcards when asked for them' {

        InModuleScope PSFolderSize -Parameters @{ root = $wildcardRoot } {
            $folders = Get-FolderList -FolderName 'Peter*' -BasePath $root
            @($folders).Count | Should -Be 2
            $folders.Name     | Should -Contain 'Peter'
            $folders.Name     | Should -Contain 'Peter123'
            $folders.Name     | Should -Not -Contain '123Peter'
        }
    }

    It 'Accepts multiple folder names' {

        InModuleScope PSFolderSize -Parameters @{ root = $wildcardRoot } {
            $folders = Get-FolderList -FolderName 'AGee', 'CMagee' -BasePath $root
            @($folders).Count | Should -Be 2
            $folders.Name     | Should -Contain 'AGee'
            $folders.Name     | Should -Contain 'CMagee'
        }
    }

    It 'Matches case-insensitively' {

        InModuleScope PSFolderSize -Parameters @{ root = $wildcardRoot } {
            $folders = Get-FolderList -FolderName 'agee' -BasePath $root
            @($folders).Count | Should -Be 1
            $folders.Name     | Should -Be 'AGee'
        }
    }

    It 'Treats the legacy value all as every folder' {

        InModuleScope PSFolderSize -Parameters @{ root = $wildcardRoot } {
            $folders = Get-FolderList -FolderName 'all' -BasePath $root
            @($folders).Count | Should -Be 7
        }
    }

    It 'Matches folder names with regex characters in the extension branch' {

        InModuleScope PSFolderSize -Parameters @{ root = $wildcardRoot } {
            $files = Get-FolderList -FolderName 'Notepad++' -FindExtension '.exe' -BasePath $root
            @($files).Count | Should -Be 1
            $files.Name     | Should -Be 'plugin.exe'
        }
    }

    It 'Does not throw when BasePath is a filesystem root (issue #29)' {

        InModuleScope PSFolderSize -Parameters @{ root = $wildcardRoot } {
            $fsRoot = [System.IO.Path]::GetPathRoot($root)
            { Get-FolderList -FolderName 'nonexistent_name_xyz' -BasePath $fsRoot -ErrorAction Stop } | Should -Not -Throw
        }
    }
}

Describe 'Get-FolderList omit matching' {

    BeforeAll {

        $omitRoot = Join-Path $TestDrive 'omit'

        foreach ($relative in 'keep/a.log', 'skip/b.log', 'nested/skip/c.log', 'nested/keep/d.log', 'Temp Files/e.log') {
            $null = New-Item -Path (Join-Path $omitRoot $relative) -ItemType File -Force
        }

        $null = New-Item -Path (Join-Path $omitRoot 'top.txt') -ItemType File -Force

    }

    It 'Lists only directories' {

        InModuleScope PSFolderSize -Parameters @{ root = $omitRoot } {
            $folders = Get-FolderList -BasePath $root
            @($folders).Count | Should -Be 4
            $folders.Name     | Should -Not -Contain 'top.txt'
        }
    }

    It 'Omits a folder by bare name' {

        InModuleScope PSFolderSize -Parameters @{ root = $omitRoot } {
            $folders = Get-FolderList -BasePath $root -OmitFolders 'skip'
            @($folders).Count | Should -Be 3
            $folders.Name     | Should -Not -Contain 'skip'
        }
    }

    It 'Omits a folder by full path' {

        InModuleScope PSFolderSize -Parameters @{ root = $omitRoot } {
            $folders = Get-FolderList -BasePath $root -OmitFolders (Join-Path $root 'skip')
            @($folders).Count | Should -Be 3
            $folders.Name     | Should -Not -Contain 'skip'
        }
    }

    It 'Tolerates a trailing separator and forward slashes in a path' {

        InModuleScope PSFolderSize -Parameters @{ root = $omitRoot } {
            $sloppy  = ((Join-Path $root 'skip') -replace '\\', '/') + '/'
            $folders = Get-FolderList -BasePath $root -OmitFolders $sloppy
            @($folders).Count | Should -Be 3
            $folders.Name     | Should -Not -Contain 'skip'
        }
    }

    It 'Omits by path relative to BasePath' {

        InModuleScope PSFolderSize -Parameters @{ root = $omitRoot } {
            $files = Get-FolderList -BasePath $root -FindExtension '.log' -OmitFolders 'nested/skip'
            @($files).Count | Should -Be 4
            $files.Name     | Should -Not -Contain 'c.log'
            $files.Name     | Should -Contain 'b.log'

            $files = Get-FolderList -BasePath $root -FindExtension '.log' -OmitFolders '.\skip'
            @($files).Count | Should -Be 4
            $files.Name     | Should -Not -Contain 'b.log'
            $files.Name     | Should -Contain 'c.log'
        }
    }

    It 'Supports wildcards in omit entries' {

        InModuleScope PSFolderSize -Parameters @{ root = $omitRoot } {
            $folders = Get-FolderList -BasePath $root -OmitFolders 'sk*', 'Temp*'
            @($folders).Count | Should -Be 2
            $folders.Name     | Should -Contain 'keep'
            $folders.Name     | Should -Contain 'nested'
        }
    }

    It 'Omits a bare name at any depth in the extension branch' {

        InModuleScope PSFolderSize -Parameters @{ root = $omitRoot } {
            $files = Get-FolderList -BasePath $root -FindExtension '.log' -OmitFolders 'skip'
            @($files).Count | Should -Be 3
            $files.Name     | Should -Not -Contain 'b.log'
            $files.Name     | Should -Not -Contain 'c.log'
        }
    }

    It 'Omits everything below a full path in the extension branch' {

        InModuleScope PSFolderSize -Parameters @{ root = $omitRoot } {
            $files = Get-FolderList -BasePath $root -FindExtension '.log' -OmitFolders (Join-Path $root 'nested')
            @($files).Count | Should -Be 3
            $files.Name     | Should -Not -Contain 'c.log'
            $files.Name     | Should -Not -Contain 'd.log'
        }
    }

    It 'Combines FolderName and OmitFolders' {

        InModuleScope PSFolderSize -Parameters @{ root = $omitRoot } {
            $folders = Get-FolderList -BasePath $root -FolderName 'keep', 'skip' -OmitFolders 'skip'
            @($folders).Count | Should -Be 1
            $folders.Name     | Should -Be 'keep'
        }
    }
}

Describe 'Get-FolderList leaf folder fallback' {

    BeforeAll {

        $leafRoot = Join-Path $TestDrive 'leaf'
        $null = New-Item -Path (Join-Path $leafRoot 'only/file.txt') -ItemType File -Force
        $null = New-Item -Path (Join-Path $leafRoot 'other')         -ItemType Directory -Force

    }

    It 'Returns the folder itself when BasePath has no subfolders' {

        InModuleScope PSFolderSize -Parameters @{ root = $leafRoot } {
            $folders = Get-FolderList -BasePath (Join-Path $root 'only')
            @($folders).Count | Should -Be 1
            $folders.Name     | Should -Be 'only'
        }
    }

    It 'Returns nothing when FolderName matches no subfolder' {

        InModuleScope PSFolderSize -Parameters @{ root = $leafRoot } {
            Get-FolderList -BasePath $root -FolderName 'nonexistent_name_xyz' | Should -BeNullOrEmpty
        }
    }

    It 'Returns nothing when every subfolder is omitted' {

        InModuleScope PSFolderSize -Parameters @{ root = $leafRoot } {
            Get-FolderList -BasePath $root -OmitFolders 'only', 'other' | Should -BeNullOrEmpty
        }
    }

    It 'Applies FolderName and OmitFolders to the fallback folder' {

        InModuleScope PSFolderSize -Parameters @{ root = $leafRoot } {
            Get-FolderList -BasePath (Join-Path $root 'only') -FolderName 'nonexistent_name_xyz' | Should -BeNullOrEmpty
            Get-FolderList -BasePath (Join-Path $root 'only') -OmitFolders 'only'                | Should -BeNullOrEmpty
        }
    }
}
