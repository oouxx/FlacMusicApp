import SwiftUI

// MARK: - Search View

public struct SearchView: View {
    
    @EnvironmentObject private var vm: SearchViewModel
    @EnvironmentObject private var downloadManager: DownloadManager
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                SearchBarView(text: $vm.query)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                Divider()
                
                // Content area
                ZStack {
                    if vm.songs.isEmpty && !vm.isLoading {
                        emptyState
                    } else {
                        songList
                    }
                    
                    if vm.isLoading && vm.songs.isEmpty {
                        loadingIndicator
                    }
                }
            }
            .navigationTitle("🎵 无损音乐")
            #if os(macOS)
            .navigationSubtitle("搜索 · 下载 FLAC 高品质音乐")
            #endif
        }
    }
    
    // MARK: - Components
    
    private var songList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(vm.songs) { song in
                    SongRowView(song: song)
                        .environmentObject(vm)
                        .environmentObject(downloadManager)
                    
                    Divider()
                        .padding(.leading, 70)
                }
                
                if vm.hasMore {
                    Button {
                        Task { await vm.loadMore() }
                    } label: {
                        HStack {
                            if vm.isLoading {
                                ProgressView()
                            } else {
                                Text("下一页")
                                    .font(.callout)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                    .disabled(vm.isLoading)
                }
            }
        }
    }
}

extension SearchView {
    private var emptyState: some View {
        VStack(spacing: 16) {
            if let error = vm.errorMessage {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                Text(error)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Button("重试") { vm.retry() }
                    .buttonStyle(.bordered)
            } else if vm.query.isEmpty {
                Image(systemName: "music.note.list")
                    .font(.system(size: 56))
                    .foregroundColor(.secondary.opacity(0.5))
                Text("搜索歌曲、歌手或专辑")
                    .font(.title3)
                    .foregroundColor(.secondary)
                Text("支持下载 FLAC 无损音质")
                    .font(.callout)
                    .foregroundColor(.secondary.opacity(0.7))
            } else {
                Image(systemName: "music.note")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary.opacity(0.5))
                Text("没有找到 \(vm.query)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var loadingIndicator: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("搜索中...")
                .font(.callout)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Search Bar

struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索歌曲、歌手、专辑...", text: $text)
                .textFieldStyle(.plain)
                #if os(iOS)
                .keyboardType(.webSearch)
                .submitLabel(.search)
                #endif
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Song Row

struct SongRowView: View {
    let song: Song
    @EnvironmentObject private var vm: SearchViewModel
    @EnvironmentObject private var downloadManager: DownloadManager
    @State private var showingFormatPicker = false
    @State private var isLoadingURL = false
    @State private var urlError: String? = nil
    @State private var resolvedURL: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            // Cover
            CoverImageView(url: song.coverUrl)
                .frame(width: 52, height: 52)
                .cornerRadius(6)
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(song.name)
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(song.artist)
                        .font(.callout)
                        .foregroundColor(.secondary)
                    
                    Text("·")
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text(song.album)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 6) {
                    ForEach(song.formats, id: \.rawValue) { fmt in
                        FormatBadge(format: fmt)
                    }
                    
                    Spacer()
                    
                    Text(song.durationString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer(minLength: 0)
            
            // Play button
            Button {
                Task {
                    PlayerManager.shared.lastSearchQuery = vm.query
                    let playlist = PlaylistManager.shared
                    if !vm.songs.isEmpty {
                        playlist.setSearchResults(vm.songs)
                    }
                    await PlayerManager.shared.play(song: song)
                }
            } label: {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            
            // Download button
            downloadButton
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private var downloadButton: some View {
        if song.formats.count > 1 {
            Menu {
                ForEach(song.formats, id: \.rawValue) { fmt in
                    Button {
                        Task { await downloadManager.download(song: song, format: fmt) }
                    } label: {
                        Label(fmt.displayName + (fmt.isLossless ? " ✦" : ""),
                              systemImage: "arrow.down.circle")
                    }
                }
            } label: {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 22))
                    .foregroundColor(.accentColor)
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
        } else {
            Button {
                Task { await downloadManager.download(song: song, format: song.bestFormat) }
            } label: {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 22))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Format Badge

struct FormatBadge: View {
    let format: AudioFormat
    
    var body: some View {
        Text(format.displayName)
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(format.isLossless ? Color.green.opacity(0.15) : Color.blue.opacity(0.1))
            .foregroundColor(format.isLossless ? .green : .blue)
            .cornerRadius(4)
    }
}

// MARK: - Cover Image

struct CoverImageView: View {
    let url: String?
    
    var body: some View {
        if let urlStr = url, let imageURL = URL(string: urlStr) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    placeholder
                case .empty:
                    Color.secondary.opacity(0.1)
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        ZStack {
            Color.secondary.opacity(0.1)
            Image(systemName: "music.note")
                .foregroundColor(.secondary.opacity(0.5))
        }
    }
}
