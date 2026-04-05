import SwiftUI

public struct SettingsView: View {
    @State private var selectedProvider: MusicProvider = .hiCN
    @State private var selectedSource: MusicSource = .kuwo

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Group {
                    providerSection
                    sourceSection
                    debugSection
                    aboutSection
                }
            }
            .navigationTitle("设置")
        }
        .onAppear {
            selectedProvider = MusicAPIService.shared.currentProviderPublic
            selectedSource = MusicAPIService.shared.currentSourcePublic
        }
    }

    private var providerSection: some View {
        Section {
            providerRow(.hiCN)
            providerRow(.gdStudio)
            providerRow(.paojiao)
        } header: {
            Text("服务平台")
        } footer: {
            Text("切换平台后音乐源列表会自动更新。Hi音乐需要Cookie验证，GD Studio和泡椒音乐无需验证。")
        }
    }

    private func providerRow(_ provider: MusicProvider) -> some View {
        Button {
            selectedProvider = provider
            MusicAPIService.shared.setProvider(provider)
            selectedSource = MusicAPIService.shared.currentSourcePublic
        } label: {
            HStack {
                Text(provider.displayName)
                Spacer()
                if selectedProvider == provider {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var sourceSection: some View {
        Section {
            if selectedProvider == .gdStudio {
                ForEach(stableSources) { source in
                    sourceRow(source)
                }
                ForEach(otherSources) { source in
                    sourceRow(source)
                }
            } else {
                ForEach(selectedProvider.availableSources) { source in
                    sourceRow(source)
                }
            }
        } header: {
            Text("音乐源")
        } footer: {
            Text("切换后重新搜索生效，当前源的搜索结果和播放链接可能不同。")
        }
    }

    private var stableSources: [MusicSource] {
        selectedProvider.stableSources
    }

    private var otherSources: [MusicSource] {
        selectedProvider.availableSources.filter { !stableSources.contains($0) }
    }

    private func sourceRow(_ source: MusicSource) -> some View {
        Button {
            selectedSource = source
            MusicAPIService.shared.setSource(source)
        } label: {
            HStack {
                Text(source.displayName)
                Spacer()
                if selectedSource == source {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var debugSection: some View {
        Section {
            NavigationLink("查看日志", destination: LogsView())
            NavigationLink("缓存设置", destination: CacheSettingsView())
        } header: {
            Text("调试")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("版本")
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        } header: {
            Text("关于")
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
