import Foundation
import Combine

@MainActor
public final class SearchViewModel: ObservableObject {

    @Published public var query: String = ""
    @Published public var songs: [Song] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var currentPage: Int = 1
    @Published public var hasMore: Bool = false

    private let pageSize = 30
    private var searchTask: Task<Void, Never>?
    private var silentRefreshTask: Task<Void, Never>?
    private let signRefreshInterval: TimeInterval = 300  // 5 分钟静默刷新一次 sign
    private var cancellables = Set<AnyCancellable>()

    public init() {
        $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                guard !query.isEmpty else {
                    self.searchTask?.cancel()
                    self.searchTask = nil
                    self.silentRefreshTask?.cancel()
                    self.silentRefreshTask = nil
                    self.songs = []
                    self.isLoading = false
                    self.errorMessage = nil
                    return
                }
                self.searchTask?.cancel()
                self.searchTask = Task {
                    await self.performSearch(query: query, reset: true)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public

    public func search(query: String, reset: Bool = false) async {
        searchTask?.cancel()
        searchTask = Task {
            await performSearch(query: query, reset: reset)
        }
    }

    public func loadMore() async {
        guard !isLoading, hasMore, !query.isEmpty else { return }
        currentPage += 1
        await search(query: query, reset: false)
    }

    public func retry() {
        searchTask?.cancel()
        searchTask = Task {
            await performSearch(query: query, reset: true)
        }
    }

    // MARK: - Private Search

    private func performSearch(query: String, reset: Bool) async {
        if reset {
            currentPage = 1
            songs = []
            // 新搜索开始时取消旧的静默刷新
            silentRefreshTask?.cancel()
            silentRefreshTask = nil
        }

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        guard !Task.isCancelled else { return }

        do {
            let results = try await MusicAPIService.shared.searchSongs(
                keyword: query,
                page: currentPage,
                pageSize: pageSize
            )

            guard !Task.isCancelled else { return }

            if reset {
                songs = results
            } else {
                songs.append(contentsOf: results)
            }
            hasMore = results.count == pageSize

            if reset && MusicAPIService.shared.currentProvider == .hiCN {
                scheduleSilentRefresh(query: query)
            }

        } catch {
            guard !Task.isCancelled else { return }

            errorMessage = error.localizedDescription

            if case MusicAPIError.cookiesRequired = error {
                MusicAPIService.shared.clearCookies()
            }
        }
    }

    // MARK: - Silent Sign Refresh

    /// 后台定期刷新 sign 缓存，用户无感知
    private func scheduleSilentRefresh(query: String) {
        silentRefreshTask?.cancel()
        silentRefreshTask = Task {
            do {
                try await Task.sleep(for: .seconds(signRefreshInterval))
            } catch {
                return  // 被取消，正常退出
            }

            guard !Task.isCancelled, !query.isEmpty else { return }

            print("[Search] Silent refreshing sign cache for: \(query)")
            do {
                _ = try await MusicAPIService.shared.searchSongs(
                    keyword: query,
                    page: 1,
                    pageSize: pageSize
                )
                // searchSongs 内部自动更新 signCache/timeCache
                // 不替换 songs 列表，避免用户正在浏览时列表跳动
                print("[Search] Silent refresh done, sign cache updated")

                guard !Task.isCancelled else { return }
                // 递归调度下一次
                scheduleSilentRefresh(query: query)
            } catch {
                print("[Search] Silent refresh failed: \(error), will retry next cycle")
                // 失败后稍等再试，不影响用户
                guard !Task.isCancelled else { return }
                scheduleSilentRefresh(query: query)
            }
        }
    }
}
