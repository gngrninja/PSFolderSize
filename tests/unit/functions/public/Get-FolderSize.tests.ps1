InModuleScope PSFolderSize {

    describe 'Get-FolderSize' {

        $dirSeparator = [IO.Path]::DirectorySeparatorChar
        $artifactPath = "$PSScriptRoot$($dirSeparator)..$($dirSeparator)..$($dirSeparator)..$($dirSeparator)artifacts"
        $resolvedPath = Resolve-Path -Path $artifactPath

        it 'Works with no path specified' {

            Push-Location

            Set-Location $resolvedPath
            $folderSize = $null
            $folderSize = Get-FolderSize 

            Pop-Location

            $folderSize                  | Should Not Be $Null
            $folderSize[0].FolderName    | Should Be 'folder2'
            $folderSize[0].'Size(Bytes)' | Should Be 60
            $folderSize[1].FolderName    | Should Be 'folder1'
            $folderSize[1].'Size(Bytes)' | Should Be 38

        }

        it 'Works with path specified' {

            $folderSize = $null
            $folderSize = Get-FolderSize -Path $resolvedPath 

            $folderSize                  | Should Not Be $Null
            $folderSize[0].FolderName    | Should Be 'folder2'
            $folderSize[0].'Size(Bytes)' | Should Be 60
            $folderSize[1].FolderName    | Should Be 'folder1'
            $folderSize[1].'Size(Bytes)' | Should Be 38

        }

        it 'Allows folder omission' {

            $folderSize = $null
            $folderSize = Get-FolderSize -Path $resolvedPath -OmitFolders 'folder1'

            $folderSize                  | Should Not Be $Null
            $folderSize[0].FolderName    | Should Be 'folder2'
            $folderSize[0].'Size(Bytes)' | Should Be 60
            $folderSize[1].FolderName    | Should Be 'folder1'
            $folderSize[1].'Size(Bytes)' | Should Be 38

        }
    }
}
