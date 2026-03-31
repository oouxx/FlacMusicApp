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
    private var cancellables = Set<AnyCancellable>()

    public init() {
        $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                guard !query.isEmpty else {
                    // 取消正在进行的搜索，清空结果
                    self.searchTask?.cancel()
                    self.searchTask = nil
                    self.songs = []
                    self.isLoading = false
                    self.errorMessage = nil
                    return
                }
                // 直接调用而不是另起 Task，避免并发竞争
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
        // 不 await searchTask?.value，避免旧 Task 堵塞新搜索
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

    // MARK: - Private

    private func performSearch(query: String, reset: Bool) async {
        if reset {
            currentPage = 1
            songs = []
        }

        isLoading = true
        errorMessage = nil

        defer {
            // 无论成功、失败、取消，都保证 isLoading 重置
            isLoading = false
        }

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

        } catch {
            guard !Task.isCancelled else { return }

            errorMessage = error.localizedDescription

            // 只在明确的 Cookie 失效错误时才清除，避免网络波动误触发
            if case MusicAPIError.cookiesRequired = error {
                MusicAPIService.shared.clearCookies()
            }
        }
    }
}
