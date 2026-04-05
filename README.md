# FlacMusicApp

多平台音乐播放器，支持 macOS 和 iOS 双平台。集成 Hi音乐、GD Studio、泡椒音乐三大音乐源，支持 13+ 音乐平台搜索。

## 功能

- 🔍 搜索歌曲（支持三大音乐源、13+ 音乐平台）
- 🎵 在线播放 FLAC / APE / MP3 无损音乐
- 💾 智能播放缓存（最大 1GB，LRU 自动淘汰，按音乐源隔离）
- 📄 歌词显示（LRC 实时滚动 + 纯文本歌词）
- ⬇️ 下载管理，支持实时进度展示
- 📱 原生 SwiftUI，macOS + iOS 共用代码
- 🎧 播放队列（顺序 / 循环 / 单曲循环 / 随机播放）
- 🔄 Cookie 心跳检测（60 秒间隔，失效自动刷新）
- ⚡ 智能启动（有缓存 Cookie 直接进主界面，后台验证）
- 🎮 iOS 锁屏 / 控制中心播放控制
- ⚙️ 设置页（音乐源切换、缓存管理、日志查看）
- 📋 日志查看（内存日志，支持导出和清空）

## 音乐源

| 平台 | 音乐源 | 认证方式 | 说明 |
|------|--------|---------|------|
| **Hi音乐** | 酷我、网易云 | Cookie 验证 | 原 flac.music.hi.cn，需 SafeLine WAF Cookie |
| **GD Studio** | 网易云、酷我、JOOX、哔哩哔哩、QQ音乐、TIDAL、Spotify、YouTube Music、Qobuz、Deezer、咪咕、酷狗、喜马拉雅、Apple Music | 无需认证 | music-api.gdstudio.xyz，13 个源 |
| **泡椒音乐** | 酷我 | 无需认证 | pjmp3.com，HTML 解析 |

## 项目结构

```
FlacMusicApp/
├── Package.swift                           # SPM 配置（SwiftSoup 依赖）
├── Makefile                                # 构建脚本
├── project.yml                             # XcodeGen 配置
├── Sources/FlacMusicApp/
│   ├── Models/
│   │   └── Song.swift                      # 数据模型（Song, AudioFormat, DownloadTask）
│   ├── Services/
│   │   ├── MusicAPIService.swift           # 门面层（Provider/Source 路由、Cookie 管理）
│   │   ├── HiCNProvider.swift              # Hi音乐 Provider（Cookie 认证 + sign 缓存）
│   │   ├── GDStudioProvider.swift          # GD Studio Provider（13 个源，无需认证）
│   │   ├── PaojiaoProvider.swift           # 泡椒音乐 Provider（HTML 解析）
│   │   ├── CookieStorage.swift             # Cookie 持久化存储
│   │   ├── AudioCacheManager.swift         # 播放缓存（1GB LRU，按 Provider 隔离）
│   │   ├── DownloadManager.swift           # 用户主动下载管理
│   │   ├── PlayerManager.swift             # 音频播放（AVFoundation + 锁屏控制）
│   │   ├── PlaylistManager.swift           # 播放队列管理
│   │   └── Logger.swift                    # 内存日志收集器
│   ├── ViewModels/
│   │   └── SearchViewModel.swift           # 搜索逻辑（防抖、分页、静默 sign 刷新）
│   ├── Views/
│   │   ├── ContentView.swift               # 主入口（启动状态机、Cookie 验证）
│   │   ├── CookieWebView.swift             # WebView 验证组件
│   │   ├── SettingsView.swift              # 设置页（音乐源切换、缓存、日志）
│   │   ├── CacheSettingsView.swift         # 缓存管理（列表查看、按源清除）
│   │   ├── LogsView.swift                  # 日志查看（导出、清空）
│   │   ├── SearchView.swift                # 搜索页
│   │   ├── DownloadsView.swift             # 下载页
│   │   ├── PlayerView.swift                # 播放栏 + 歌词
│   │   └── QueueView.swift                 # 播放队列
│   ├── FlacMusicApp_macOS.swift            # macOS @main
│   └── FlacMusicApp_iOS.swift              # iOS @main
├── FlacMusicApp-macOS/                     # macOS Target
└── FlacMusicApp-iOS/                       # iOS Target
```

## 架构说明

采用 MVVM 分层 + Provider 模式，支持多音乐源扩展：

```
Views → ViewModels → MusicAPIService（门面）→ Provider → Models
```

### Provider 架构

```
MusicAPIService（门面）
  ├── currentProvider: MusicProvider（当前平台）
  ├── currentSource: MusicSource（当前音乐源）
  └── activeProvider → 路由到对应 Provider 实现

MusicProviderProtocol（协议）
  ├── HiCNProvider（Hi音乐，Cookie 认证 + sign/time 缓存）
  ├── GDStudioProvider（GD Studio，13 个源，无需认证）
  └── PaojiaoProvider（泡椒音乐，HTML 解析）
```

### Cookie 验证流程（仅 Hi音乐）

```
启动
  ├── 有本地 Cookie → 直接进主界面（乐观策略）
  │     └── 后台心跳验证（60s 间隔）
  │           ├── 有效 → 无感知 ✅
  │           └── 无效 → 底部弹出验证 Sheet
  └── 无 Cookie → 启动屏 + 后台静默加载 WebView
                   └── 加载完成自动淡入主界面
```

### 音乐缓存流程

```
点击播放
  ├── 命中本地缓存 → 直接本地播放（零流量）✅
  └── 未命中 → 远程流播 + 后台下载存缓存
                └── 下次播放直接命中 ✅

预取：当前歌播放成功后，后台静默预取下一首
用户下载：优先从缓存复制，避免重复下载
缓存隔离：不同 Provider 的缓存完全独立
损坏检测：缓存文件播放失败时自动删除并回退远程
```

### 缓存 Key 格式

```
{provider}_{songId}_{format}
例：hican_550531860_mp3320      (Hi音乐)
    gdstudio_550531860_mp3320   (GD Studio)
    paojiao_550531860_mp3320    (泡椒音乐)
```

## 使用说明

### 首次启动

1. 启动 App 后自动在后台完成验证
2. 大多数情况下无需任何操作，直接进入主界面
3. 遇到人机验证时底部会弹出验证 Sheet，完成后自动关闭

### 切换音乐源

1. 进入 **设置** 页
2. 选择 **服务平台**（Hi音乐 / GD Studio / 泡椒音乐）
3. 选择 **音乐源**（根据平台动态变化）
4. 切换后重新搜索生效

### 搜索与播放

1. 在搜索框输入关键词（500ms 防抖自动搜索）
2. 点击歌曲右侧播放按钮在线播放
3. 播放过的歌曲自动缓存，重复播放无需流量
4. 点击歌词按钮查看实时滚动歌词
5. 点击下载按钮保存到本地

### 缓存管理

- 进入 **设置 → 缓存设置** 查看缓存详情
- 按 Provider 分组显示已缓存歌曲
- 可单独删除单个缓存或按 Provider 批量清除
- 超出 1GB 时自动清理最久未播放的文件（LRU）

### 日志查看

- 进入 **设置 → 查看日志** 查看运行日志
- 支持导出日志文本（分享）
- 支持清空日志

### 常见问题

**Q: 搜索 / 播放失败怎么办？**

A: App 会自动处理。Cookie 失效时后台静默刷新；sign 过期时自动重搜重试，无需手动操作。

**Q: 如何下载高品质音乐？**

A: 搜索结果中点击下载按钮，支持 FLAC / APE / MP3 格式。已缓存的歌曲下载时直接复制本地文件，不消耗流量。

**Q: 播放列表如何使用？**

A: 点击播放栏的列表按钮打开队列，支持顺序、循环全部、单曲循环、随机播放四种模式。loopOne 模式下手动点上下一首仍可切歌。

**Q: 缓存占用太多空间怎么办？**

A: 进入设置 → 缓存设置，可查看当前占用并按 Provider 清除。App 超出 1GB 时也会自动淘汰旧缓存。

## 构建命令

```bash
# 构建
make build-macos          # 构建 macOS（Debug）
make build-ios-sim        # 构建 iOS 模拟器
make build-all            # 同时构建两个平台

# 导出
make export-macos         # 导出 .app（无签名）
make export-ios           # 导出 .ipa（无签名）

# 发布
make release VERSION=2.0.0   # 自动打包 + 生成 changelog + 创建 GitHub Release
make release-dry-run         # 预览 release 内容不实际发布

# 清理
make clean                # 清理构建缓存
make clean-derived        # 清理 Xcode DerivedData
```

## GitHub Actions

推送到 `main` 分支自动触发：

- macOS（arm64 + x86_64）
- iOS 模拟器（arm64 + x86_64）
- 自动导出并上传构建产物

## 系统要求

| 项目 | 要求 |
|------|------|
| Xcode | 15+ |
| macOS | 14+（Sonoma） |
| iOS | 17+ |
| Swift | 5.9+ |

## 技术栈

| 模块 | 技术 |
|------|------|
| UI | SwiftUI |
| 并发 | Swift Concurrency（async/await） |
| 音频播放 | AVFoundation |
| 网络 | URLSession |
| Cookie 验证 | WKWebView + SafeLine WAF |
| 锁屏控制 | MediaPlayer framework |
| HTML 解析 | SwiftSoup |
| 缓存 | FileManager + LRU（自实现） |
| 构建 | XcodeGen + Makefile + SPM |
| CI | GitHub Actions |
| 依赖 | SwiftSoup（HTML 解析） |

## API 说明

### Hi音乐（flac.music.hi.cn）

Base URL：`https://flac.music.hi.cn`

所有请求需要携带 SafeLine WAF Cookie（`sl-session`、`sl_jwt_session`、`sl_jwt_sign`）。

| 端点 | 说明 |
|------|------|
| `POST /ajax.php?act=search` | 搜索歌曲，返回列表和 sign/time |
| `POST /ajax.php?act=getUrl` | 获取播放 / 下载链接 |
| `POST /ajax.php?act=getLyric` | 获取 LRC 歌词 |

状态码：`200` 正常，`401` Cookie 无效，`468` WAF 拦截。

### GD Studio（music-api.gdstudio.xyz）

Base URL：`https://music-api.gdstudio.xyz/api.php`

无需认证，GET 请求。

| 参数 | 说明 |
|------|------|
| `types=search` | 搜索歌曲 |
| `types=url` | 获取播放链接 |
| `types=lyric` | 获取歌词 |
| `types=pic` | 获取封面图 |
| `source=netease|kuwo|...` | 音乐源 |

### 泡椒音乐（pjmp3.com）

Base URL：`https://pjmp3.com`

无需认证，HTML 页面解析。

| 端点 | 说明 |
|------|------|
| `GET /search.php?keyword=xxx` | 搜索歌曲（HTML） |
| `GET /song.php?id=xxx` | 歌曲详情页（含播放 URL 和歌词） |
