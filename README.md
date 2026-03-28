# FlacMusicApp

flac.music.hi.cn 的 Swift 原生复刻版，支持 macOS 和 iOS。

## 功能

- 🔍 搜索歌曲（支持酷我、网易云双平台）
- 🎵 在线播放 FLAC 无损音乐
- 📄 歌词显示
- ⬇️ 下载管理，支持进度展示
- 📱 原生 SwiftUI，macOS + iOS 共用代码

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
│   │   ├── DownloadManager.swift   # 下载管理
│   │   └── PlayerManager.swift     # 音频播放
│   ├── ViewModels/
│   │   └── SearchViewModel.swift   # 搜索逻辑
│   ├── Views/
│   │   ├── ContentView.swift        # 主入口
│   │   ├── SearchView.swift        # 搜索页
│   │   ├── DownloadsView.swift      # 下载页
│   │   └── PlayerView.swift       # 播放栏 + 歌词
│   ├── FlacMusicApp_macOS.swift   # macOS @main
│   └── FlacMusicApp_iOS.swift     # iOS @main
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
A: 点击"刷新Cookie"按钮重新验证

**Q: 如何下载高品质音乐？**
A: 搜索结果中点击下载按钮，支持 FLAC/MP3 格式

## 构建命令

```bash
# 构建 macOS
make build-macos

# 构建 iOS 模拟器
make build-ios-sim

# 同时构建
make build-all
```

## GitHub Actions

推送代码到 main 分支自动触发构建：

- macOS arm64 + x86_64
- iOS 模拟器

## 系统要求

- Xcode 15+
- macOS 14+ / iOS 17+
- Swift 5.9+

## 技术栈

- SwiftUI + Swift Concurrency
- AVFoundation 音频播放
- URLSession 网络请求
- WKWebView Cookie 验证
