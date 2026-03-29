# FlacMusicApp

flac.music.hi.cn 的 Swift 原生复刻版，支持 macOS 和 iOS。

## 功能

- 🔍 搜索歌曲（支持酷我、网易云双平台）
- 🎵 在线播放 FLAC 无损音乐
- 📄 歌词显示（LRC 格式，实时滚动）
- ⬇️ 下载管理，支持进度展示
- 📱 原生 SwiftUI，macOS + iOS 共用代码
- 🎧 播放队列（顺序/循环/随机播放）
- 🔄 Cookie 池自动刷新（后台每 10 分钟）

## 界面预览

| 搜索页         | 下载页             | 播放栏       |
| -------------- | ------------------ | ------------ |
| 搜索歌曲、歌手 | 下载管理、进度显示 | 底部播放控制 |

## 项目结构

```
FlacMusicApp/
├── Package.swift
├── Makefile
├── .github/workflows/build.yml    # GitHub Actions CI
├── Sources/FlacMusicApp/
│   ├── Models/
│   │   └── Song.swift              # 数据模型
│   ├── Services/
│   │   ├── MusicAPIService.swift   # 音乐 API 请求层
│   │   ├── CookieStorage.swift     # Cookie 池 (5 个,10 分钟过期)
│   │   ├── DownloadManager.wav     # 下载管理
│   │   ├── PlayerManager.swift     # 音频播放
│   │   └── LyricsParser.swift      # LRC 歌词解析
│   ├── ViewModels/
│   │   └── SearchViewModel.swift   # 搜索逻辑
│   ├── Views/
│   │   ├── ContentView.swift        # 主入口
│   │   ├── SearchView.swift        # 搜索页
│   │   ├── DownloadsView.wav        # 下载页
│   │   ├── PlayerView.wav         # 播放栏 + 歌词
│   │   └── QueueView.wav        # 播放队列
│   ├── FlacMusicApp_macOS.wav   # macOS @main
│   └── FlacMusicApp_iOS.wav     # iOS @main
├── FlacMusicApp-macOS/            # macOS Target
└── FlacMusicApp-iOS/             # iOS Target
```

## 使用说明

### 首次启动

1. 启动 App 后会显示验证页面
2. 完成人机验证后自动进入主界面
3. 验证 Cookie 会缓存用于后续请求

### 搜索与播放

1. 在搜索框输入关键词
2. 点击歌曲右侧播放按钮在线播放
3. 点击歌词按钮查看歌词
4. 点击下载按钮保存到本地

### 常见问题

**Q: 搜索/播放失败怎么办？**
A: Cookie 会自动刷新（后台每 10 分钟）。也可手动点击"刷新Cookie"按钮重新验证

**Q: 如何下载高品质音乐？**
A: 搜索结果中点击下载按钮，支持 FLAC/MP3 格式

**Q: 播放列表如何使用？**
A: 点击播放列表按钮打开队列。支持顺序、循环、随机播放模式

## 构建命令

```bash
# 构建 macOS
make build-macos

# 构建 iOS 模拟器
make build-ios-sim

# 同时构建
make build-all

# 导出
make export-macos         # 导出 .app (无签名)
make export-ios           # 导出 .ipa (无签名)

# 发布 GitHub Release
make release VERSION=1.0.0  # 自动打包 + changelog
```

## GitHub Actions

推送代码到 main 分支自动触发构建：

- macOS (arm64 + x86_64)
- iOS 模拟器
- 自动导出并上传构建产物

## 系统要求

- Xcode 15+
- macOS 14+ / iOS 17+
- Swift 5.9+

## 技术栈

- SwiftUI + Swift Concurrency
- AVFoundation 音频播放
- URLSession 网络请求
- WKWebView Cookie 验证
- MediaPlayer 框架 (控制中心 + Lock Screen)
