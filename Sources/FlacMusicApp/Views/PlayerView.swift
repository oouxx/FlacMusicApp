import SwiftUI

public struct PlayerView: View {
    @ObservedObject var player = PlayerManager.shared
    @State private var showLyrics = false
    
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
                    
                    if player.isLoading {
                        ProgressView()
                            .frame(width: 24, height: 24)
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
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                
                if player.duration > 0 {
                    ProgressView(value: player.currentTime, total: player.duration)
                        .tint(.accentColor)
                }
            }
            .sheet(isPresented: $showLyrics) {
                LyricsView(lyrics: player.currentLyrics, songName: song.name, artist: song.artist)
            }
        }
    }
}

public struct LyricsView: View {
    let lyrics: String
    let songName: String
    let artist: String
    @Environment(\.dismiss) var dismiss
    
    public init(lyrics: String, songName: String, artist: String) {
        self.lyrics = lyrics
        self.songName = songName
        self.artist = artist
    }
    
    public var body: some View {
        VStack {
            Text(songName)
                .font(.headline)
            Text(artist)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView {
                Text(lyrics.isEmpty ? "暂无歌词" : lyrics)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button("关闭") {
                dismiss()
            }
            .padding()
        }
    }
}
