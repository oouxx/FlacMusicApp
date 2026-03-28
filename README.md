# FlacMusicApp

flac.music.hi.cn 的 Swift 原生复刻版，支持 macOS 和 iOS。

## 功能

- 🔍 搜索歌曲、歌手、专辑（对接酷我音乐 API）
- 🎵 支持 FLAC 无损格式下载
- 📱 原生 SwiftUI，macOS + iOS 共用代码
- ⬇️ 下载管理，支持进度展示

## API 说明

| 功能 | 接口 |
|------|------|
| 搜索 | `GET https://flac.music.hi.cn/api/search?keyword=...&page=1&limit=30` |
| 下载链接 | `GET https://flac.music.hi.cn/api/url?id={rid}&type=flac` |
| 歌词 | `GET https://flac.music.hi.cn/api/lrc?id={rid}` |

## 项目结构

```
FlacMusicApp/
├── Package.swift
├── Makefile
├── Sources/FlacMusicApp/
│   ├── Models/
│   │   └── Song.swift               # 数据模型 + Kuwo API 结构
│   ├── Services/
│   │   ├── MusicAPIService.swift    # API 请求层
│   │   └── DownloadManager.swift   # 下载管理
│   ├── ViewModels/
│   │   └── SearchViewModel.swift   # 搜索逻辑
│   ├── Views/
│   │   ├── ContentView.swift       # 跨平台入口 (TabView)
│   │   ├── SearchView.swift        # 搜索页
│   │   └── DownloadsView.swift     # 下载页
│   ├── FlacMusicApp_macOS.swift    # macOS @main
│   └── FlacMusicApp_iOS.swift      # iOS @main
```

## 接入 Xcode 工程

1. 用 Xcode 新建 **Multi-platform App** 工程，名称 `FlacMusicApp`
2. 添加两个 Target：`FlacMusicApp-macOS`、`FlacMusicApp-iOS`
3. 将 `Sources/FlacMusicApp/` 中所有 `.swift` 文件加入对应 Target
4. 在 **Info.plist** 中加入 ATS 豁免：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 构建命令

```bash
# 构建 macOS Universal (arm64 + x86_64)
make build-macos

# 构建 iOS 真机
make build-ios

# 同时构建两个平台
make build-all

# 清理
make clean
```

## 系统要求

- Xcode 15+
- macOS 14+ / iOS 17+
- Swift 5.9+
