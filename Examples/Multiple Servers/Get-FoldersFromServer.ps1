#In this example we will import a server list, and then use the module to get the folder size for each server in the list

#Let's create an array to store all the results in
[System.Collections.ArrayList]$resultsArray = @()

#The base path we want to use will be set here
$basePath = 'c$'

#Import the servers from a text file
$servers = Get-Content -Path "$PSScriptRoot\servers.txt"

#Import the module - be sure to change this path to where the psd1 file is on your machine
#Not needed if you already have the module imported
Import-Module -Name C:\path\to\PSFolderSize.psd1

foreach ($server in $servers) {
    
    $curPath       = $null
    $result        = $null

    #This will be the path we pass to the module
    $curPath = "\\$server\$basePath"

        Write-Verbose "Working with [$curPath]!"
        
        if (Test-Path -Path $curPath) {

            $result = Get-FolderSize -BasePath $curPath -AddTotal

            if ($result) {
    
                #Add the basepath as a property, so we can sort by it later if needed
                $result | Add-Member -MemberType NoteProperty -Name "BasePath" -Value $curPath 

            }  

        } else {

            #If we can't access the path, let it be known in the result
            $result = [PSCustomObject]@{

                BasePath = $curPath
                Result   = "Unable to access path [$curPath]!"

            }
        }    

        if (!$result) {

            #If for some reason we still don't have a result object, create one to spread the word
            $result = [PSCustomObject]@{

                BasePath     = $curPath
                Result       = "No results!"

            }

        }        
 
        #Add our result object to the array
        $resultsArray.Add($result) | Out-Null

}

#Example of exporting combined results as CSV

#Flatten array
$combined = $resultsArray | ForEach-Object {$_}

#Export combined array
$combined | Export-Csv -Path ("{1}\results_{0:MMddyy_HHmm}.csv" -f (Get-Date), $PSScriptRoot) -NoTypeInformation -Force

#Return results array
return $resultsArray
