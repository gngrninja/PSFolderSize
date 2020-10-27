function Get-FileReport { #Begin function Get-FileReport
    [cmdletbinding(
        DefaultParameterSetName = 'default'
    )]
    param(
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'default'
        )]
        [Alias('Path')]
        [String[]]
        $BasePath = (Get-Location),        

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'default'
            
        )]
        [String[]]
        $FindExtension = @('.exe','.msi'),

        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'default'
            
        )]
        [String[]]
        $FolderName = 'all',

        [Parameter(
            ParameterSetName = 'default'
        )]
        [String[]]
        $OmitFolders,

        [Parameter(
            ParameterSetName = 'default'
        )]
        [Switch]
        $AddTotal,

        [Parameter(
            ParameterSetName = 'default'
        )]
        [Parameter(
            ParameterSetName = 'outputWithType'
        )]
        [ValidateSet('csv','xml','json')]
        [String]        
        $Output,

        [Parameter(
            ParameterSetName = 'default'
        )]
        [Parameter(
            ParameterSetName = 'outputWithType'
        )]
        [String]
        $OutputPath = (Get-Location),

        [Parameter(
            ParameterSetName = 'default'
        )]
        [String]
        $OutputFile = [string]::Empty
    )

    #Get a list of all the directories in the base path we're looking for.
    $allFolders = Get-FolderList -FolderName $FolderName -FindExtension $FindExtension -OmitFolders $OmitFolders -BasePath $BasePath

    $foundFiles = $null

    #Create list to store folder objects found with size info.
    [System.Collections.Generic.List[Object]]$fileList = @()

    #Go through each folder in the base path.
    ForEach ($file in $allFolders) {

        #Clear out the variables used in the loop.      
        $fullPath      = $null        
        $folderObject  = $null
        $fileSize      = $null
        $fileSizeInMB  = $null
        $fileSizeInGB  = $null
        $fileName      = $null

        #Store the full path to the folder and its name in separate variables
        $fullPath = $file.FullName
        $fileName = $file.BaseName     

        Write-Verbose "Working with [$fullPath]..."            

        #Get folder info / sizes
        $fileSize = $file.Length 
            
        #We use the string format operator here to show only 2 decimals, and do some PS Math.
        [double]$fileSizeInMB = "{0:N2}" -f ($fileSize / 1MB)
        [double]$fileSizeInGB = "{0:N2}" -f ($fileSize / 1GB)

        #Here we create a custom object that we'll add to the list
        $folderObject = [PSCustomObject]@{

            PSTypeName    = 'PS.File.List.Result'
            FileName      = $fileName
            SizeBytes     = $fileSize
            SizeMB        = $fileSizeInMB
            SizeGB        = $fileSizeInGB
            FullPath      = $fullPath

        }                        

        #Add the object to the list
        $fileList.Add($folderObject)

    }

    if ($AddTotal) {

        $grandTotal = $null

        if ($fileList.Count -gt 1) {
        
            $fileList | ForEach-Object {

                $grandTotal += $_.'Size(Bytes)'    

            }

            [double]$totalFolderSizeInMB = "{0:N2}" -f ($grandTotal / 1MB)
            [double]$totalFolderSizeInGB = "{0:N2}" -f ($grandTotal / 1GB)

            $folderObject = [PSCustomObject]@{

                FileName      = "GrandTotal for [$fullPath]"
                SizeBytes     = $grandTotal
                SizeMB        = $totalFolderSizeInMB
                SizeGB        = $totalFolderSizeInGB
                FullPath      = 'N/A'

            }

            #Add the object to the list
            $fileList.Add($folderObject)
        }   

    }

    if ($Output -or $OutputFile) {

        if (!$OutputFile) {

            $fileName = "{2}\{0:MMddyy_HHmm}.{1}" -f (Get-Date), $Output, $OutputPath

        } else {

            $fileName = $OutputFile
            $Output   = $fileName.Substring($fileName.LastIndexOf('.') + 1) 


        }
    
        Write-Verbose "Attempting to export results to -> [$fileName]!"

        try {

            switch ($Output) {

                'csv' {

                    $fileList | Sort-Object SizeBytes -Descending | Export-Csv -Path $fileName -NoTypeInformation -Force

                }

                'xml' {

                    $fileList | Sort-Object SizeBytes -Descending | Export-Clixml -Path $fileName

                }

                'json' {

                    $fileList | Sort-Object SizeBytes -Descending | ConvertTo-Json | Out-File -FilePath $fileName -Force

                }

            } 
        } 

        catch {

            $errorMessage = $_.Exception.Message

            Write-Error "Error exporting file to [$fileName] -> [$errorMessage]!"

        }
    
    }

    #Return the object list with the objects selected in the order specified.
    Return $fileList | Sort-Object SizeBytes -Descending

} #End function Get-FileReport
