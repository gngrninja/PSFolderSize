function Get-FolderList {
    [cmdletbinding()]
    param(
        [Parameter()]
        [string[]]
        $FolderName,

        [Parameter()]
        [string[]]
        $BasePath,

        [Parameter()]
        [string[]]
        $OmitFolders,

        [Parameter()]
        [string[]]
        $FindExtension
    )
    
    begin {

    }

    process {

        #All folders and look for files with a particular extension
        if ($FolderName -eq 'all' -and $FindExtension) {

            $allFolders = Get-ChildItem -LiteralPath $BasePath -Force -Recurse | 
                Where-Object {

                    ($OmitFolders -notcontains $_.FullName) -and 
                    ($FindExtension -contains $_.Extension)
                    
                }                

        #All folders
        } elseif ($FolderName -eq 'all') {

            $allFolders = Get-ChildItem -LiteralPath $BasePath -Force | 
                Where-Object {

                    $OmitFolders -notcontains $_.FullName

                }

        #Specified folder names and look for files with a particular extension
        } elseif ($FolderName -ne 'all' -and $FindExtension) {

            $allFolders = Get-ChildItem -LiteralPath $BasePath -Force -Recurse | 
                Where-Object {

                    ($_.FullName -match ".+$FolderName.+")   -and 
                    ($OmitFolders -notcontains $_.FullName) -and 
                    ($FindExtension -contains $_.Extension)

                } 
                
        } else {

            $allFolders = Get-ChildItem -LiteralPath $BasePath -Force | 
                Where-Object {

                    ($_.BaseName -match "$FolderName") -and 
                    ($OmitFolders -notcontains $_.FullName)

            }
        }
        
        #Test for null, return just folder if no subfolders
        $splitPath = Split-Path -Path $BasePath
        if (!($allFolders) -and (Test-Path -Path $splitPath -ErrorAction SilentlyContinue)) {
            
            $findName   = Split-Path $BasePath -Leaf        
            $allFolders = Get-ChildItem -LiteralPath $splitPath | 
                Where-Object {

                    $_.Name -eq $findName

                }
                    
        }
    }
    
    end {

        return $allFolders

    }    
}
