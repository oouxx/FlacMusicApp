//
//  CacheSettingsView.swift
//  FlacMusicApp
//
//  Created by wxx on 2026/4/1.
//

import SwiftUI

public struct CacheSettingsView: View {
    @State private var cacheSize: Int64 = 0
    @State private var cacheCount: Int = 0
    @State private var showClearConfirm = false

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

            Section {
                Button(role: .destructive) {
                    showClearConfirm = true
                } label: {
                    Label("清除播放缓存", systemImage: "trash")
                }
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
    }

    private func refresh() {
        cacheSize = AudioCacheManager.shared.currentCacheSize
        cacheCount = AudioCacheManager.shared.cacheCount
    }
}
