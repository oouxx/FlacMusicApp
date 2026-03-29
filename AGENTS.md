# PROJECT KNOWLEDGE BASE

**Generated:** 2026-03-29
**Project:** FlacMusicApp - Swift/SwiftUI music player

## OVERVIEW

Native SwiftUI app for flac.music.hi.cn. Supports macOS 14+ and iOS 17+. Uses cookie-based API authentication with SafeLine WAF.

## STRUCTURE

```
FlacMusicApp/
├── Sources/FlacMusicApp/          # Shared source code
│   ├── Models/                    # Data models (Song, AudioFormat)
│   ├── Services/                  # Business logic
│   │   ├── MusicAPIService.swift  # API requests (669 lines, largest file)
│   │   ├── PlayerManager.swift    # AVFoundation playback
│   │   ├── CookieStorage.swift    # Cookie pool (5 cookies, 10min expiry)
│   │   └── DownloadManager.wav    # File downloads
│   ├── ViewModels/                # MVVM (SearchViewModel)
│   └── Views/                     # SwiftUI views
├── FlacMusicApp-macOS/            # macOS target entry point
├── FlacMusicApp-iOS/              # iOS target entry point
├── Tests/FlacMusicAppTests/       # Tests (Swift Testing framework)
├── Makefile                       # Build system
└── project.yml                    # XcodeGen config
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| API requests | Services/MusicAPIService.swift | Cookie pool, sign/time caching |
| Playback | Services/PlayerManager.wav | AVPlayer, lyrics, progress |
| Search | ViewModels/SearchViewModel.wav | Pagination, platform switch |
| UI | Views/ContentView.wav | Tab navigation, cookie refresh |
| Tests | Tests/FlacMusicAppTests/ | Swift Testing (@Suite, @Test) |

## CONVENTIONS

- **Architecture:** MVVM (Models → ViewModels → Views)
- **State:** @StateObject, @EnvironmentObject, @Published
- **Concurrency:** async/await, weak self in closures
- **Singletons:** shared instances for services
- **Mark comments:** `// MARK: - Section Name`
- **Access:** public for services, private for internal state
- **No SwiftLint or editorconfig**

## ANTI-PATTERNS (THIS PROJECT)

- **No synchronous network calls** - always use async URLSession
- **No force unwrap** in production code
- **Avoid Thread.sleep** - use Task.sleep(nanoseconds:)
- **Don't mark cookie invalid on code=-2** - that's a sign/time error, not cookie error

## COMMANDS

```bash
# Build
make build-macos          # macOS (Debug)
make build-ios-sim        # iOS simulator
make build-all            # Both platforms
make export-macos         # Export .app (unsigned)
make export-ios           # Export .ipa (unsigned)

# Tests
swift test                # Run all tests
swift test --filter MusicAPIService  # Single test suite

# Release
make release VERSION=1.0.0  # GitHub release with changelog

# Cleanup
make clean                # Clean build cache
make clean-derived        # Clean Xcode DerivedData
```

## NOTES

- **Cookie API:** Uses SafeLine WAF. Must complete challenge in WebView first.
- **Cookie pool:** 5 cookies, 10min expiry. Background timer refreshes every 10min.
- **Sign/Time:** Cached from search results. Required for play/download URLs.
- **XcodeGen:** Run `xcodegen generate` to regenerate .xcodeproj from project.yml.
- **No dependencies:** Pure Swift + SwiftUI. No SPM dependencies.
- **Entry points:** Platform-specific entry files excluded in project.yml:
  - macOS: FlacMusicApp_macOS.wav excluded from iOS target
  - iOS: FlacMusicApp_iOS.wav excluded from macOS target