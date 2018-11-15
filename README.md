[![Build status](https://ci.appveyor.com/api/projects/status/dc0dfydghko3jck5/branch/master?svg=true)](https://ci.appveyor.com/project/gngrninja/psfoldersize/branch/master) [![Build Status](https://dev.azure.com/ginja/PSFolderSize/_apis/build/status/PSFolderSize-CI)](https://dev.azure.com/ginja/PSFolderSize/_build/latest?definitionId=3)
[![Documentation Status](https://readthedocs.org/projects/psfoldersize/badge/?version=latest)](https://psfoldersize.readthedocs.io/en/latest/?badge=latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[![PSFolderSize](https://static1.squarespace.com/static/5644323de4b07810c0b6db7b/t/5bcc1e9e419202a53790e662/1540103847317/PSFolderSize.png)](https://www.gngrninja.com/script-ninja/2016/5/24/powershell-calculating-folder-sizes)

# PowerShell -> Get Folder Sizes
This module enables you to gather folder size information, and output the results in various ways.

Article for this repository is here:
https://www.gngrninja.com/script-ninja/2016/5/24/powershell-calculating-folder-sizes

## Getting Started

Install via the [PowerShell Gallery](https://www.powershellgallery.com/packages/PSFolderSize/):

```powershell
Install-Module PSFolderSize
```

If you manually cloned/downloaded the code:

```powershell
Import-Module .\path\to\PSFolderSize.psd1
```

-or-

```powershell
Import-Module .\path\to\FolderModuleFilesAreIn
```

Once it is imported, use...

```powershell
Get-Help Get-FolderSize -Detailed 
```
...to get all the help goodness.

Check out the Examples folder for example(s) on how to use the module.

There's only one for now, with more to come!

*Leave an issue here if you have some feedback, issues, or questions.*
