import SwiftUI

public struct SettingsView: View {

    @AppStorage("selectedPlatform") private var selectedPlatform: String = MusicPlatform.kuwo
        .rawValue

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                // MARK: 音乐源
                Section {
                    platformRow(.kuwo)
                    platformRow(.netease)
                } header: {
                    Text("音乐源")
                } footer: {
                    Text("切换后重新搜索生效，当前源的搜索结果和播放链接可能不同。")
                }

                // MARK: 缓存
                Section {
                    NavigationLink {
                        CacheSettingsView()
                    } label: {
                        HStack {
                            Label("播放缓存", systemImage: "internaldrive")
                            Spacer()
                            Text(
                                ByteCountFormatter.string(
                                    fromByteCount: AudioCacheManager.shared.currentCacheSize,
                                    countStyle: .file)
                            )
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        }
                    }
                } header: {
                    Text("存储")
                }

                // MARK: 关于
                Section {
                    HStack {
                        Label("版本", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                } header: {
                    Text("关于")
                }
            }
            .navigationTitle("设置")
        }
        .onAppear {
            if let p = MusicPlatform(rawValue: selectedPlatform) {
                MusicAPIService.shared.setPlatform(p)
            }
        }
    }

    @ViewBuilder
    private func platformRow(_ platform: MusicPlatform) -> some View {
        Button {
            selectedPlatform = platform.rawValue
            MusicAPIService.shared.setPlatform(platform)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(platform.displayName)
                        .foregroundStyle(.primary)
                    Text(platformDescription(platform))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if selectedPlatform == platform.rawValue {
                    Image(systemName: "checkmark")
                        .tint(.accentColor)
                        .fontWeight(.semibold)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func platformDescription(_ platform: MusicPlatform) -> String {
        switch platform {
        case .kuwo: return "酷我音乐 · 曲库丰富，FLAC 资源多"
        case .netease: return "网易云音乐 · 热门歌曲覆盖广"
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
