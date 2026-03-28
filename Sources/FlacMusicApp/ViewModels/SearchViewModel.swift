import Foundation
import Combine

// MARK: - Search ViewModel

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
        // Debounce search
        $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard !query.isEmpty else {
                    self?.songs = []
                    return
                }
                Task { [weak self] in
                    await self?.search(query: query, reset: true)
                }
            }
            .store(in: &cancellables)
    }
    
    public func search(query: String, reset: Bool = false) async {
        searchTask?.cancel()
        
        if reset {
            currentPage = 1
            songs = []
        }
        
        isLoading = true
        errorMessage = nil
        
        searchTask = Task {
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
                
                // 如果是 Cookie 相关错误，清除缓存让用户重新验证
                let errorStr = error.localizedDescription.lowercased()
                if errorStr.contains("验证") || errorStr.contains("expired") || errorStr.contains("参数校验失败") || errorStr.contains("server error") {
                    MusicAPIService.shared.clearCookies()
                }
            }
            isLoading = false
        }
        
        await searchTask?.value
    }
    
    public func loadMore() async {
        guard !isLoading, hasMore, !query.isEmpty else { return }
        currentPage += 1
        await search(query: query, reset: false)
    }
    
    public func retry() {
        Task {
            await search(query: query, reset: true)
        }
    }
}
