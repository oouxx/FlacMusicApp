# PROJECT KNOWLEDGE BASE

**Generated:** 2026-04-05
**Version:** 2.0.0
**Project:** FlacMusicApp - Swift/SwiftUI music player

## OVERVIEW

Native SwiftUI app supporting three music providers: Hi音乐 (flac.music.hi.cn), GD Studio (music-api.gdstudio.xyz), and 泡椒音乐 (pjmp3.com). Supports macOS 14+ and iOS 17+. Uses Provider pattern for multi-source extensibility. One third-party dependency: SwiftSoup.

## STRUCTURE

```
FlacMusicApp/
├── Sources/FlacMusicApp/          # Shared source code
│   ├── Models/                    # Data models
│   │   └── Song.swift             # Song, AudioFormat, DownloadTask, KuwoSongURLResponse
│   ├── Services/                  # Business logic
│   │   ├── MusicAPIService.swift  # Facade: MusicProvider/MusicSource enums, protocol, routing, cookie mgmt
│   │   ├── HiCNProvider.swift     # Hi音乐: Cookie auth, sign/time cache, POST API
│   │   ├── GDStudioProvider.swift # GD Studio: 13 sources, GET API, no auth, cover fetching
│   │   ├── PaojiaoProvider.swift  # 泡椒音乐: HTML parsing via SwiftSoup
│   │   ├── CookieStorage.swift    # Cookie persistence (UserDefaults)
│   │   ├── AudioCacheManager.swift # Playback cache (1GB LRU, per-provider isolation)
│   │   ├── PlayerManager.swift    # AVFoundation playback, prefetch, MPRemoteCommandCenter
│   │   ├── PlaylistManager.swift  # Queue management, shuffle order, play modes
│   │   ├── DownloadManager.swift  # User-initiated downloads, progress via KVO
│   │   └── Logger.swift           # In-memory log collector (500 entries, export/clear)
│   ├── ViewModels/
│   │   └── SearchViewModel.swift  # Search, debounce, pagination, silent sign refresh (hi.cn only)
│   └── Views/
│       ├── ContentView.swift      # App state machine, launch flow, cookie verification
│       ├── CookieWebView.swift    # CookieWebView, SilentCookieWebView, CookieVerificationSheet (iOS only)
│       ├── SettingsView.swift     # Settings: provider/source switch, cache, logs
│       ├── CacheSettingsView.swift # Cache management: list by provider, delete per-entry/per-provider
│       ├── LogsView.swift         # Log viewer: export, clear
│       ├── SearchView.swift       # Search UI with current provider indicator
│       ├── DownloadsView.swift    # Downloads UI
│       ├── PlayerView.swift       # Player bar + lyrics
│       ├── LyricsParser.swift     # LRC parser
│       └── QueueView.swift        # Playback queue UI
├── FlacMusicApp-macOS/            # macOS target entry point
├── FlacMusicApp-iOS/              # iOS target entry point
├── Tests/FlacMusicAppTests/       # Tests (Swift Testing framework)
├── Makefile                       # Build system
├── project.yml                    # XcodeGen config
└── Package.swift                  # SPM config (SwiftSoup dependency)
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Provider routing | Services/MusicAPIService.swift | Facade, enums, protocol, cookie mgmt, heartbeat |
| Hi音乐 API | Services/HiCNProvider.swift | Cookie auth, sign/time cache, POST requests |
| GD Studio API | Services/GDStudioProvider.swift | GET requests, 13 sources, cover fetching, GBK encoding |
| 泡椒音乐 API | Services/PaojiaoProvider.swift | SwiftSoup HTML parsing, APlayer URL extraction |
| Playback | Services/PlayerManager.swift | AVPlayer (single instance), prefetch, remote commands, corrupted cache handling |
| Playback cache | Services/AudioCacheManager.swift | 1GB LRU, per-provider key, list/delete entries |
| Playlist | Services/PlaylistManager.swift | Queue, shuffle order, play modes, nextSong |
| Search | ViewModels/SearchViewModel.swift | Debounce, pagination, silent sign refresh (hi.cn only) |
| Launch flow | Views/ContentView.swift | AppState machine, optimistic launch, sheet verification |
| WebView | Views/CookieWebView.swift | Three components: visible, silent, sheet (iOS only) |
| Downloads | Services/DownloadManager.swift | KVO progress, cache reuse |
| Settings | Views/SettingsView.swift | Provider/source switch, cache, logs |
| Tests | Tests/FlacMusicAppTests/ | Swift Testing (@Suite, @Test) |

## ARCHITECTURE

MVVM + Provider pattern:

```
Views → ViewModels → MusicAPIService (Facade) → Provider → Models
```

### Provider Architecture

```
MusicProviderProtocol (protocol)
  ├── HiCNProvider (Cookie auth, sign/time cache, POST)
  ├── GDStudioProvider (No auth, GET, 13 sources, GBK→UTF8)
  └── PaojiaoProvider (No auth, HTML parsing via SwiftSoup)

MusicAPIService (facade)
  ├── currentProvider: MusicProvider
  ├── currentSource: MusicSource
  └── activeProvider → routes to correct Provider
```

### Cookie / Launch Flow (Hi音乐 only)

```
App launch
  ├── hasValidCookie → optimistic enter main UI
  │     └── background heartbeat (60s interval)
  │           ├── valid → no-op ✅
  │           └── invalid → show CookieVerificationSheet
  └── no cookie → launch screen + SilentCookieWebView
                   └── onCookiesReady → fade into main UI
```

### Playback Cache Flow

```
play(song)
  ├── AudioCacheManager.cachedURL hit → local playback (zero network) ✅
  │     └── if playback fails → delete corrupted cache → retry remote
  └── miss → stream remote URL
              ├── background Task: downloadToTemp → cache.store()
              └── after success: prefetchNextSongURL() in background
```

Cache key format: `{provider}_{songId}_{format}` (e.g., `hican_550531860_mp3320`)

### Sign Refresh Flow (Hi音乐 only)

```
getSongURL fails (sign expired)
  └── silentRefreshSign(): searchSongs() → updates signCache
        ├── found → retry playCurrentSong(retryCount: 1) ✅
        └── not found → stop() + show error

SearchViewModel: scheduleSilentRefresh() every 5min after successful search
  → only for Hi音乐 provider, skipped for GD Studio / 泡椒音乐
```

### Cookie Invalid Handler

```
onCookieInvalid triggered
  ├── Wait for cookie refresh (max 15s, poll every 0.5s)
  ├── If cookie ready → re-search and replay
  └── If timeout → give up (no infinite retry loop)
```

## CONVENTIONS

- **Architecture:** MVVM + Provider pattern
- **State:** `@StateObject`, `@EnvironmentObject`, `@Published`
- **Concurrency:** `async/await`, `Task.detached` for background work, `weak self` in closures
- **Singletons:** `static let shared` for all services
- **Guards:** `defer { isHandling = false }` for all re-entrancy guards
- **Mark comments:** `// MARK: - Section Name`
- **Access:** `public` for services/models, `private` for internal state
- **Dependencies:** SPM for SwiftSoup only

## ANTI-PATTERNS (DO NOT DO)

- **No synchronous network calls** — always `async` URLSession
- **No force unwrap** in production code
- **Avoid `Thread.sleep`** — use `Task.sleep(for:)`
- **Don't mark cookie invalid on `code=-2`** — that's a sign/time error, not cookie error
- **Don't call `onSongExpired` from search endpoint** — only from HiCNProvider's getSongURL
- **Don't `await searchTask?.value`** — cancels but still blocks; assign and move on
- **Don't use `Timer.scheduledTimer` without storing reference** — causes leak; always store and invalidate in `deinit`
- **Don't replace `songs` list during silent sign refresh** — only update signCache/timeCache
- **Don't mix provider caches** — always use provider-prefixed cache keys
- **Don't call play(song:) from remote play command** — use `player?.play()` to preserve position

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
| `currentProvider` | MusicAPIService | Current music provider (hiCN/gdStudio/paojiao) |
| `currentSource` | MusicAPIService | Current music source within provider |

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
make release VERSION=2.0.0   # Package + changelog + gh release create
make release-dry-run         # Preview without publishing

# Tests
swift test                         # All tests
swift test --filter MusicAPIService # Single suite

# Cleanup
make clean                # Clean build cache + swift package clean
make clean-derived        # Clean Xcode DerivedData
```

## API ENDPOINTS

### Hi音乐 (flac.music.hi.cn)

Base URL: `https://flac.music.hi.cn`

All requests require SafeLine WAF cookies: `sl-session`, `sl_jwt_session`, `sl_jwt_sign`

| Endpoint | Method | Body | Returns |
|----------|--------|------|---------|
| `/ajax.php?act=search` | POST | `platform=kuwo\|wyy&keyword=xxx&page=1&size=30` | `{data: {list: [{id, name, artist, sign, time}]}}` |
| `/ajax.php?act=getUrl` | POST | `platform=kuwo\|wyy&songid=xxx&format=flac\|mp3&bitrate=2000\|320&time=xxx&sign=xxx` | Plain URL or `{url: "..."}` |
| `/ajax.php?act=getLyric` | POST | `platform=kuwo\|wyy&songid=xxx&time=xxx&sign=xxx` | `{data: "<lrc string>"}` |

Response codes: `code: 0` success, `code: -1` server error, `code: -2` sign/time error, HTTP `401` cookie invalid, HTTP `468` WAF block.

### GD Studio (music-api.gdstudio.xyz)

Base URL: `https://music-api.gdstudio.xyz/api.php`

No authentication required. GET requests with query params.

| Param | Values | Description |
|-------|--------|-------------|
| `types` | `search`, `url`, `lyric`, `pic` | API action |
| `source` | `netease`, `kuwo`, `joox`, `bilibili`, `tencent`, `tidal`, `spotify`, `ytmusic`, `qobuz`, `deezer`, `migu`, `kugou`, `ximalaya`, `apple` | Music source |
| `name` | keyword | Search keyword |
| `count` | number | Results per page |
| `pages` | number | Page number |
| `id` | song ID | Song/lyric/pic ID |
| `br` | `999`, `320`, `128` | Bitrate (999=lossless) |
| `size` | `500` | Cover image size |

Search response: `[{id, name, artist, album, pic_id, url_id, lyric_id, source}]` (array, no nesting)
URL response: `{url: "...", br: "...", size: "..."}`
Lyrics response: `{lyric: "...", tlyric: "..."}`
Pic response: `{url: "https://..."}`

Note: Response may be GBK encoded — decode with `.windowsCP936` fallback.

### 泡椒音乐 (pjmp3.com)

Base URL: `https://pjmp3.com`

No authentication required. HTML pages parsed with SwiftSoup.

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/search.php?keyword=xxx` | GET | Search results (HTML) |
| `/song.php?id=xxx` | GET | Song detail page (HTML with APlayer config) |

Search HTML: `<a class="search-result-list-item" href="song.php?id=xxx">` with `<img src="...">`, `.search-result-list-item-left-song`, `.search-result-list-item-left-singer`
Song URL: Extracted from `new APlayer({ audio: [{ url: '...' }] })` in `<script>`
Lyrics: `<div class="lyric-item">` text content (plain text, not LRC)

## AUDIO CACHE

- **Location:** `Caches/FlacMusicApp/AudioCache/`
- **Meta file:** `.meta.json` (persisted CacheMeta, survives app restart)
- **Max size:** 1 GB
- **Eviction:** LRU — sorted by `lastAccessed`, oldest evicted first
- **Key format:** `{provider}_{songId}_{format}.{format}` e.g., `hican_6844452_flac.flac`
- **Thread safety:** `NSLock` on all read/write operations
- **DownloadManager integration:** checks cache before downloading, stores after download
- **Corrupted cache handling:** if playback fails on cached file, delete and retry remote

## NOTES

- **XcodeGen:** Run `xcodegen generate` after editing `project.yml` to regenerate `.xcodeproj`
- **SPM:** Run `swift package resolve` after editing `Package.swift`
- **Entry points:** Platform entry files are excluded per-target in `project.yml` excludes array
- **`timeoutTimer`:** stored as `private var timeoutTimer: Timer?`, invalidated in `deinit`
- **`nextSong` property:** exposed on `PlaylistManager` for prefetch logic in `PlayerManager`
- **`validateCookieIfNeeded`:** has 30s debounce, called on `scenePhase == .active`
- **LyricsParser:** uses `LyricsParser.swift`, cancellable via `lyricsLoadTask`
- **`loopOne` manual skip:** `playNext()`/`playPrevious()` advance normally; only auto-end loops
- **iOS lock screen:** Requires `UIBackgroundModes` + `audio` in Info.plist + `MPRemoteCommandCenter`
- **Remote play command:** Use `player?.play()` not `play(song:)` to preserve playback position
- **No Navidrome/Subsonic:** this app targets multiple providers directly, not a Subsonic client
