# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A single-file Bash script that scans macOS systems for leftover files from deleted applications. The script identifies remnants by comparing directories in common app storage locations against currently installed applications.

## Running the Script

```bash
# Make executable (if needed)
chmod +x src/macos-app-cleanup.sh

# Run the cleaner
./src/macos-app-cleanup.sh
```

## Code Architecture

### Core Algorithm

1. **Application Discovery** (lines 106-134): Scans multiple system directories to build a list of currently installed applications, extracting both app names and bundle identifiers from Info.plist files.

2. **Remnant Detection** (lines 222-295): Scans standard macOS library locations for directories that don't match any installed application, filtering out system components using the `MACOS_SYSTEM_IDENTIFIERS` list.

3. **Interactive Cleanup** (lines 327-403): Presents found remnants with metadata and offers four cleanup modes: review-each, save-to-file, delete-all, or exit.

### Key Functions

- `is_app_installed()` (140-151): Case-insensitive matching against the installed apps list
- `is_macos_system()` (154-162): Filters system components using prefix matching
- `extract_app_metadata()` (165-220): Parses bundle identifiers and Info.plist files to extract human-readable app names and company names
- `check_location()` (23-35) and `remove_directory()` (38-45): Helper functions for directory operations

### Scanned Locations

The `LOCATIONS` array (92-103) defines where to search for remnants:
- Application Support, Caches, Preferences
- Saved Application State, Logs
- WebKit, Cookies, HTTPStorages
- Group Containers, Containers

### App Search Paths

The `APP_SEARCH_PATHS` array (108-115) defines where to look for installed apps:
- Standard /Applications directories
- System applications
- User-specific Applications
- CoreServices applications

## Important Constraints

- **Bash Version**: Written for Bash 3.2 compatibility (macOS default) - avoids modern Bash 4+ features
- **Case Sensitivity**: macOS filesystems are typically case-insensitive; the script handles this with `tr '[:upper:]' '[:lower:]'` conversions
- **Bundle ID Patterns**: Recognizes com.*, org.*, io.*, net.*, dev.* patterns for extracting company and app names
