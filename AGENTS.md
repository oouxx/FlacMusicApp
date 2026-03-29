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
make clean                # Clean build cache
make clean-derived        # Clean Xcode DerivedData
```

## API ENDPOINTS

Base URL: `https://flac.music.hi.cn`

Only these endpoints are available:

### 1. Search - `ajax.php?act=search`
```
POST /ajax.php?act=search
platform=kuwo|wyy&keyword=xxx&page=1&size=30
```

### 2. Get URL (Play/Download) - `ajax.php?act=getUrl`
```
POST /ajax.php?act=getUrl
platform=kuwo|wyy&songid=xxx&format=flac|mp3&bitrate=320|2000&time=xxx&sign=xxx
```

### 3. Get Lyric - `ajax.php?act=getLyric`
```
POST /ajax.php?act=getLyric
platform=kuwo|wyy&songid=xxx&time=xxx&sign=xxx
```

**Cookie required:** All requests need SafeLine WAF cookie (`sl-session`, `sl_jwt_session`, `sl_jwt_sign`)

**Status codes:**
- 200: Success
- 401: Unauthorized (cookie invalid)
- 468: Cookie invalid (SafeLine WAF block)

## NOTES

- **Cookie API:** Uses SafeLine WAF. Must complete challenge in WebView first.
- **Heartbeat:** 60-second interval validates cookie via search endpoint
- **Sign/Time:** Cached from search results. Required for play/download URLs.
- **XcodeGen:** Run `xcodegen generate` to regenerate .xcodeproj from project.yml.
- **No dependencies:** Pure Swift + SwiftUI. No SPM dependencies.
- **Entry points:** Platform-specific entry files excluded in project.yml:
  - macOS: FlacMusicApp_macOS.swift excluded from iOS target
  - iOS: FlacMusicApp_iOS.swift excluded from macOS target
