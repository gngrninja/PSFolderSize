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
    
    if ($FolderName -eq 'all' -and $FindExtension) {

        $allFolders = Get-ChildItem -Path $BasePath -Force -Recurse | Where-Object {($_.FullName -notin $OmitFolders) -and ($_.Extension -in $FindExtension)}                

    } elseif ($folderName -eq 'all') {

        $allFolders = Get-ChildItem $BasePath -Directory -Force | Where-Object {$_.FullName -notin $OmitFolders}

    } elseif ($FolderName -ne 'all' -and $FindExtension) {

        $allFolders = Get-ChildItem -Path $BasePath -Force -Recurse | Where-Object {($_.BaseName -like $FolderName) -and ($_.FullName -notin $OmitFolders) -and ($_.Extension -in $FindExtension)}        

    } else {

        $allFolders = Get-ChildItem -Path $BasePath -Directory -Force | Where-Object {($_.BaseName -like $FolderName) -and ($_.FullName -notin $OmitFolders)}

    }

    #Test for null, return just folder if no subfolders
    $splitPath = Split-Path $BasePath
    
    if (($allFolders -eq $null) -and (Test-Path -Path $splitPath -ErrorAction SilentlyContinue)) {
        
        $findName   = Split-Path $BasePath -Leaf        
        $allFolders = Get-ChildItem -Path $splitPath -Directory | Where-Object {$_.Name -eq $findName}
                
    }

    return $allFolders

}