import Foundation
import Testing

#if canImport(FlacMusicApp)
import FlacMusicApp

@Suite("MusicAPIService Real URL Tests")
struct MusicAPIServiceTests {
    
    @Test("searchSongs with empty keyword returns empty array")
    func testEmptyKeyword() async throws {
        let service = MusicAPIService()
        
        let result = try await service.searchSongs(keyword: "")
        
        #expect(result.isEmpty)
    }
    
    @Test("searchSongs with whitespace only returns empty array")
    func testWhitespaceKeyword() async throws {
        let service = MusicAPIService()
        
        let result = try await service.searchSongs(keyword: "   ")
        
        #expect(result.isEmpty)
    }
    
    @Test("kuwo platform search returns songs")
    func testKuwoSearch() async throws {
        let service = MusicAPIService()
        service.setPlatform(.kuwo)
        
        let songs = try await service.searchSongs(keyword: "hello", page: 1, pageSize: 5)
        
        #expect(!songs.isEmpty)
        
        let firstSong = songs[0]
        #expect(!firstSong.id.isEmpty)
        #expect(!firstSong.name.isEmpty)
        #expect(!firstSong.artist.isEmpty)
    }
    
    @Test("netease platform search returns songs")
    func testNeteaseSearch() async throws {
        let service = MusicAPIService()
        service.setPlatform(.netease)
        
        let songs = try await service.searchSongs(keyword: "hello", page: 1, pageSize: 5)
        
        #expect(!songs.isEmpty)
        
        let firstSong = songs[0]
        #expect(!firstSong.id.isEmpty)
        #expect(!firstSong.name.isEmpty)
    }
    
    @Test("search with pagination works")
    func testPagination() async throws {
        let service = MusicAPIService()
        service.setPlatform(.kuwo)
        
        let page1 = try await service.searchSongs(keyword: "test", page: 1, pageSize: 3)
        let page2 = try await service.searchSongs(keyword: "test", page: 2, pageSize: 3)
        
        #expect(!page1.isEmpty)
        #expect(!page2.isEmpty)
    }
    
    @Test("getSongURL returns URL for valid song")
    func testGetSongURL() async throws {
        let service = MusicAPIService()
        service.setPlatform(.kuwo)
        
        let songs = try await service.searchSongs(keyword: "hello", page: 1, pageSize: 1)
        #expect(!songs.isEmpty)
        
        let song = songs[0]
        let url = try await service.getSongURL(songId: song.id, format: .mp3320)
        
        #expect(url.isEmpty == false)
    }
}
#endif
