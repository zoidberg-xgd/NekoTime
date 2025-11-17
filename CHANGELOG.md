# Changelog

All notable changes to NekoTime will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0] - 2025-11-18

### Fixed
- **Critical**: Application freeze/hang issue causing macOS force quit dialog
  - Root cause: High-frequency debug logging triggered every second
  - Root cause: Repeated window operations in `ClockScreen` build method
  - Solution: Removed all per-second debug logging
  - Solution: Added configuration state caching to prevent redundant window updates
  - Solution: Only update window properties when configuration actually changes

### Changed
- Optimized UI rendering performance
  - Removed excessive logging in `TimeDisplay` widget
  - Removed frequent logging in `DigitGifV2` widget
  - Kept error logs for debugging purposes
- Improved window management
  - Window size only updates when theme or scale changes
  - Opacity only updates when value changes
  - Prevented duplicate `addPostFrameCallback` calls

### Performance
- Reduced main thread load by eliminating high-frequency I/O operations
- Minimized unnecessary `setState` calls
- Optimized state comparison logic

## [2.0.0] - 2025-11-18

### Added
- **Modular theme system** with package-based structure
- **Built-in Frosted Glass theme** included with application
- **Complete logging system**
  - File-based logging with automatic rotation (5MB limit, 3 backups)
  - In-app log viewer with real-time display
  - Multiple log levels: DEBUG, INFO, WARNING, ERROR
- **Multi-format image support** for digits
  - Supported formats: GIF, PNG, JPG, JPEG, WebP, BMP
  - Automatic format detection
- **Double-click to hide** functionality
- **Tray menu enhancements**
  - Quick show/hide toggle
  - Theme reload button
  - Log viewer access
- **Developer tools**
  - Log viewer dialog
  - Open theme folder
  - Open logs directory
- Comprehensive theme development documentation
  - `themes/THEME_GUIDE.md` - Complete theme development guide
  - `themes/README.md` - Theme usage instructions
  - `themes/example_mod/README.md` - Example theme documentation

### Fixed
- **Infinite rebuild loop** causing digits to disappear after theme switch
  - Root cause: `setState` in `ensureFontsLoaded()` triggering endless rebuilds
  - Solution: Added theme loading cache (`_lastLoadedThemeId`)
  - Solution: Load fonts only once when theme ID changes
- **Window scaling ratio** issues
  - Fixed incorrect aspect ratio during scaling
  - Optimized window size calculation

### Changed
- **Display compactness improvements**
  - Digit width: `0.75 → 0.6` (20% more compact)
  - Colon width: `0.4 → 0.3` (25% more compact)
  - Built-in theme padding: `16/8 → 12/8`
  - Example theme digit spacing: `8-10 → 2` (75% reduction)
- Theme resource loading now automatic
- Backward compatible with legacy single-file themes

### Performance
- Font loading cache mechanism prevents duplicate loads
- GIF animation state preservation using `AutomaticKeepAliveClientMixin`
- Stable keys for `StreamBuilder` and widgets
- Reduced unnecessary widget rebuilds

## [1.0.0] - 2025-11-18

### Added
- Initial release
- Cross-platform desktop clock (macOS, Windows, Linux)
- System-level window transparency
- Blur/frosted glass effects
- Draggable and lockable window
- Three-layer window management (Desktop/Normal/Top)
- Scale adjustment (0.75x - 2.0x)
- Opacity control (10% - 100%)
- System tray integration
- Basic theme support
- Internationalization (Chinese/English)
- Configuration persistence

---

## Migration Guide

### From v1.x to v2.0

**Theme Structure Changes**

Old structure (still supported):
```
themes/
├── my_theme.json
└── gif/
    └── ...
```

New structure (recommended):
```
themes/
└── my_theme/
    ├── theme.json
    └── digits/
        └── ...
```

**Configuration Changes**

- Added `digit.gifPath` and `digit.format` fields
- Added `padding.preset` for quick padding configuration
- Added `blur.sigmaX` and `blur.sigmaY` for blur effects

### From v2.0 to v2.1

No breaking changes. This is a performance optimization release focused on fixing the application freeze issue.

---

## Notes

### Performance Considerations

- v2.1.0 significantly improves stability by eliminating performance bottlenecks
- Debug logging has been reduced; use the log viewer for troubleshooting
- Window operations are now intelligent and cached

### Theme Development

- See `themes/THEME_GUIDE.md` for complete documentation
- Use `example_mod` theme as a template
- All theme resources are relative to theme root directory

### Known Limitations

- Colon (`:`) uses text rendering, custom image not yet supported
- Theme changes require manual reload

---

**Project Repository**: https://github.com/zoidberg-xgd/NekoTime

[Unreleased]: https://github.com/zoidberg-xgd/NekoTime/compare/v2.1.0...HEAD
[2.1.0]: https://github.com/zoidberg-xgd/NekoTime/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/zoidberg-xgd/NekoTime/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/zoidberg-xgd/NekoTime/releases/tag/v1.0.0
