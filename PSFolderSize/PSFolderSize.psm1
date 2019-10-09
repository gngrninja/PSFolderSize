$Public  = @( Get-ChildItem -Path "$PSScriptRoot\Functions\Public\*.ps1" )
$Private = @( Get-ChildItem -Path "$PSScriptRoot\Functions\Private\*.ps1" )

@($Public + $Private) | ForEach-Object {

    Try {

        . $_.FullName

    } Catch {

        Write-Error -Message "Failed to import function $($_.FullName): $_"
        
    }
}

Export-ModuleMember -Function $Public.BaseName