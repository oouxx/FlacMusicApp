import SwiftUI

public struct SettingsView: View {
    public init() {}

    public var body: some View {
        List {
            Section {
                NavigationLink("查看日志", destination: LogsView())
                NavigationLink("缓存设置", destination: CacheSettingsView())
            } header: {
                Text("调试")
            }

            Section {
                HStack {
                    Text("版本")
                    Spacer()
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("关于")
            }
        }
        .navigationTitle("设置")
    }
}