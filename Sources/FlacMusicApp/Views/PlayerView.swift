import SwiftUI

public struct PlayerView: View {
    @ObservedObject var player = PlayerManager.shared
    @ObservedObject var playlist = PlaylistManager.shared
    @State private var showLyrics = false
    @State private var showQueue = false
    
    public init() {}
    
    public var body: some View {
        if let song = player.currentSong {
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: song.coverUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .overlay {
                                Image(systemName: "music.note")
                                    .foregroundColor(.secondary)
                            }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(song.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        Text(song.artist)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button {
                            player.playPrevious()
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.body)
                        }
                        .buttonStyle(.plain)
                        
                        if player.isLoading {
                            ProgressView()
                                .frame(width: 20, height: 20)
                        } else {
                            Button {
                                player.togglePlayPause()
                            } label: {
                                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.title2)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Button {
                            player.playNext()
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.body)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            player.togglePlayMode()
                        } label: {
                            Image(systemName: playlist.playMode.icon)
                                .font(.body)
                                .foregroundColor(playlist.playMode == .normal ? .secondary : .accentColor)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            showQueue = true
                        } label: {
                            Image(systemName: "list.bullet")
                                .font(.body)
                        }
                        .buttonStyle(.plain)
                        .overlay(alignment: .topTrailing) {
                            if playlist.queue.count > 1 {
                                Text("\(playlist.queue.count)")
                                    .font(.caption2)
                                    .padding(2)
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .offset(x: 4, y: -4)
                            }
                        }
                        
                        Button {
                            showLyrics = true
                        } label: {
                            Image(systemName: "text.quote")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            player.stop()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                
                if player.duration > 0 {
                    Slider(value: Binding(
                        get: { player.currentTime },
                        set: { player.seek(to: $0) }
                    ), in: 0...player.duration)
                    .tint(.accentColor)
                }
            }
            .sheet(isPresented: $showLyrics) {
                LyricsView(
                    lyrics: player.currentLyrics,
                    songName: song.name,
                    artist: song.artist,
                    player: player
                )
            }
            .sheet(isPresented: $showQueue) {
                QueueView()
            }
        }
    }
}

public struct LyricsView: View {
    let lyrics: String
    let songName: String
    let artist: String
    @ObservedObject var player: PlayerManager
    @Environment(\.dismiss) var dismiss
    
    private var parsedLyrics: [LyricLine] {
        parseLRC(lyrics)
    }
    
    private var currentLineIndex: Int? {
        findCurrentLineIndex(parsedLyrics, currentTime: player.currentTime)
    }
    
    public init(lyrics: String, songName: String, artist: String, player: PlayerManager) {
        self.lyrics = lyrics
        self.songName = songName
        self.artist = artist
        self.player = player
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text(songName)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(artist)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                if lyrics.isEmpty {
                    Spacer()
                    Text("暂无歌词")
                        .foregroundColor(.secondary)
                        .font(.title2)
                    Spacer()
                } else if !parsedLyrics.isEmpty {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(Array(parsedLyrics.enumerated()), id: \.element.id) { index, line in
                                    Text(line.text)
                                        .font(.body)
                                        .foregroundColor(index == currentLineIndex ? .white : .white.opacity(0.5))
                                        .scaleEffect(index == currentLineIndex ? 1.1 : 1.0)
                                        .opacity(index == currentLineIndex ? 1.0 : 0.6)
                                        .id(index)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .onChange(of: currentLineIndex) { _, newIndex in
                            if let index = newIndex {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(index, anchor: .center)
                                }
                            }
                        }
                    }
                } else {
                    ScrollView {
                        Text(lyrics)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                
                Spacer()
                
                if player.duration > 0 {
                    VStack(spacing: 8) {
                        Slider(value: Binding(
                            get: { player.currentTime },
                            set: { player.seek(to: $0) }
                        ), in: 0...player.duration)
                        .tint(.white)
                        
                        HStack {
                            Text(formatTime(player.currentTime))
                            Spacer()
                            Text(formatTime(player.duration))
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
                
                Button("关闭") {
                    dismiss()
                }
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 32)
            }
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
