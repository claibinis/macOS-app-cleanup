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

### Basic Scan

```bash
# Run the cleaner script
./src/macos-app-cleanup.sh

# Show help and available options
./src/macos-app-cleanup.sh --help
```

The script will:
1. Build a list of currently installed applications
2. Scan your Library folders for potential remnants
3. Present findings with app names, companies, and sizes
4. Offer cleanup options:
   - Clean top X largest items (quick cleanup)
   - Filter by company/author
   - Review all items sorted by size
   - Save list to a file for manual review
   - Delete all found items (use with caution)
   - Exit without changes

### Baseline Feature (New!)

The baseline feature helps identify bloat added to your system after a fresh macOS install:

```bash
# Step 1: Create a baseline on a fresh system (do this once)
./src/macos-app-cleanup.sh --create-baseline

# Step 2: Later, scan for items added since the baseline
./src/macos-app-cleanup.sh --use-baseline

# List available baselines
./src/macos-app-cleanup.sh --list-baselines

# Use a specific baseline version
./src/macos-app-cleanup.sh --use-baseline 26.2
```

**How it works:**
- Create a baseline snapshot on a freshly installed system
- Baselines are version-specific (e.g., macOS 26.2 Tahoe)
- Future scans compare against the baseline to show only **new** remnants
- Ideal for identifying bloat from applications you've installed over time

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
- **Baseline Storage**: Baselines saved to `~/.config/macos-app-cleanup/baselines/`

## Current Status

**Version**: 1.1
**Status**: Stable and functional

**Recent Updates:**
- Added baseline feature for tracking bloat from fresh install
- Performance optimizations (75% faster scanning)
- Size-based sorting (largest items first)
- Enhanced cleanup modes (top X items, filter by company)

See TASKS.md for planned improvements.

## Alternative Tools

For automated app cleanup, consider [AppCleaner](https://freemacsoft.net/appcleaner/) (free).
