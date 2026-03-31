# FlacMusicApp

flac.music.hi.cn 的 Swift 原生复刻版，支持 macOS 和 iOS 双平台。

## 功能

- 🔍 搜索歌曲（支持酷我、网易云双平台）
- 🎵 在线播放 FLAC / APE / MP3 无损音乐
- 💾 智能播放缓存（最大 1GB，LRU 自动淘汰，重复播放零流量）
- 📄 歌词显示（LRC 格式，实时滚动）
- ⬇️ 下载管理，支持实时进度展示
- 📱 原生 SwiftUI，macOS + iOS 共用代码
- 🎧 播放队列（顺序 / 循环 / 单曲循环 / 随机播放）
- 🔄 Cookie 心跳检测（60 秒间隔，失效自动静默刷新）
- ⚡ 智能启动（有缓存 Cookie 直接进主界面，后台验证）
- 🎮 锁屏 / 控制中心播放控制

## 界面预览

| 搜索页 | 下载页 | 播放栏 |
|--------|--------|--------|
| 搜索歌曲、歌手 | 下载管理、进度显示 | 底部播放控制 |

## 项目结构

```
FlacMusicApp/
├── Package.swift
├── Makefile                              # 构建脚本
├── project.yml                           # XcodeGen 配置
├── .github/workflows/build.yml           # GitHub Actions CI
├── Sources/FlacMusicApp/
│   ├── Models/
│   │   └── Song.swift                    # 数据模型（Song, AudioFormat, DownloadTask）
│   ├── Services/
│   │   ├── MusicAPIService.swift         # API 请求层（心跳、sign 缓存、Cookie 管理）
│   │   ├── CookieStorage.swift           # Cookie 持久化存储
│   │   ├── AudioCacheManager.swift       # 播放缓存（1GB LRU）
│   │   ├── DownloadManager.swift         # 用户主动下载管理
│   │   ├── PlayerManager.swift           # 音频播放（AVFoundation）
│   │   ├── PlaylistManager.swift         # 播放队列管理
│   │   └── LyricsParser.swift            # LRC 歌词解析
│   ├── ViewModels/
│   │   └── SearchViewModel.swift         # 搜索逻辑（防抖、分页、静默 sign 刷新）
│   ├── Views/
│   │   ├── ContentView.swift             # 主入口（启动状态机、Cookie 验证流程）
│   │   ├── CookieWebView.swift           # WebView 验证组件
│   │   ├── CacheSettingsView.swift       # 缓存设置页
│   │   ├── SearchView.swift              # 搜索页
│   │   ├── DownloadsView.swift           # 下载页
│   │   ├── PlayerView.swift              # 播放栏 + 歌词
│   │   └── QueueView.swift               # 播放队列
│   ├── FlacMusicApp_macOS.swift          # macOS @main
│   └── FlacMusicApp_iOS.swift            # iOS @main
├── FlacMusicApp-macOS/                   # macOS Target
└── FlacMusicApp-iOS/                     # iOS Target
```

## 架构说明

采用标准 MVVM 分层，零第三方依赖：

```
Views → ViewModels → Services → Models
```

### Cookie 验证流程

```
启动
 ├── 有本地 Cookie → 直接进主界面（乐观策略）
 │     └── 后台心跳验证
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
```

### Sign 自动刷新

```
搜索成功后每 5 分钟后台静默刷新 sign 缓存
播放 URL 失败时先静默重搜拿新 sign 再重试，用户只看到"加载中"
```

## 使用说明

### 首次启动

1. 启动 App 后自动在后台完成验证
2. 大多数情况下无需任何操作，直接进入主界面
3. 遇到人机验证时底部会弹出验证 Sheet，完成后自动关闭

### 搜索与播放

1. 在搜索框输入关键词（500ms 防抖自动搜索）
2. 点击歌曲右侧播放按钮在线播放
3. 播放过的歌曲自动缓存，重复播放无需流量
4. 点击歌词按钮查看实时滚动歌词
5. 点击下载按钮保存到本地

### 播放缓存

- 播放过的音乐自动缓存到本地，最大 1GB
- 超出限制时自动清理最久未播放的文件（LRU）
- 进入设置页可查看缓存大小并手动清除

### 常见问题

**Q: 搜索 / 播放失败怎么办？**

A: App 会自动处理。Cookie 失效时后台静默刷新；sign 过期时自动重搜重试，无需手动操作。

**Q: 如何下载高品质音乐？**

A: 搜索结果中点击下载按钮，支持 FLAC / APE / MP3 格式。已缓存的歌曲下载时直接复制本地文件，不消耗流量。

**Q: 播放列表如何使用？**

A: 点击播放栏的列表按钮打开队列，支持顺序、循环全部、单曲循环、随机播放四种模式。loopOne 模式下手动点上下一首仍可切歌。

**Q: 缓存占用太多空间怎么办？**

A: 进入设置 → 缓存设置，可查看当前占用并一键清除。App 超出 1GB 时也会自动淘汰旧缓存。

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
make release VERSION=1.0.0   # 自动打包 + 生成 changelog + 创建 GitHub Release
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
| 缓存 | FileManager + LRU（自实现） |
| 构建 | XcodeGen + Makefile |
| CI | GitHub Actions |
| 依赖 | 无（零第三方依赖） |

## API 说明

Base URL：`https://flac.music.hi.cn`

所有请求需要携带 SafeLine WAF Cookie（`sl-session`、`sl_jwt_session`、`sl_jwt_sign`）。

| 端点 | 说明 |
|------|------|
| `POST /ajax.php?act=search` | 搜索歌曲，返回列表和 sign/time |
| `POST /ajax.php?act=getUrl` | 获取播放 / 下载链接 |
| `POST /ajax.php?act=getLyric` | 获取 LRC 歌词 |

状态码：`200` 正常，`401` Cookie 无效，`468` WAF 拦截。
