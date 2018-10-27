---
external help file: PSFolderSize-help.xml
Module Name: PSFolderSize
online version:
schema: 2.0.0
---

# Get-FolderSize

## SYNOPSIS
Get-FolderSize
Returns the size of folders in MB and GB.
You can change the base path, omit folders, as well as output results in various formats.

## SYNTAX

### default (Default)
```
Get-FolderSize [[-BasePath] <String[]>] [-FolderName <String[]>] [-OmitFolders <String[]>] [-AddTotal]
 [-UseRobo] [-Output <String>] [-OutputPath <String>] [-OutputFile <String>] [<CommonParameters>]
```

### outputWithType
```
Get-FolderSize [-Output <String>] [-OutputPath <String>] [<CommonParameters>]
```

## DESCRIPTION
This function will get the folder size in MB and GB of folders found in the basePath parameter. 
The basePath parameter defaults to C:\Users.
You can also specify a specific folder name via the folderName parameter.

## EXAMPLES

### EXAMPLE 1
```
Get-FolderSize | Format-Table -AutoSize
```

FolderName                Size(Bytes) Size(MB)     Size(GB)

$GetCurrent                    193768 0.18 MB      0.00 GB
$RECYCLE.BIN                 20649823 19.69 MB     0.02 GB
$SysReset                    53267392 50.80 MB     0.05 GB
Config.Msi                            0.00 MB      0.00 GB
Documents and Settings                0.00 MB      0.00 GB
Games                     48522184491 46,274.36 MB 45.19 GB

### EXAMPLE 2
```
Get-FolderSize -BasePath 'C:\Program Files'
```

FolderName                                   Size(Bytes) Size(MB)    Size(GB)

7-Zip                                            4588532 4.38 MB     0.00 GB
Adobe                                         3567833029 3,402.55 MB 3.32 GB
Application Verifier                              353569 0.34 MB     0.00 GB
Bonjour                                           615066 0.59 MB     0.00 GB
Common Files                                   489183608 466.52 MB   0.46 GB

### EXAMPLE 3
```
Get-FolderSize -BasePath 'C:\Program Files' -FolderName IIS
```

FolderName Size(Bytes) Size(MB) Size(GB)

IIS            5480411 5.23 MB  0.01 GB

### EXAMPLE 4
```
$getFolderSize = Get-FolderSize
```

$getFolderSize | Format-Table -AutoSize


FolderName Size(GB) Size(MB)

Public     0.00 GB  0.00 MB
thegn      2.39 GB  2,442.99 MB

### EXAMPLE 5
```
$getFolderSize = Get-FolderSize -Output csv -OutputPath ~\Desktop
```

$getFolderSize 


FolderName Size(GB) Size(MB)

Public     0.00 GB  0.00 MB
thegn      2.39 GB  2,442.99 MB

(Results will also be exported as a CSV to your Desktop folder)

### EXAMPLE 6
```
Sort by size descending
```

$getFolderSize = Get-FolderSize | Sort-Object 'Size(Bytes)' -Descending
$getFolderSize 


FolderName                Size(Bytes) Size(MB)     Size(GB)

Users                     76280394429 72,746.65 MB 71.04 GB
Games                     48522184491 46,274.36 MB 45.19 GB
Program Files (x86)       27752593691 26,466.94 MB 25.85 GB
Windows                   25351747445 24,177.31 MB 23.61 GB

### EXAMPLE 7
```
Omit folder(s) from being included
```

Get-FolderSize.ps1 -OmitFolders 'C:\Temp','C:\Windows'

## PARAMETERS

### -BasePath
This parameter allows you to specify the base path you'd like to get the child folders of.
It defaults to where the module was run from via (Get-Location).

```yaml
Type: String[]
Parameter Sets: default
Aliases: Path

Required: False
Position: 1
Default value: (Get-Location)
Accept pipeline input: False
Accept wildcard characters: False
```

### -FolderName
This parameter allows you to specify the name of a specific folder you'd like to get the size of.

```yaml
Type: String[]
Parameter Sets: default
Aliases: Name

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -OmitFolders
This parameter allows you to omit folder(s) (array of string) from being included

```yaml
Type: String[]
Parameter Sets: default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddTotal
This parameter adds a total count at the end of the array

```yaml
Type: SwitchParameter
Parameter Sets: default
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseRobo
{{Fill UseRobo Description}}

```yaml
Type: SwitchParameter
Parameter Sets: default
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Output
Use this option to output the results.
Valid options are csv, xml, or json.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath
Specify the path you want to use when outputting the results as a csv, xml, or json file.

Do not include a trailing slash.

Example: C:\users\you\Desktop

Defaults to (Get-Location)
This will be where you called the module from.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (Get-Location)
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputFile
This allows you to specify the path and file name you'd like for output.

Example: C:\users\you\desktop\output.csv

```yaml
Type: String
Parameter Sets: default
Aliases:

Required: False
Position: Named
Default value: [string]::Empty
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
