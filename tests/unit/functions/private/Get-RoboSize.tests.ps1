BeforeAll {
    $projectRoot = Resolve-Path "$PSScriptRoot/../../../.."
    $outputModule = Join-Path $projectRoot 'output/PSFolderSize/PSFolderSize.psd1'
    $sourceModule = Join-Path $projectRoot 'PSFolderSize/PSFolderSize.psd1'
    $modulePath = if (Test-Path $outputModule) { $outputModule } else { $sourceModule }
    Get-Module PSFolderSize | Remove-Module -Force
    Import-Module $modulePath -Force

    $hasRobocopy = [bool](Get-Command 'robocopy' -ErrorAction SilentlyContinue)
}

Describe 'Get-RoboSize' {

    BeforeAll {

        $dirSeparator = [IO.Path]::DirectorySeparatorChar
        $artifactPath = "$PSScriptRoot$($dirSeparator)..$($dirSeparator)..$($dirSeparator)..$($dirSeparator)artifacts"
        $resolvedPath = Resolve-Path -Path $artifactPath

    }

    It 'Should return an object with bytes, mb, and gb' -Skip:(-not $hasRobocopy) {

        $params = @{
            resolvedPath = $resolvedPath.ToString()
        }

        InModuleScope PSFolderSize -Parameters $params {
            $folderSize = Get-RoboSize -Path $resolvedPath

            $folderSize.TotalBytes | Should -Be 98
            $folderSize.TotalKB    | Should -Not -BeNullOrEmpty
            $folderSize.TotalMB    | Should -Not -BeNullOrEmpty
            $folderSize.TotalGB    | Should -Not -BeNullOrEmpty
        }
    }

    It 'Should error out if robocopy is not available' {

        $params = @{
            resolvedPath = $resolvedPath.ToString()
        }

        InModuleScope PSFolderSize -Parameters $params {
            Mock Get-Command {

                return $false

            }

            {$folderSize = Get-RoboSize -Path $resolvedPath -ErrorAction Continue} | Should -Throw 'Robocopy command is not available... cannot continue!'
        }
    }

    It 'Returns null when robocopy output does not match regex' -Skip:(-not $hasRobocopy) {

        $params = @{
            resolvedPath = $resolvedPath.ToString()
        }

        InModuleScope PSFolderSize -Parameters $params {
            Mock robocopy { return 'garbage output that does not match' }

            $result = Get-RoboSize -Path $resolvedPath
            $result | Should -BeNullOrEmpty
        }
    }
}
