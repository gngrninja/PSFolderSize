function Get-FolderList {
    [cmdletbinding()]
    param(
        [string[]]
        $FolderName,

        [string[]]
        $BasePath,

        [string[]]
        $OmitFolders,

        [string[]]
        $FindExtension
    )
    
    #All folders and look for files with a particular extension
    if ($FolderName -eq 'all' -and $FindExtension) {

        $allFolders = Get-ChildItem -Path $BasePath -Force -Recurse | 
            Where-Object {
                ($_.FullName -notin $OmitFolders) -and 
                ($_.Extension -in $FindExtension)
            }                

    #All folders
    } elseif ($FolderName -eq 'all') {

        $allFolders = Get-ChildItem $BasePath -Directory -Force | 
            Where-Object {
                $_.FullName -notin $OmitFolders
            }

    #Specified folder names and look for files with a particular extension
    } elseif ($FolderName -ne 'all' -and $FindExtension) {

        $allFolders = Get-ChildItem -Path $BasePath -Force -Recurse | 
            Where-Object {
                ($_.FullName -match ".+$FolderName.+")   -and 
                ($_.FullName -notin $OmitFolders) -and 
                ($_.Extension -in $FindExtension)
            } 
            
    } else {

        $allFolders = Get-ChildItem -Path $BasePath -Directory -Force | 
            Where-Object {
                ($_.BaseName -match "$FolderName") -and 
                ($_.FullName -notin $OmitFolders)
        }
    }

    
    $splitPath = Split-Path $BasePath
    
    #Test for null, return just folder if no subfolders
    if (!($allFolders) -and (Test-Path -Path $splitPath -ErrorAction SilentlyContinue)) {
        
        $findName   = Split-Path $BasePath -Leaf        
        $allFolders = Get-ChildItem -Path $splitPath -Directory | 
            Where-Object {
                $_.Name -eq $findName
            }
                
    }

    return $allFolders

}