# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/).
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [1.8.0] 2026-10-02

### Changed
- `-FolderName` now uses PowerShell wildcard matching (`*`, `?`, `[...]`) instead of regular expressions.
  Names match exactly by default, so `-FolderName Peter` no longer also returns `Peter123`; use `-FolderName 'Peter*'`
  for the old substring behaviour. Note that `[` is a wildcard character, so a literal name such as `[Backup]` needs
  `[WildcardPattern]::Escape()`. Multiple names are supported, and the legacy value `all` still means every folder.
  Supersedes PR #32 (thanks @Yordanofff for the original fix).
- `-OmitFolders` accepts folder names, full paths, or paths relative to `-BasePath`, with wildcard support.
  A bare name (`node_modules`) omits any folder with that name; a path (`C:\Temp`, `.\Temp`, `C:\Temp\*`) omits that
  folder and everything below it. Forward slashes and trailing separators are tolerated. Fixes #25.
- A `-FolderName` or `-OmitFolders` filter that matches nothing now returns nothing. Previously the parent folder was
  silently reported instead. Pointing `-BasePath` at a folder with no subfolders still reports that folder itself.
- `Get-FolderSize` no longer lists top-level files as if they were folders.

### Fixed
- `-FolderName` values containing regex characters such as `Notepad++` no longer throw. Fixes #24.
- `-FolderName` no longer matches as a substring. Fixes #26.
- `Get-FolderSize` no longer fails when run from a filesystem root such as `/` on Linux and macOS. Fixes #29.
- `-OmitFolders` now works with `Get-FileReport` (it previously only matched file paths by accident).
- `Get-FileReport -AddTotal` labels the grand total with the base path instead of the last file's path.
- Empty folders now report `0` for all sizes. Previously `SizeBytes`/`SizeMB`/`SizeGB` were blank and `SizeKB` repeated the
  previous folder's value.
- Unit tests pass on Windows PowerShell 5.1 as well as PowerShell 7.

## [1.7.3] 2026-02-07

### Fixed
- Fixed Get-FileReport -AddTotal calculating incorrect totals

### Changed
- Build system migrated from psake to Invoke-Build
- CI migrated from AppVeyor/Azure Pipelines to GitHub Actions
- Expanded test coverage

## [1.7.1] 2020-10-10
### Fixed
- Fixed adding totals

## [1.7] 2020-09-16
### Changed
- Changed results to display as Bytes, SizeKB, SizeMB, and SizeGB.
  (was Size(KB), Size(MB), and Size(GB))
### Added  
- Added the ability to pre-sort output when using the -OutputFile parameter via the new parameter -OutputSort
  (supported options are FolderSize and SizeBytes)
### Fixed
- Fixed up unit tests so they work with Pester v5

## [1.6.9] 2020-03-05
### Added
- Added size in KB to results

## [1.6.8] 2019-06-05
### Fixed
- Number formatting for de-DE culture should now work properly

## [1.6.7] 2019-05-22
### Changed
- Results are now of type double, not string (for MB/GB/Byte count)
- Support for v3.0 of PowerShell, as a lot of folks that use this needed it

### Added
- Initial support for using Robocopy added, only for folders, with the -UseRobo switch

## [1.6.6] 2018-12-10
### Changed
- Adding file counts are now optional. You can add them to the results by adding the -AddFileTotals switch.
  - This will reduce performance of the script (by around 30%), until I can find a better way to calculate file totals!

## [1.6.5] 2018-12-10
### Added
- Added FileCount to results, as well as to grand total

## [1.6.4] 2018-11-28
### Added
- Added hostname to results

## [1.6.3] 2018-10-21
### Fixed

- Changed -Path to -LiteralPath so []'s aren't interpreted as wild cards

## [1.6.2] 2018-10-21
### Fixed

- Typo in description.

## [1.6.1] 2018-10-21
### Fixed

- Fixed number formatting for DE

### Added
- Added file listing under root search folder
    - The files will show up under FolderName until I figure out a better approach for this. This was added for a better GrandTotal amount when files were in the root of a folder listed.
- Added more documentation

### Changed
- Folder structure in repo, added build + tests
