function Get-FolderList {
    [cmdletbinding()]
    param(
        [Parameter()]
        [SupportsWildcards()]
        [string[]]
        $FolderName = '*',

        [Parameter()]
        [string[]]
        $BasePath,

        [Parameter()]
        [SupportsWildcards()]
        [string[]]
        $OmitFolders,

        [Parameter()]
        [string[]]
        $FindExtension
    )

    begin {

        if (-not $FolderName) {

            $FolderName = '*'

        }

        #'all' was the default before wildcards were supported
        $FolderName = $FolderName -replace '^all$', '*'
        $matchAll   = $FolderName -contains '*'
        $separator  = [System.IO.Path]::DirectorySeparatorChar

        $namePatterns = [System.Collections.Generic.List[System.Management.Automation.WildcardPattern]]::new()
        $omitNames    = [System.Collections.Generic.List[System.Management.Automation.WildcardPattern]]::new()
        $omitPaths    = [System.Collections.Generic.List[System.Management.Automation.WildcardPattern]]::new()

        foreach ($pattern in $FolderName) {

            $namePatterns.Add([System.Management.Automation.WildcardPattern]::new($pattern, 'IgnoreCase'))

        }

        #A bare omit entry matches a folder name; one with a separator matches a path and everything below it
        foreach ($entry in $OmitFolders) {

            if ([string]::IsNullOrWhiteSpace($entry)) {

                continue

            }

            if ($entry -notmatch '[\\/]') {

                $omitNames.Add([System.Management.Automation.WildcardPattern]::new($entry, 'IgnoreCase'))
                continue

            }

            $omitPath = ($entry -replace '[\\/]', $separator).TrimEnd($separator)

            if ([System.IO.Path]::IsPathRooted($omitPath)) {

                $omitRoots = @($omitPath)

            } else {

                $omitPath  = $omitPath -replace "^\.$([regex]::Escape($separator))"
                $omitRoots = foreach ($base in (Convert-Path -LiteralPath $BasePath -ErrorAction SilentlyContinue)) {

                    Join-Path -Path $base -ChildPath $omitPath

                }
            }

            foreach ($omitRoot in $omitRoots) {

                $omitPaths.Add([System.Management.Automation.WildcardPattern]::new($omitRoot, 'IgnoreCase'))
                $omitPaths.Add([System.Management.Automation.WildcardPattern]::new("$omitRoot$separator*", 'IgnoreCase'))

            }
        }

        $hasOmitNames = $omitNames.Count -gt 0
        $hasOmitPaths = $omitPaths.Count -gt 0

        #Used directly as a Where-Object filter so nothing but the pattern checks runs per folder
        $folderFilter = {

            $name     = $_.Name
            $included = $matchAll

            if (-not $included) {

                foreach ($pattern in $namePatterns) {

                    if ($pattern.IsMatch($name)) { $included = $true; break }

                }
            }

            if ($included -and $hasOmitNames) {

                foreach ($pattern in $omitNames) {

                    if ($pattern.IsMatch($name)) { $included = $false; break }

                }
            }

            if ($included -and $hasOmitPaths) {

                $fullName = $_.FullName

                foreach ($pattern in $omitPaths) {

                    if ($pattern.IsMatch($fullName)) { $included = $false; break }

                }
            }

            $included
        }
    }

    process {

        if ($FindExtension) {

            #Files share directories, so the decision is made once per directory and cached
            $directoryIncluded = @{}

            $allFolders = Get-ChildItem -LiteralPath $BasePath -Force -Recurse -File |
                Where-Object {

                    if ($FindExtension -notcontains $_.Extension) { return $false }

                    $directory = $_.DirectoryName

                    if ($directoryIncluded.ContainsKey($directory)) { return $directoryIncluded[$directory] }

                    $segments = $directory.Split($separator)
                    $included = $matchAll

                    if (-not $included) {

                        :nameSearch foreach ($segment in $segments) {

                            foreach ($pattern in $namePatterns) {

                                if ($pattern.IsMatch($segment)) { $included = $true; break nameSearch }

                            }
                        }
                    }

                    if ($included -and $hasOmitNames) {

                        :omitSearch foreach ($segment in $segments) {

                            foreach ($pattern in $omitNames) {

                                if ($pattern.IsMatch($segment)) { $included = $false; break omitSearch }

                            }
                        }
                    }

                    if ($included -and $hasOmitPaths) {

                        foreach ($pattern in $omitPaths) {

                            if ($pattern.IsMatch($directory)) { $included = $false; break }

                        }
                    }

                    $directoryIncluded[$directory] = $included
                    $included
                }

        } else {

            $children   = Get-ChildItem -LiteralPath $BasePath -Force -Directory
            $allFolders = $children | Where-Object -FilterScript $folderFilter

            #A folder with no subfolders is reported as itself, so a single folder can be sized
            if (-not $children) {

                #Split-Path throws on a filesystem root in newer PowerShell versions (issue #29)
                try {

                    $parentPath = Split-Path -Path $BasePath -ErrorAction Stop

                } catch {

                    $parentPath = $null

                }

                if ($parentPath -and (Test-Path -LiteralPath $parentPath)) {

                    $leafNames  = Split-Path -Path $BasePath -Leaf
                    $allFolders = Get-ChildItem -LiteralPath $parentPath -Force -Directory |
                        Where-Object { $leafNames -contains $_.Name } |
                        Where-Object -FilterScript $folderFilter

                }
            }
        }
    }

    end {

        return $allFolders

    }
}
