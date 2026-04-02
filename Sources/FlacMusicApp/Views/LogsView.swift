import SwiftUI

public struct LogsView: View {
    @State private var logs: [Logger.LogEntry] = []
    @State private var showClearConfirm = false

    public init() {}

    public var body: some View {
        List {
            if logs.isEmpty {
                Text("暂无日志")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(logs) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entry.timeString)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(entry.category)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                        }
                        Text(entry.message)
                            .font(.caption)
                            .lineLimit(3)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("日志")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    let text = Logger.shared.exportAsText()
                    #if os(iOS)
                    let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.present(activityVC, animated: true)
                    }
                    #endif
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }

                Button(role: .destructive) {
                    showClearConfirm = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .onAppear { refresh() }
        .confirmationDialog("清空所有日志？", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("清空", role: .destructive) {
                Logger.shared.clear()
                refresh()
            }
            Button("取消", role: .cancel) {}
        }
    }

    private func refresh() {
        logs = Logger.shared.allLogs
    }
}