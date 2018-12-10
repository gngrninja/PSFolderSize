# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/).
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased] 

### Adding
- Ability to use wildcards if looking for files
- Ability to find file with a particular extension
- Ability to use robocopy if specified

### Changing
- Adding tests/official support for Get-FileReport

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