import SwiftUI

// MARK: - Downloads View

public struct DownloadsView: View {
    
    @EnvironmentObject private var downloadManager: DownloadManager
    
    public var body: some View {
        NavigationStack {
            Group {
                if downloadManager.tasks.isEmpty {
                    emptyState
                } else {
                    downloadList
                }
            }
            .navigationTitle("下载列表")
            .toolbar {
                if !downloadManager.tasks.isEmpty {
                    ToolbarItem(placement: .automatic) {
                        Button("清除已完成") {
                            downloadManager.clearCompleted()
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var downloadList: some View {
        List {
            ForEach(downloadManager.tasks) { task in
                DownloadRowView(task: task)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            downloadManager.removeTask(task)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 56))
                .foregroundColor(.secondary.opacity(0.4))
            
            Text("暂无下载任务")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("在搜索页面点击下载按钮\n开始下载无损音乐")
                .font(.callout)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Download Row

struct DownloadRowView: View {
    let task: DownloadTask
    
    var body: some View {
        HStack(spacing: 12) {
            // Cover
            CoverImageView(url: task.song.coverUrl)
                .frame(width: 44, height: 44)
                .cornerRadius(6)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.song.name)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                
                Text(task.song.artist)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // Progress / status
                statusView
            }
            
            Spacer()
            
            // Format badge
            FormatBadge(format: task.format)
            
            // Action
            actionView
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch task.state {
        case .pending:
            Text("等待中...")
                .font(.caption)
                .foregroundColor(.secondary)
        case .downloading:
            ProgressView(value: task.progress)
                .progressViewStyle(.linear)
                .frame(maxWidth: 160)
        case .completed:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("下载完成")
                    .foregroundColor(.green)
            }
            .font(.caption)
        case .failed(let msg):
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                Text(msg)
                    .lineLimit(1)
                    .foregroundColor(.red)
            }
            .font(.caption)
        }
    }
    
    @ViewBuilder
    private var actionView: some View {
        switch task.state {
        case .completed:
            if let url = task.localURL {
                #if os(macOS)
                Button {
                    NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "")
                } label: {
                    Image(systemName: "folder")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                #else
                ShareLink(item: url) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                #endif
            }
        default:
            EmptyView()
        }
    }
}
