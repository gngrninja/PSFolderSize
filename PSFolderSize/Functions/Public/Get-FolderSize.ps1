function Get-FolderSize {
    <#
    .SYNOPSIS

    Get-FolderSize
    Returns the size of folders in MB and GB.
    You can change the base path, omit folders, as well as output results in various formats.

    .DESCRIPTION

    This function will get the folder size in MB and GB of folders found in the basePath parameter. 
    The BasePath parameter defaults to the current directory.

    .PARAMETER BasePath

    This parameter allows you to specify the base path you'd like to get the child folders of.
    It defaults to where the module was run from via (Get-Location).

    .PARAMETER FolderName

    This parameter allows you to specify the name of a specific folder you'd like to get the size of.

    .PARAMETER AddTotal

    This parameter adds a total count at the end of the array

    .PARAMETER OmitFolders

    This parameter allows you to omit folder(s) (array of string) from being included

    .PARAMETER Output

    Use this option to output the results. Valid options are csv, xml, or json

    .PARAMETER OutputPath

    Specify the path you want to use when outputting the results as a csv, xml, or json file

    Do not include a trailing slash

    Example: C:\users\you\Desktop

    Defaults to (Get-Location)
    This will be where you called the module from

    .PARAMETER OutputFile

    This allows you to specify the path and file name you'd like for output
    
    Example: C:\users\you\desktop\output.csv

    .PARAMETER OutputSort

    This allows you to specify what you'd like to sort by for the csv/json/xml output. 

    Valid options are FolderSize and SizeBytes

    .PARAMETER AddFileTotals

    This parameter allows you to add file totals to the results
    Note: This will reduce performance of the script by around 30%!

    .PARAMETER IgnoreLinks

    This parameter defaults to true, set to false if you want to include sym/hard links for some reason
    Note: This will add to the total in an unexpected way (including the link target's total)

    .EXAMPLE 

    Get-FolderSize | Format-Table -AutoSize


    FolderName                SizeBytes SizeMB     SizeGB
   
    $GetCurrent                    193768 0.18 MB      0.00 GB
    $RECYCLE.BIN                 20649823 19.69 MB     0.02 GB
    $SysReset                    53267392 50.80 MB     0.05 GB
    Config.Msi                            0.00 MB      0.00 GB
    Documents and Settings                0.00 MB      0.00 GB
    Games                     48522184491 46,274.36 MB 45.19 GB

    .EXAMPLE 

    Get-FolderSize -BasePath 'C:\Program Files'
    

    FolderName                                   SizeBytes SizeMB    SizeGB

    7-Zip                                            4588532 4.38 MB     0.00 GB
    Adobe                                         3567833029 3,402.55 MB 3.32 GB
    Application Verifier                              353569 0.34 MB     0.00 GB
    Bonjour                                           615066 0.59 MB     0.00 GB
    Common Files                                   489183608 466.52 MB   0.46 GB

    .EXAMPLE 

    Get-FolderSize -BasePath 'C:\Program Files' -FolderName IIS


    FolderName SizeBytes SizeMB SizeGB
  
    IIS            5480411 5.23 MB  0.01 GB

    .EXAMPLE

    $getFolderSize = Get-FolderSize 
    $getFolderSize | Format-Table -AutoSize


    FolderName SizeGB SizeMB
  
    Public     0.00 GB  0.00 MB
    thegn      2.39 GB  2,442.99 MB

    .EXAMPLE

    $getFolderSize = Get-FolderSize -Output csv -OutputPath ~\Desktop
    $getFolderSize 
  

    FolderName SizeGB SizeMB
    
    Public     0.00 GB  0.00 MB
    thegn      2.39 GB  2,442.99 MB

    (Results will also be exported as a CSV to your Desktop folder)

    .EXAMPLE

    Sort by size descending 
    $getFolderSize = Get-FolderSize | Sort-Object SizeBytes -Descending
    $getFolderSize 


    FolderName                SizeBytes SizeMB     SizeGB

    Users                     76280394429 72,746.65 MB 71.04 GB
    Games                     48522184491 46,274.36 MB 45.19 GB
    Program Files (x86)       27752593691 26,466.94 MB 25.85 GB
    Windows                   25351747445 24,177.31 MB 23.61 GB

    .EXAMPLE

    Omit folder(s) from being included 
    Get-FolderSize.ps1 -OmitFolders 'C:\Temp','C:\Windows'

    .EXAMPLE

    Add file counts for each folder
    Note: This will slow down the execution of the script by around 30%
    
    $results = Get-FolderSize -AddFileTotal

    PS /Users/ninja/Documents/repos/PSFolderSize> $results[0] | Format-List *

    FolderName  : .git
    SizeBytes   : 228591
    SizeMB      : 0.22
    SizeGB      : 0.00
    FullPath    : /Users/ninja/Documents/repos/PSFolderSize/.git
    HostName    : njambp.local
    FileCount   : 382

    #>
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
        [Alias('Name')]
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
        [Switch]
        $AddFileTotals,        

        [Parameter(
            ParameterSetName = 'default'
        )]
        [Switch]
        $UseRobo,

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
        [Parameter(
            ParameterSetName = 'outputWithType'
        )]
        [ValidateSet('FolderName','SizeBytes')]
        [String]
        $OutputSort,

        [Parameter(
            ParameterSetName = 'default'
        )]
        [String]
        $OutputFile = [string]::Empty,

        [Parameter(
            ParameterSetName = 'default'
        )]
        [Boolean]
        $IgnoreLinks = $true
    )

    begin {

        #Add default for OutputSort
        if ([string]::IsNullOrEmpty($OutputSort)) {

            $OutputSort = 'SizeBytes'

        }

        #Get a list of all the directories in the base path we're looking for.
        if ($IgnoreLinks) {

            $allFolders = Get-FolderList -FolderName $FolderName -OmitFolders $OmitFolders -BasePath $BasePath | Where-Object {!$_.LinkType}

        } else {

            $allFolders = Get-FolderList -FolderName $FolderName -OmitFolders $OmitFolders -BasePath $BasePath

        }
        
        #Create list to store folder objects found with size info.
        [System.Collections.Generic.List[Object]]$folderList = @()

        #Get hostname
        $hostName = [System.Net.Dns]::GetHostByName((hostname)).HostName
        
    }

    process  {

        #Go through each folder in the base path.
        $allFolders | ForEach-Object {

            #Clear out the variables used in the loop.
            $folder            = $null
            $fullPath          = $null
            $folderInfo        = $null        
            $folderObject      = $null
            $folderSize        = $null
            $folderSizeInBytes = $null
            $folderSizeInMB    = $null
            $folderSizeInGB    = $null
            $folderBaseName    = $null
            $totalFiles        = $null

            $folder = $_

            #Store the full path to the folder and its name in separate variables
            $fullPath       = $folder.FullName
            $folderBaseName = $folder.BaseName     

            Write-Verbose "Working with [$fullPath]..."            

            #Get folder info / sizes
            if ($UseRobo) {

                $folderSize        = Get-RoboSize -Path $fullPath -DecimalPrecision 2

                $folderSizeInBytes = $folderSize.TotalBytes
                $folderSizeInKB    = [math]::Round($folderSize.TotalKB, 2)
                $folderSizeInMB    = [math]::Round($folderSize.TotalMB, 2)
                $folderSizeInGB    = [math]::Round($folderSize.TotalGB, 2)

            } else {

                if ($IgnoreLinks) {

                    $folderInfo = Get-Childitem -LiteralPath $fullPath -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {!$_.LinkType}
                
                } else {

                    $folderInfo = Get-Childitem -LiteralPath $fullPath -Recurse -Force -ErrorAction SilentlyContinue
                
                }
                 
                $folderSize = $folderInfo | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue       

                #We use the string format operator here to show only 2 decimals, and do some PS Math.            
                if ($folderSize.Sum) {

                    $folderSizeInBytes = $folderSize.Sum
                    $folderSizeInKB    = [math]::Round($folderSize.Sum / 1KB, 2)
                    $folderSizeInMB    = [math]::Round($folderSize.Sum / 1MB, 2)
                    $folderSizeInGB    = [math]::Round($folderSize.Sum / 1GB, 2)

                }
            }

            #Here we create a custom object that we'll add to the list
            $folderObject = [PSCustomObject]@{

                PSTypeName    = 'PS.Folder.List.Result'
                FolderName    = $folderBaseName
                SizeBytes     = $folderSizeInBytes
                SizeKB        = $folderSizeInKB               
                SizeMB        = $folderSizeInMB
                SizeGB        = $folderSizeInGB
                FullPath      = $fullPath            
                HostName      = $hostName

            }                        

            #Add file totals if switch is true
            if ($AddFileTotals) {

                $totalFiles = ($folderInfo | Where-Object {!$_.PSIsContainer}).Count
                $folderObject | Add-Member -MemberType NoteProperty -Name FileCount -Value $totalFiles

            }

            #Add the object to the list
            $folderList.Add($folderObject)

            }

        if ($AddTotal) {

            $grandTotal      = $null
            $grandTotalFiles = $null

            if ($folderList.Count -gt 1) {

                $folderList | ForEach-Object {
                    
                    if ($_.SizeBytes -gt 0) {

                        $grandTotal += $_.SizeBytes

                    }                  
                }

                $totalFolderSizeInKB = [math]::Round($grandTotal / 1KB, 2)
                $totalFolderSizeInMB = [math]::Round($grandTotal / 1MB, 2)
                $totalFolderSizeInGB = [math]::Round($grandTotal / 1GB, 2)

                $folderObject = [PSCustomObject]@{

                    PSTypeName    = 'PS.Folder.List.Result'
                    FolderName    = "GrandTotal for [$BasePath]"
                    SizeBytes     = $grandTotal
                    SizeKB        = $totalFolderSizeInKB
                    SizeMB        = $totalFolderSizeInMB
                    SizeGB        = $totalFolderSizeInGB
                    FullPath      = 'N/A'                
                    HostName      = $hostName

                }
            }

            if ($AddFileTotals) {

                $folderList | ForEach-Object {

                    $grandTotalFiles += $_.FileCount   

                }

                $folderObject  | 
                    Add-Member -MemberType NoteProperty -Name FileCount -Value $grandTotalFiles

            }

            #Add the object to the list
            $folderList.Add($folderObject)

        }   
    }
    
    end {

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
        
                        $folderList | Sort-Object $OutputSort -Descending | Export-Csv -Path $fileName -NoTypeInformation -Force
        
                    }
        
                    'xml' {
        
                        $folderList | Sort-Object $OutputSort -Descending | Export-Clixml -Path $fileName
        
                    }
        
                    'json' {
        
                        $folderList | Sort-Object $OutputSort -Descending | ConvertTo-Json | Out-File -FilePath $fileName -Force
        
                    }
        
                } 
            } 
    
            catch {
    
                $errorMessage = $_.Exception.Message
    
                Write-Error "Error exporting file to [$fileName] -> [$errorMessage]!"
    
            }
          
        }
    
        #Return the object array with the objects selected in the order specified
        Return $folderList | Sort-Object SizeBytes -Descending

    }    
}
