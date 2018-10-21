InModuleScope PSFolderSize {

    describe 'Get-FolderList' {

        $dirSeparator = [IO.Path]::DirectorySeparatorChar
        $artifactPath = "$PSScriptRoot$($dirSeparator)..$($dirSeparator)..$($dirSeparator)..$($dirSeparator)artifacts"
        $resolvedPath = Resolve-Path -Path $artifactPath      

        it 'Lists all folders in a directory' {
            
            $resolvedPath = Resolve-Path -Path $artifactPath  
            $folders = $null
            $folders = Get-FolderList -FolderName 'all' -BasePath $resolvedPath
                        
            $folders.Count | Should Be 2
           

            switch ($PSVersionTable.PSEdition) {

                'Desktop' {                    

                    $folders.Name -contains 'folder1' | Should Be $true
                    $folders.Name -contains 'folder2' | Should Be $true

                    $folders | Where-Object {$_.Name -eq 'folder1'} | Should Be 'folder1'
                    $folders | Where-Object {$_.Name -eq 'folder2'} | Should Be 'folder2'

                }

                'Core' {                    

                    $folders.Name | Should Contain 'folder1'
                    $folders.Name | Should Contain 'folder2'

                    $folders | Where-Object {$_.Name -eq 'folder1'} | Should Be "$($resolvedPath)$($dirSeparator)folder1"
                    $folders | Where-Object {$_.Name -eq 'folder2'} | Should Be "$($resolvedPath)$($dirSeparator)folder2"
         
                }
            }                                    
        }

        it 'Omits folders if specified' {

            $folderToOmit = "$($resolvedPath)$($dirSeparator)folder2"
            $folders = $null
            $folders = Get-FolderList -FolderName 'all' -BasePath $artifactPath -OmitFolders $folderToOmit

            $folders.Count       | Should Be 1
            $folders[0].Name     | Should Be 'folder1'
            $folders[0].FullName | Should Be "$($resolvedPath)$($dirSeparator)folder1"
            $folders[1]          | Should Be $null
 
        }

        it 'Finds file extensions if specified' {

            $extension = '.file'
            $folders   = $null
            $folders   = Get-FolderList -FolderName 'all' -FindExtension $extension -BasePath $resolvedPath
                        
            $folders.Count       | Should Be 2

            switch ($PSVersionTable.PSEdition) {

                'Desktop' {                    

                    $folders.FullName -contains "$($resolvedPath)$($dirSeparator)folder2$($dirSeparator)file2.file" | Should Be $true
                    $folders.FullName -Contains "$($resolvedPath)$($dirSeparator)folder1$($dirSeparator)file1.file" | Should Be $true

                }

                'Core' {                    

                    $folders.FullName | Should Contain "$($resolvedPath)$($dirSeparator)folder2$($dirSeparator)file2.file"
                    $folders.FullName | Should Contain "$($resolvedPath)$($dirSeparator)folder1$($dirSeparator)file1.file"

                }
            }
        }

        it 'Finds specified folder name' {

            $folders   = $null
            $folders   = Get-FolderList -FolderName 'folder1' -BasePath $resolvedPath

            $folders.Count   | Should Be 1
            $folders[0].Name | Should Be 'folder1'

            $folders   = $null
            $folders   = Get-FolderList -FolderName 'folder2' -BasePath $resolvedPath

            $folders.Count   | Should Be 1
            $folders[0].Name | Should Be 'folder2'

        }

        it 'Finds specified folder name and file extension' {

            $extension = '.file'

            $folders   = $null
            $folders   = Get-FolderList -FolderName 'folder1' -BasePath $resolvedPath -FindExtension $extension

            $folders.Count   | Should Be 1
            $folders[0].FullName | Should Be "$($resolvedPath)$($dirSeparator)folder1$($dirSeparator)file1.file"

            $folders   = $null
            $folders   = Get-FolderList -FolderName 'folder2' -BasePath $resolvedPath -FindExtension $extension
            
            $folders.Count   | Should Be 1
            $folders[0].FullName | Should Be "$($resolvedPath)$($dirSeparator)folder2$($dirSeparator)file2.file"

        }
    }
}