# Development Notes & Decisions

## Session Log

### 2026-01-08: Project Structure Setup
- Reorganized project into standard structure
- Created documentation files (README, TASKS, NOTES)
- Moved script to `src/` directory
- Created CLAUDE.md for AI assistant context

**Decisions Made:**
- Keep single-file script architecture for simplicity and portability
- Use `src/` directory even for single file to allow for future expansion
- Maintain Bash 3.2 compatibility (macOS default, no Homebrew required)

---

## Design Decisions

### Bundle Identifier Parsing
**Decision**: Support multiple TLD patterns (com.*, org.*, io.*, net.*, dev.*)

**Rationale**: Different companies use different naming conventions. Supporting multiple patterns ensures broader compatibility.

**Impact**: Lines 189-203, 261-270

### System Identifier Filtering
**Decision**: Use prefix-based filtering with comprehensive list of macOS system components

**Rationale**: Prevents false positives that could lead to deleting system files. Better to be conservative and miss some remnants than to flag system components.

**List Location**: Lines 54-86 (MACOS_SYSTEM_IDENTIFIERS array)

### Case-Insensitive Matching
**Decision**: Convert all app names to lowercase for comparison

**Rationale**: macOS filesystems are typically case-insensitive (HFS+/APFS default), and apps may have inconsistent casing between bundle IDs and display names.

**Implementation**: Lines 144-145 using `tr '[:upper:]' '[:lower:]'`

### Interactive Default Mode
**Decision**: Make review-each-item mode the default recommendation (option 1)

**Rationale**: Safety first. Users should consciously decide what to delete rather than bulk operations.

**Alternative Modes Provided**:
- Save to file (for documentation/review)
- Delete all (for advanced users who trust the scan)
- Exit without changes

---

## Known Limitations

### Not Detected
- LaunchAgents/LaunchDaemons in ~/Library/LaunchAgents
- Login items
- Browser extensions
- Shell configuration modifications (.bashrc, .zshrc additions)
- System-wide remnants in /Library/ (requires sudo)

### Potential False Positives
- Apps from well-known companies that may still be installed but named differently
- Development tools that use unusual bundle ID patterns
- Apps installed in non-standard locations

### Compatibility
- Requires macOS-specific tools (PlistBuddy, standard Unix utilities)
- Assumes standard macOS directory structure
- May not work correctly on case-sensitive filesystems (rare on macOS)

---

## Future Architecture Considerations

### If Expanding to Multiple Files:
```
src/
  ├── macos-app-cleanup.sh       # Main entry point
  ├── lib/
  │   ├── scanner.sh             # App discovery & scanning logic
  │   ├── parser.sh              # Bundle ID & metadata parsing
  │   ├── ui.sh                  # Interactive prompts & display
  │   └── config.sh              # Configuration loading
  └── config/
      └── system_identifiers.txt  # External config for system IDs
```

**Benefits**: Better organization, easier testing, modular updates
**Tradeoffs**: Loses single-file portability, more complex execution

**Current Decision**: Keep single-file until complexity warrants refactor

---

## Testing Notes

### Manual Testing Checklist:
- [ ] Test with fresh macOS installation
- [ ] Test after removing popular apps (Chrome, Slack, Discord)
- [ ] Test with sandboxed Mac App Store apps
- [ ] Verify system components are properly filtered
- [ ] Check output formatting on different terminal widths
- [ ] Test with spaces and special characters in app names

### Edge Cases to Consider:
- App installed but in non-standard location
- Multiple versions of same app
- Apps with identical bundle ID prefixes
- Renamed or moved applications
- Symlinked application bundles

---

## Resources & References

### macOS File System Structure
- [Apple File System Programming Guide](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/)
- Standard Library locations: ~/Library vs /Library
- Bundle identifier conventions

### Shell Scripting Best Practices
- Bash 3.2 compatibility (macOS ships with old Bash due to GPL v3)
- Use of `set -e` for error handling
- Array usage in Bash 3.2 (limited compared to 4.x)

### Related Tools
- AppCleaner: GUI alternative for app cleanup
- CleanMyMac: Commercial comprehensive cleanup tool
- Homebrew Cask: Package manager with uninstall support
