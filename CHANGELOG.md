# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- added check that required programs are well available
- Improved portability of `mtt_sync.sh` script by replacing absolute paths with relative paths based on script location
- Added script directory detection to make installation location independent

## [0.0.5] - 2024-04-14

### Breaking Changes
- Renamed scripts for better clarity and consistency

### Added
- Added support for deleted tasks
- Added debug options for better troubleshooting
- Added more test coverage

### Changed
- Improved script hardening and robustness

## [0.0.4] - 2024-04-07

### Added
- Added support for dependencies between tasks
- Added "project" parameter to mtt_sync
- Added first 3 tests on import, automatically run via GitHub actions

### Changed
- Improved documentation in main README.md

## [0.0.3] - 2024-04-03

### Added
- Added global mtt_sync script

### Changed
- Improved logging style
- Various fixes and improvements

## [0.0.2] - 2024-03-29

### Fixed
- Fixed issues with hook
- Fixed handling of @ tags

### Changed
- Improved documentation

## [0.0.1] - 2024-03-28

### Added
- Initial release
- Basic functionality for syncing between Obsidian and Taskwarrior

