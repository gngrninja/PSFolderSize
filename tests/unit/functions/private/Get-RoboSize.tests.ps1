InModuleScope PSFolderSize {

    describe 'Get-RoboSize' {

        $dirSeparator = [IO.Path]::DirectorySeparatorChar
        $artifactPath = "$PSScriptRoot$($dirSeparator)..$($dirSeparator)..$($dirSeparator)..$($dirSeparator)artifacts"
        $resolvedPath = Resolve-Path -Path $artifactPath

        if (Get-Command 'robocopy' -ErrorAction SilentlyContinue) {

            it 'Should return an object with bytes, mb, and gb' {

                $folderSize = Get-RoboSize -Path $resolvedPath

                $folderSize.TotalBytes | Should Be 98
                $folderSize.TotalMB    | Should Not Be $null
                $folderSize.TotalGB    | Should Not Be $null

            }
        } 

        it 'Should error out if robocopy is not available' {

            mock Get-Command {

                return $false

            }

            {$folderSize = Get-RoboSize -Path $resolvedPath} | Should Throw 'Robocopy command is not available... cannot continue!'

        }
    }
}
