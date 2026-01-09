# macOS App Cleanup

A Bash script that helps you find and remove leftover files from deleted applications on macOS.

**GitHub**: [claibinis/macOS-app-cleanup](https://github.com/claibinis/macOS-app-cleanup)

## What It Does

When you delete an application on macOS, it often leaves behind configuration files, caches, and other data in your Library folders. This script:

1. Scans common macOS library locations for application-related directories
2. Compares them against currently installed applications
3. Identifies remnants from deleted apps
4. Helps you safely remove them through an interactive interface

## Requirements

- macOS (tested on macOS 10.12+)
- Bash 3.2+ (included with macOS)
- Standard macOS command-line tools (du, find, PlistBuddy)

## Usage

```bash
# Run the cleaner script
./src/macos-app-cleanup.sh
```

The script will:
1. Build a list of currently installed applications
2. Scan your Library folders for potential remnants
3. Present findings with app names, companies, and sizes
4. Offer cleanup options:
   - Review each item individually (recommended)
   - Save list to a file for manual review
   - Delete all found items (use with caution)
   - Exit without changes

## What Gets Scanned

The script checks these locations in your home directory:
- `~/Library/Application Support`
- `~/Library/Caches`
- `~/Library/Preferences`
- `~/Library/Saved Application State`
- `~/Library/Logs`
- `~/Library/WebKit`
- `~/Library/Cookies`
- `~/Library/HTTPStorages`
- `~/Library/Group Containers`
- `~/Library/Containers`

## Safety Features

- **System Protection**: Filters out macOS system components (com.apple.*, system.*, etc.)
- **Interactive Mode**: Default mode asks for confirmation on each item
- **Size Display**: Shows disk space used by each remnant
- **No Automatic Deletion**: Requires explicit user confirmation

## Current Status

**Version**: 1.0
**Status**: Stable and functional

The script is feature-complete for basic use. See TASKS.md for potential improvements.

## Alternative Tools

For automated app cleanup, consider [AppCleaner](https://freemacsoft.net/appcleaner/) (free).
