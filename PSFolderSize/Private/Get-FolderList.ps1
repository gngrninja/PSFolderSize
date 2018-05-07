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

        $allFolders = Get-ChildItem $BasePath -Force -Recurse | Where-Object {($_.FullName -notin $OmitFolders) -and ($_.Extension -in $FindExtension)}                

    } elseif ($folderName -eq 'all') {

        $allFolders = Get-ChildItem $BasePath -Directory -Force | Where-Object {$_.FullName -notin $OmitFolders}

    } elseif ($FolderName -ne 'all' -and $FindExtension) {

        $allFolders = Get-ChildItem $BasePath -Force -Recurse | Where-Object {($_.BaseName -like $FolderName) -and ($_.FullName -notin $OmitFolders) -and ($_.Extension -in $FindExtension)}        

    } else {

        $allFolders = Get-ChildItem $BasePath -Directory -Force | Where-Object {($_.BaseName -like $FolderName) -and ($_.FullName -notin $OmitFolders)}

    }

    return $allFolders

}