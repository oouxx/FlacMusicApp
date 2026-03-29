import SwiftUI

public struct QueueView: View {
    @ObservedObject var playlist = PlaylistManager.shared
    @Environment(\.dismiss) var dismiss
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("播放队列")
                    .font(.headline)
                Spacer()
                Button("关闭") {
                    dismiss()
                }
            }
            .padding()
            
            Divider()
            
            if playlist.queue.isEmpty {
                Spacer()
                Text("播放队列为空")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(playlist.queue.enumerated()), id: \.offset) { index, song in
                            queueRow(song: song, index: index)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        playlist.removeFromQueue(at: index)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                
                Divider()
                
                Button(role: .destructive) {
                    playlist.clearQueue()
                } label: {
                    Label("清空队列", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private func queueRow(song: Song, index: Int) -> some View {
        Button {
            playlist.play(at: index)
        } label: {
            HStack(spacing: 12) {
                if index == playlist.currentIndex {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.accentColor)
                        .font(.caption)
                        .frame(width: 20)
                } else {
                    Text("\(index + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.name)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(song.artist)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
