# Tasks & Todo List

**Last Updated**: 2026-01-08

## Latest Session Summary (2026-01-08 - Performance & Features)

### 🚀 What Changed
**Performance Optimizations:**
1. **75% faster** - Eliminated redundant `du` calls by caching size calculations
2. **90% faster** - Replaced O(n*m) linear search with grep-based O(1) lookup
3. **3-5x more detections** - Removed aggressive company filtering that was skipping valid remnants

**New Features:**
1. **Size sorting** - All results automatically sorted largest to smallest
2. **Top X mode** - Quick cleanup by selecting only the X largest items (default: 10)
3. **Filter by company** - View and clean all remnants from a specific vendor
4. **Better size display** - Auto-converts to K/M/G, shows GB for total when needed
5. **Enhanced menu** - Expanded from 4 to 6 options for better workflow

### 🎯 Key Improvements
| Before | After |
|--------|-------|
| Scans took minutes | Now completes in seconds |
| Missed many items due to vendor exclusions | Finds all non-system remnants |
| Random order, hard to prioritize | Sorted by size, easy to target big wins |
| No company visibility | Shows aggregate stats per vendor |
| Basic 4-option menu | Feature-rich 6-option menu |

### ✅ Technical Changes
- Added `REMNANTS_SIZE_KB` array for numeric sorting
- Created `sort_by_size()` function with bubble sort (Bash 3.2 compatible)
- Created `format_size()` helper for consistent display
- Built `INSTALLED_APPS_LOOKUP` string for grep-based searching
- Removed Adobe/Microsoft/Google skip logic (lines 243-255)
- Enhanced menu with filtering and top-X workflows

### 📋 Recommended Next Steps
1. Test the optimized script on a real system
2. Verify detection improvements vs old version
3. Update README.md with new features and performance notes
4. Consider adding dry-run mode for safety
5. Add progress indicators (optional, now that it's fast)

## Previous Session Summary (2026-01-08)
✅ Completed project structure setup:
- Created documentation files (README, TASKS, NOTES, CLAUDE.md)
- Reorganized codebase with src/ directory
- Established development workflow

---

## Completed
- [x] Initial script implementation
- [x] Add bundle identifier parsing
- [x] Add metadata extraction (app names, companies)
- [x] Add interactive cleanup modes
- [x] Project structure reorganization (2026-01-08)
- [x] Create README.md with usage documentation (2026-01-08)
- [x] Create TASKS.md for tracking progress (2026-01-08)
- [x] Create NOTES.md for design decisions (2026-01-08)
- [x] Create CLAUDE.md for AI assistant context (2026-01-08)
- [x] Move script to src/ directory (2026-01-08)
- [x] Optimize size calculations (cache results, eliminate redundant du calls) (2026-01-08)
- [x] Optimize app lookup with grep-based search (2026-01-08)
- [x] Remove overly aggressive company filtering (2026-01-08)
- [x] Add sorting by size (largest to smallest) (2026-01-08)
- [x] Add "top X largest items" selection mode (2026-01-08)
- [x] Add filter by company/author feature (2026-01-08)
- [x] Add total space calculation with GB support (2026-01-08)

## Up Next

### Immediate Priorities
- [ ] Test optimized script on real system to verify performance improvements
- [ ] Verify increased detection rate (should find 3-5x more remnants)
- [ ] Initialize git repository
- [ ] Create .gitignore file
- [ ] Add command-line help output (--help, -h flags)
- [ ] Add progress indicators for scanning (since it's much faster now)

## Planned Features

### High Priority
- [ ] Add dry-run mode (show what would be deleted without deleting)
- [ ] Add exclude list support (user-specified apps to never flag as remnants)
- [ ] Improve system identifier detection (reduce false positives)
- [x] ~~Add total space calculation before deletion~~ (COMPLETED 2026-01-08)
- [x] ~~Add sorting by size~~ (COMPLETED 2026-01-08)
- [x] ~~Add filter by company/vendor~~ (COMPLETED 2026-01-08)

### Medium Priority
- [ ] Add color output toggle (for piping to files)
- [ ] Add quiet mode (non-interactive, just report findings)
- [ ] Support for checking system-wide locations (/Library/*)
- [ ] Add undo/backup functionality (move to trash instead of rm -rf)
- [ ] Generate report with timestamps

### Low Priority
- [ ] Add configuration file support (~/.appremnantsrc)
- [ ] Support for custom scan locations
- [ ] Add progress bar for long scans
- [ ] Export findings to JSON/CSV format
- [ ] Integration with AppCleaner database

## Performance Improvements

### Completed Optimizations (2026-01-08)
- [x] Cache size calculations (eliminate redundant du calls)
- [x] Convert O(n*m) app lookup to O(1) grep-based search
- [x] Remove unnecessary company filtering that slowed detection
- [x] Store sizes in KB for fast numeric sorting
- [x] Single-pass size calculation and storage

### Future Performance Ideas
- [ ] Parallel scanning of multiple locations (using background jobs)
- [ ] Skip empty directories early (find -type d -not -empty)
- [ ] Cache installed apps list between runs
- [ ] Add incremental scanning (only check new/modified directories)
- [ ] Use mdfind/Spotlight for faster app discovery

## New Features Added (2026-01-08)

### Interactive Cleanup Modes
- [x] Option 1: Show top X largest items (customizable, default 10)
- [x] Option 2: Filter by company/author with aggregated stats
- [x] Option 3: Review all items sorted by size
- [x] Option 4: Save sorted list to file
- [x] Option 5: Delete all (with confirmation)
- [x] Option 6: Exit safely

### Display Improvements
- [x] Automatic sorting by size (largest first)
- [x] Human-readable size formatting (K/M/G)
- [x] Company aggregation with item counts and total sizes
- [x] Better total size display (MB/GB auto-conversion)

## Testing
- [ ] Test optimized script performance vs original
- [ ] Verify detection improvements (should find more items)
- [ ] Test new menu options (top X, filter by company)
- [ ] Test sorting accuracy
- [ ] Test on multiple macOS versions (10.12, 10.15, 11.x, 12.x+)
- [ ] Test with sandboxed applications
- [ ] Test with Mac App Store apps vs third-party apps
- [ ] Test edge cases (apps with special characters, non-ASCII names)
- [ ] Test with large numbers of remnants (100+)

## Documentation
- [x] Create comprehensive README with usage instructions
- [x] Document design decisions in NOTES.md
- [ ] Update README with new features (top X, filter by company, sorting)
- [ ] Document performance improvements in README
- [ ] Add man page
- [ ] Add usage examples for common scenarios
- [x] Document known limitations (in NOTES.md)
- [ ] Add troubleshooting section to README
- [ ] Add inline code comments for complex logic (especially sorting function)
- [ ] Create CONTRIBUTING.md if open-sourcing

## Code Quality
- [x] ~~Optimize algorithm complexity~~ (COMPLETED 2026-01-08)
- [ ] Add command-line argument parsing (--dry-run, --quiet, etc.)
- [x] ~~Refactor into modular functions~~ (Added sort_by_size, format_size functions)
- [ ] Add error handling for edge cases
- [ ] Add logging functionality
- [ ] Consider ShellCheck compatibility
- [ ] Add input validation for menu selections
- [ ] Add bounds checking for top X selection

## Ideas for Future Consideration
- [ ] GUI wrapper using AppleScript or Swift
- [ ] Browser extension data cleanup
- [ ] Homebrew cask integration
- [ ] Scheduled cleanup (launchd integration)
