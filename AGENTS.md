# PROJECT KNOWLEDGE BASE

**Generated:** 2026-04-01
**Project:** FlacMusicApp - Swift/SwiftUI music player

## OVERVIEW

Native SwiftUI app for flac.music.hi.cn. Supports macOS 14+ and iOS 17+. Uses cookie-based API authentication with SafeLine WAF. Zero third-party dependencies.

## STRUCTURE

```
FlacMusicApp/
├── Sources/FlacMusicApp/          # Shared source code
│   ├── Models/                    # Data models
│   │   └── Song.swift             # Song, AudioFormat, DownloadTask, API response models
│   ├── Services/                  # Business logic
│   │   ├── MusicAPIService.swift  # API requests, heartbeat, sign/time cache, cookie mgmt
│   │   ├── CookieStorage.swift    # Cookie persistence (UserDefaults)
│   │   ├── AudioCacheManager.swift # Playback cache (1GB LRU, FileManager)
│   │   ├── PlayerManager.swift    # AVFoundation playback, prefetch, silent sign refresh
│   │   ├── PlaylistManager.swift  # Queue management, shuffle order, play modes
│   │   └── DownloadManager.swift  # User-initiated downloads, progress via KVO
│   ├── ViewModels/
│   │   └── SearchViewModel.swift  # Search, debounce, pagination, silent sign refresh
│   └── Views/
│       ├── ContentView.swift      # App state machine, launch flow, cookie verification
│       ├── CookieWebView.swift    # CookieWebView, SilentCookieWebView, CookieVerificationSheet
│       ├── CacheSettingsView.swift # Cache size display and clear
│       ├── SearchView.swift       # Search UI
│       ├── DownloadsView.swift    # Downloads UI
│       ├── PlayerView.swift       # Player bar + lyrics
│       ├── LyricsParser.swift     # LRC parser
│       └── QueueView.swift        # Playback queue UI
├── FlacMusicApp-macOS/            # macOS target entry point
├── FlacMusicApp-iOS/              # iOS target entry point
├── Tests/FlacMusicAppTests/       # Tests (Swift Testing framework)
├── Makefile                       # Build system (305 lines)
└── project.yml                    # XcodeGen config
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| API requests | Services/MusicAPIService.swift | Heartbeat, sign/time caching, cookie pool |
| Playback | Services/PlayerManager.swift | AVPlayer, cache hit/miss, prefetch, silent retry |
| Playback cache | Services/AudioCacheManager.swift | 1GB LRU, meta persisted as JSON |
| Playlist | Services/PlaylistManager.swift | Queue, shuffle order, play modes, nextSong |
| Search | ViewModels/SearchViewModel.swift | Debounce, pagination, silent sign refresh every 5min |
| Launch flow | Views/ContentView.swift | AppState machine, optimistic launch, sheet verification |
| WebView | Views/CookieWebView.swift | Three components: visible, silent, sheet |
| Downloads | Services/DownloadManager.swift | KVO progress, cache reuse |
| Tests | Tests/FlacMusicAppTests/ | Swift Testing (@Suite, @Test) |

## ARCHITECTURE

Standard MVVM, no third-party dependencies:

```
Views → ViewModels → Services → Models
```

### Cookie / Launch Flow

```
App launch
 ├── hasValidCookie → optimistic enter main UI (300ms delay)
 │     └── background heartbeat (60s interval)
 │           ├── valid → no-op ✅
 │           └── invalid → show CookieVerificationSheet (bottom sheet)
 └── no cookie → launch screen + SilentCookieWebView loads in background
                  └── onCookiesReady → fade into main UI
```

### Playback Cache Flow

```
play(song)
 ├── AudioCacheManager.cachedURL hit → local playback (zero network) ✅
 └── miss → stream remote URL
             ├── background Task: downloadToTemp → cache.store()
             └── after success: prefetchNextSongURL() in background
```

### Sign Refresh Flow

```
getSongURL fails (sign expired)
 └── silentRefreshSign(): searchSongs() → updates signCache
       ├── found → retry playCurrentSong(retryCount: 1) ✅
       └── not found → stop() + show error

SearchViewModel: scheduleSilentRefresh() every 5min after successful search
  → searchSongs() in background, only updates signCache, does NOT replace songs list
```

## CONVENTIONS

- **Architecture:** MVVM (Models → Services → ViewModels → Views)
- **State:** `@StateObject`, `@EnvironmentObject`, `@Published`
- **Concurrency:** `async/await`, `Task.detached` for background work, `weak self` in closures
- **Singletons:** `static let shared` for all services
- **Guards:** `defer { isHandling = false }` for all re-entrancy guards
- **Mark comments:** `// MARK: - Section Name`
- **Access:** `public` for services/models, `private` for internal state
- **No SwiftLint, no editorconfig**

## ANTI-PATTERNS (DO NOT DO)

- **No synchronous network calls** — always `async` URLSession
- **No force unwrap** in production code
- **Avoid `Thread.sleep`** — use `Task.sleep(for:)`
- **Don't mark cookie invalid on `code=-2`** — that's a sign/time error, not cookie error
- **Don't call `onSongExpired` from search endpoint** — only from `fetchHiCNSongURL`
- **Don't `await searchTask?.value`** — cancels but still blocks; assign and move on
- **Don't use `Timer.scheduledTimer` without storing reference** — causes leak; always store and invalidate in `deinit`
- **Don't replace `songs` list during silent sign refresh** — only update signCache/timeCache

## KEY STATE FLAGS

| Flag | Owner | Purpose |
|------|-------|---------|
| `isHandlingCookieInvalid` | PlayerManager | Re-entrancy guard for cookie invalid handler |
| `isHandlingSongExpired` | PlayerManager | Re-entrancy guard for song expired handler |
| `isRefreshingCookie` | MusicAPIService | Prevents concurrent cookie refresh triggers |
| `cookieNeedsRefresh` | MusicAPIService | Observed by ContentView to trigger WebView |
| `isCookieValid` | MusicAPIService | Observed by ContentView for state transitions |
| `appState` | ContentView | `.launching` → `.loadingCookie` / `.ready` |
| `silentRefreshTrigger` | ContentView | Shows SilentCookieWebView in background |
| `showVerificationSheet` | ContentView | Shows CookieVerificationSheet bottom sheet |

## COMMANDS

```bash
# Build
make build-macos          # macOS Debug
make build-ios-sim        # iOS simulator
make build-all            # Both platforms

# Export (unsigned, for sideloading)
make export-macos         # Export .app
make export-ios           # Export .ipa (Payload/ zip method)

# Release
make release VERSION=1.0.0   # Package + changelog + gh release create
make release-dry-run         # Preview without publishing

# Tests
swift test                         # All tests
swift test --filter MusicAPIService # Single suite

# Cleanup
make clean                # Clean build cache + swift package clean
make clean-derived        # Clean Xcode DerivedData
```

## API ENDPOINTS

Base URL: `https://flac.music.hi.cn`

All requests require SafeLine WAF cookies: `sl-session`, `sl_jwt_session`, `sl_jwt_sign`

### Search
```
POST /ajax.php?act=search
Body: platform=kuwo|wyy&keyword=xxx&page=1&size=30
Returns: list with id, name, artist, sign, time per song
```

### Get URL (play / download)
```
POST /ajax.php?act=getUrl
Body: platform=kuwo|wyy&songid=xxx&format=flac|mp3&bitrate=2000|320&time=xxx&sign=xxx
Returns: JSON { url } or plain URL string
```

### Get Lyric
```
POST /ajax.php?act=getLyric
Body: platform=kuwo|wyy&songid=xxx&time=xxx&sign=xxx
Returns: JSON { data: "<lrc string>" }
```

**Response codes:**
- `code: 0` — success
- `code: -1` — server error (search failure, do NOT trigger onSongExpired)
- `code: -2` — sign/time error (refresh sign, do NOT clear cookie)
- HTTP `401` — cookie invalid
- HTTP `468` — SafeLine WAF block (cookie invalid)

## AUDIO CACHE

- **Location:** `Caches/FlacMusicApp/AudioCache/`
- **Meta file:** `.meta.json` (persisted CacheMeta, survives app restart)
- **Max size:** 1 GB
- **Eviction:** LRU — sorted by `lastAccessed`, oldest evicted first
- **Key format:** `{songId}_{format.rawValue}.{format.rawValue}` e.g. `6844452_flac.flac`
- **Thread safety:** `NSLock` on all read/write operations
- **DownloadManager integration:** checks cache before downloading, stores after download

## PLAYBACK CACHE STRATEGY

1. `cachedURL` hit → `AVPlayerItem(url: localURL)` — zero network
2. miss → `AVPlayerItem(url: remoteURL)` stream immediately
3. Simultaneously: `Task.detached(priority: .background)` downloads and stores to cache
4. On success: `prefetchNextSongURL()` — background download of next song into cache
5. On URL failure (sign expired): `silentRefreshSign()` → retry once → then `stop()`

## NOTES

- **XcodeGen:** Run `xcodegen generate` after editing `project.yml` to regenerate `.xcodeproj`
- **Entry points:** Platform entry files are excluded per-target in `project.yml` excludes array
- **`timeoutTimer`:** stored as `private var timeoutTimer: Timer?`, invalidated in `deinit`
- **`nextSong` property:** exposed on `PlaylistManager` for prefetch logic in `PlayerManager`
- **`validateCookieIfNeeded`:** has 30s debounce, called on `scenePhase == .active`
- **LyricsParser:** uses `LyricsParser.swift`, cancellable via `lyricsLoadTask`
- **`loopOne` manual skip:** `playNext()`/`playPrevious()` advance normally; only auto-end loops
- **No Navidrome/Subsonic:** this app targets flac.music.hi.cn directly, not a Subsonic client
