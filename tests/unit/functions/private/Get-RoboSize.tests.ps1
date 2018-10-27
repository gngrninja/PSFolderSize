InModuleScope PSFolderSize {

    describe 'Get-RoboSize' {

        $dirSeparator = [IO.Path]::DirectorySeparatorChar
        $artifactPath = "$PSScriptRoot$($dirSeparator)..$($dirSeparator)..$($dirSeparator)..$($dirSeparator)artifacts"
        $resolvedPath = Resolve-Path -Path $artifactPath


        if (Get-Command 'robocopy' -ErrorAction SilentlyContinue) {

            it 'Should return an object with bytes, mb, and gb' {

                $folderSize = Get-RoboSize -Path $resolvedPath

                $folderSize.TotalBytes | should not be $null
                $folderSize.TotalMB    | should not be $null
                $folderSize.TotalGB    | should not be $null

            }

        } 

        it 'Should error out if robocopy is not available' {

            mock Get-Command {

                return $false

            }

            {$folderSize = Get-RoboSize -Path $resolvedPath} | should throw 'Robocopy command is not available... cannot continue!'


        }
    }
}
