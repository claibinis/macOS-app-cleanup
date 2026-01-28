# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A single-file Bash script that scans macOS systems for leftover files from deleted applications. The script identifies remnants by comparing directories in common app storage locations against currently installed applications.

## Running the Script

```bash
# Make executable (if needed)
chmod +x src/macos-app-cleanup.sh

# Run the cleaner (normal scan)
./src/macos-app-cleanup.sh

# Create baseline of fresh system state
./src/macos-app-cleanup.sh --create-baseline

# Run scan comparing against baseline
./src/macos-app-cleanup.sh --use-baseline

# List available baselines
./src/macos-app-cleanup.sh --list-baselines

# Show help
./src/macos-app-cleanup.sh --help
```

## Code Architecture

### Core Algorithm

1. **Application Discovery**: Scans multiple system directories (`APP_SEARCH_PATHS` array) to build a list of currently installed applications, extracting both app names and bundle identifiers from Info.plist files. Uses grep-based O(1) lookup via `INSTALLED_APPS_LOOKUP` string.

2. **Remnant Detection**: Scans standard macOS library locations (`LOCATIONS` array) for directories that don't match any installed application, filtering out system components using the `MACOS_SYSTEM_IDENTIFIERS` list. Caches size calculations in KB for performance.

3. **Interactive Cleanup**: Presents found remnants sorted by size (largest first) with metadata and offers six cleanup modes:
   - Top X largest items (quick cleanup)
   - Filter by company/author
   - Review all items sorted by size
   - Save list to file
   - Delete all (requires typing "DELETE ALL")
   - Exit without changes

### Baseline Feature

The script supports creating and using baselines to identify bloat added after a fresh macOS install:

- **Storage**: Baselines stored in `~/.config/macos-app-cleanup/baselines/`
- **Format**: Text files named `baseline-{version}.txt` (e.g., `baseline-26.2.txt`)
- **Content**: Header comments plus `location|item_name` entries for each directory
- **Comparison**: Uses grep-based O(1) lookup via `BASELINE_LOOKUP` string
- **macOS Version Detection**: `get_macos_version()` uses `sw_vers -productVersion`

### Key Functions

- `is_app_installed()`: O(1) grep-based case-insensitive matching against installed apps lookup string
- `is_macos_system()`: Filters system components using prefix matching against `MACOS_SYSTEM_IDENTIFIERS`
- `is_in_baseline()`: Checks if item existed in baseline (when baseline mode enabled)
- `extract_app_metadata()`: Parses bundle identifiers and Info.plist files to extract human-readable app names and company names
- `sort_by_size()`: Bubble sort implementation (Bash 3.2 compatible) for descending size ordering
- `format_size()`: Converts KB to human-readable K/M/G format
- `create_baseline()`: Scans all locations and saves directory names with macOS version
- `load_baseline()`: Loads baseline file into lookup string for fast comparison

### Data Arrays

The script maintains parallel arrays for remnant data:
- `REMNANTS_FOUND[]`: Directory/file names
- `REMNANTS_PATHS[]`: Full filesystem paths
- `REMNANTS_APPNAME[]`: Human-readable app names
- `REMNANTS_COMPANY[]`: Company/vendor names
- `REMNANTS_SIZE_KB[]`: Size in KB for sorting

## Important Constraints

- **Bash Version**: Written for Bash 3.2 compatibility (macOS default) - avoids modern Bash 4+ features like associative arrays
- **Case Sensitivity**: macOS filesystems are typically case-insensitive; the script handles this with `tr '[:upper:]' '[:lower:]'` conversions
- **Bundle ID Patterns**: Recognizes com.*, org.*, io.*, net.*, dev.* patterns for extracting company and app names
- **No Parallel Execution**: Avoids background jobs for Bash 3.2 compatibility
