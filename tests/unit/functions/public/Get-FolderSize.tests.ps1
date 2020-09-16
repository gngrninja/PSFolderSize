InModuleScope PSFolderSize {

    describe 'Get-FolderSize' {

        BeforeAll {

            $dirSeparator = [IO.Path]::DirectorySeparatorChar
            $artifactPath = "$PSScriptRoot$($dirSeparator)..$($dirSeparator)..$($dirSeparator)..$($dirSeparator)artifacts"
            $resolvedPath = Resolve-Path -Path $artifactPath

        }

        it 'Works with no path specified' {

            Push-Location

            Set-Location $resolvedPath

            $folderSize = $null
            $folderSize = Get-FolderSize 

            Pop-Location

            $folderSize | Should -Not -BeNullOrEmpty

            switch ($PSVersionTable.PSEdition) {

                'Desktop' {                    

                    $folderSize.FolderName -Contains 'folder2' | Should -BeTrue
                    $folderSize.FolderName -Contains 'folder1' | Should -BeTrue   

                }

                'Core' {                    

                    $folderSize.FolderName  | Should -Contain 'folder2'
                    $folderSize.FolderName  | Should -Contain 'folder1'        

                }
            }

            ($folderSize | Where-Object {$_.FolderName -eq 'folder2'}).SizeBytes | Should -Be 60
            ($folderSize | Where-Object {$_.FolderName -eq 'folder1'}).SizeBytes | Should -Be 38

        }

        it 'Works with path specified' {

            $folderSize = $null
            $folderSize = Get-FolderSize -Path $resolvedPath 

            $folderSize | Should -Not -BeNullOrEmpty

            switch ($PSVersionTable.PSEdition) {

                'Desktop' {                    

                    $folderSize.FolderName -contains 'folder2' | Should -BeTrue
                    $folderSize.FolderName -contains 'folder1' | Should -BeTrue

                }

                'Core' {                    

                    $folderSize.FolderName | Should -Contain 'folder2'
                    $folderSize.FolderName | Should -Contain 'folder1'
        
                }
            }

            ($folderSize | Where-Object {$_.FolderName -eq 'folder2'}).SizeBytes | Should -Be 60
            ($folderSize | Where-Object {$_.FolderName -eq 'folder1'}).SizeBytes | Should -Be 38

        }

        it 'Allows folder omission' {

            $folderSize = $null
            $folderSize = Get-FolderSize -Path $resolvedPath -OmitFolders "$($resolvedPath)$($dirSeparator)folder1"

            $folderSize | Should -Not -BeNullOrEmpty

            switch ($PSVersionTable.PSEdition) {

                'Desktop' {                    

                    $folderSize.FolderName -contains 'folder2'    | Should -BeTrue
                    $folderSize.FolderName -notcontains 'folder1' | Should -BeTrue

                }

                'Core' {                    

                    $folderSize.FolderName | Should -Contain 'folder2'
                    $folderSize.FolderName | Should -Not -Contain 'folder1'
        
                }
            }

            ($folderSize | Where-Object {$_.FolderName -eq 'folder2'}).SizeBytes | Should -Be 60
  
        }
    }
}
