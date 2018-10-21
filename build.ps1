[cmdletbinding(
    DefaultParameterSetName = 'task'
)]
param(
    [parameter(
        ParameterSetName = 'task', 
        Position = 0
    )]
    [string[]]
    $Task = 'default',

    [parameter(
        ParameterSetName = 'help'
    )]
    [switch]
    $Help,

    [switch]
    $UpdateModules
)

function Resolve-Module {
    [Cmdletbinding()]
    param (
        [Parameter(
            Mandatory, 
            ValueFromPipeline
        )]
        [string[]]
        $Name,

        [switch]
        $UpdateModules
    )

    begin {
        Get-PackageProvider -Name Nuget -ForceBootstrap -Verbose:$false | Out-Null
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -Verbose:$false

        $PSDefaultParameterValues = @{

            '*-Module:Verbose'            = $false
            'Install-Module:ErrorAction'  = 'Stop'
            'Install-Module:Force'        = $true
            'Install-Module:Scope'        = 'CurrentUser'
            'Install-Module:Verbose'      = $false
            'Install-Module:AllowClobber' = $true
            'Import-Module:ErrorAction'   = 'Stop'
            'Import-Module:Verbose'       = $false
            'Import-Module:Force'         = $true

        }
    }

    process {
        $Name | ForEach-Object {

            $versionToImport = $null
            $moduleName      = $null
            $moduleName      = $_
            
            Write-Verbose -Message "Resolving Module [$($moduleName)]"

            if ($Module = Get-Module -Name $moduleName -ListAvailable -Verbose:$false) {

                #Get local ver and PSGallery ver
                $latestLocalVersion   = ($Module | Measure-Object -Property Version -Maximum).Maximum
                $latestGalleryVersion = (
                    Find-Module -Name $moduleName -Repository PSGallery |
                        Measure-Object -Property Version -Maximum
                    ).Maximum

                #Check if out of date
                if ($latestLocalVersion -lt $latestGalleryVersion) {
                    if ($UpdateModules) {

                        Write-Verbose -Message "$($moduleName) installed version [$($latestLocalVersion.ToString())] is outdated. Installing gallery version [$($latestGalleryVersion.ToString())]"

                        if ($UpdateModules) {

                            Write-Verbose "Updating module [$moduleName] from [$latestLocalVersion] to [$latestGalleryVersion]"
                            
                            Install-Module -Name $moduleName -RequiredVersion $latestGalleryVersion
                            $versionToImport = $latestGalleryVersion

                        }
                    } else {

                        Write-Warning "$($moduleName) is out of date. Latest version on PSGallery is [$latestGalleryVersion]. To update, use the -UpdateModules switch."

                    }
                } else {

                    $versionToImport = $latestLocalVersion

                }
            } else {

                Write-Verbose -Message "[$($moduleName)] missing. Installing..."

                Install-Module -Name $moduleName -Repository PSGallery
                $versionToImport = (
                        Get-Module -Name $moduleName -ListAvailable | 
                            Measure-Object -Property Version -Maximum
                        ).Maximum

            }

            Write-Verbose -Message "$($moduleName) installed. Importing..."

            if (-not [string]::IsNullOrEmpty($versionToImport)) {

                Import-module -Name $moduleName -RequiredVersion $versionToImport

            } else {

                Import-module -Name $moduleName

            }
        }
    }
}

'BuildHelpers', 'psake', 'PSDeploy' | Resolve-Module -UpdateModules:($PSBoundParameters.ContainsKey('UpdateModules'))

if ($PSBoundParameters.ContainsKey('help')) {

    Get-PSakeScriptTasks -buildFile "$PSScriptRoot\psake.ps1" |
        Sort-Object -Property Name                            |
        Format-Table -Property Name, Description, Alias, DependsOn

} else {

    Set-BuildEnvironment -Force

    Invoke-psake -buildFile "$PSScriptRoot\psake.ps1" -taskList $Task -nologo -Verbose:($VerbosePreference -eq 'Continue')
    
    if ($psake.build_success -eq $false) {exit 1 } else { exit 0 }

}
