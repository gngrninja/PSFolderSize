InModuleScope PSFolderSize {

    describe 'Get-RoboSize' {

        BeforeAll {

            $dirSeparator = [IO.Path]::DirectorySeparatorChar
            $artifactPath = "$PSScriptRoot$($dirSeparator)..$($dirSeparator)..$($dirSeparator)..$($dirSeparator)artifacts"
            $resolvedPath = Resolve-Path -Path $artifactPath            

        }

        if (Get-Command 'robocopy' -ErrorAction SilentlyContinue) {

            it 'Should return an object with bytes, mb, and gb' {

                $folderSize = Get-RoboSize -Path $resolvedPath

                $folderSize.TotalBytes | Should -Be 98
                $folderSize.TotalKB    | Should -Not -BeNullOrEmpty
                $folderSize.TotalMB    | Should -Not -BeNullOrEmpty
                $folderSize.TotalGB    | Should -Not -BeNullOrEmpty

            }
        } 

        it 'Should error out if robocopy is not available' {

            mock Get-Command {

                return $false

            }
            
            {$folderSize = Get-RoboSize -Path $resolvedPath -ErrorAction Continue} | Should -Throw 'Robocopy command is not available... cannot continue!'
            
        }
    }
}
