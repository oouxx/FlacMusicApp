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
                List {
                    ForEach(Array(playlist.queue.enumerated()), id: \.offset) { index, song in
                        HStack {
                            if index == playlist.currentIndex {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.accentColor)
                                    .font(.caption)
                            } else {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(song.name)
                                    .font(.body)
                                    .lineLimit(1)
                                Text(song.artist)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            playlist.play(at: index)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            playlist.removeFromQueue(at: index)
                        }
                    }
                }
                .listStyle(.plain)
                
                if !playlist.queue.isEmpty {
                    Divider()
                    Button("清空队列") {
                        playlist.clearQueue()
                    }
                    .foregroundColor(.red)
                    .padding()
                }
            }
        }
    }
}
