import SwiftUI

public struct CacheSettingsView: View {
    @State private var cacheSize: Int64 = 0
    @State private var cacheCount: Int = 0
    @State private var entries: [AudioCacheManager.CacheEntryInfo] = []
    @State private var showClearConfirm = false
    @State private var providerToDelete: MusicProvider?

    public init() {}

    public var body: some View {
        List {
            Section {
                HStack {
                    Label("缓存大小", systemImage: "internaldrive")
                    Spacer()
                    Text(ByteCountFormatter.string(fromByteCount: cacheSize, countStyle: .file))
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Label("已缓存歌曲", systemImage: "music.note.list")
                    Spacer()
                    Text("\(cacheCount) 首")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Label("最大缓存", systemImage: "chart.bar")
                    Spacer()
                    Text("1 GB")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("播放缓存")
            } footer: {
                Text("播放过的音乐会自动缓存到本地，重复播放无需消耗流量。超出 1 GB 时自动清理最久未播放的文件。")
            }

            if !entries.isEmpty {
                ForEach(groupedEntries(), id: \.key) { group in
                    Section {
                        ForEach(group.value) { entry in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(entry.songId)
                                        .font(.subheadline)
                                    Text("\(entry.format.rawValue) · \(ByteCountFormatter.string(fromByteCount: entry.fileSize, countStyle: .file))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button(role: .destructive) {
                                    AudioCacheManager.shared.deleteEntry(entry)
                                    refresh()
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } header: {
                        Text(group.key.displayName)
                    }
                }
            }

            Section {
                ForEach(MusicProvider.allCases) { provider in
                    let count = entries.filter { $0.provider == provider }.count
                    if count > 0 {
                        Button(role: .destructive) {
                            providerToDelete = provider
                        } label: {
                            HStack {
                                Label("清除 \(provider.displayName) 缓存 (\(count) 首)", systemImage: "trash.circle")
                                Spacer()
                            }
                        }
                    }
                }
                Button(role: .destructive) {
                    showClearConfirm = true
                } label: {
                    Label("清除全部播放缓存", systemImage: "trash")
                }
            } header: {
                Text("操作")
            }
        }
        .navigationTitle("缓存设置")
        .onAppear { refresh() }
        .confirmationDialog("确定清除全部播放缓存？", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("清除", role: .destructive) {
                AudioCacheManager.shared.clearAll()
                refresh()
            }
            Button("取消", role: .cancel) {}
        }
        .confirmationDialog("清除 \(providerToDelete?.displayName ?? "") 的缓存？", isPresented: .constant(providerToDelete != nil), titleVisibility: .visible) {
            if let provider = providerToDelete {
                Button("清除", role: .destructive) {
                    AudioCacheManager.shared.deleteProvider(provider)
                    providerToDelete = nil
                    refresh()
                }
            }
            Button("取消", role: .cancel) {
                providerToDelete = nil
            }
        }
    }

    private func groupedEntries() -> [(key: MusicProvider, value: [AudioCacheManager.CacheEntryInfo])] {
        Dictionary(grouping: entries, by: { $0.provider })
            .sorted { $0.key.displayName < $1.key.displayName }
    }

    private func refresh() {
        cacheSize = AudioCacheManager.shared.currentCacheSize
        cacheCount = AudioCacheManager.shared.cacheCount
        entries = AudioCacheManager.shared.allEntries
    }
}
