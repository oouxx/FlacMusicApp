import Foundation

public struct LyricLine: Identifiable, Equatable {
    public let id = UUID()
    public let timestamp: Double
    public let text: String
    
    public init(timestamp: Double, text: String) {
        self.timestamp = timestamp
        self.text = text
    }
}

public final class LyricsParser {
    public static let shared = LyricsParser()
    
    private init() {}
    
    public func parseLRC(_ lrc: String) -> [LyricLine] {
        // 支持多种格式: [mm:ss], [mm:ss.ms], [mm:ss.msms], [mm:ss.msmsms]
        let pattern = #"\[(\d{1,2}):(\d{2})(?:\.(\d{1,3}))?\](.*)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let lines = lrc.components(separatedBy: .newlines)
        var result: [LyricLine] = []
        
        for line in lines {
            let range = NSRange(line.startIndex..<line.endIndex, in: line)
            let matches = regex.matches(in: line, options: [], range: range)
            
            for match in matches {
                if match.numberOfRanges >= 5 {
                    let minRange = Range(match.range(at: 1), in: line)!
                    let secRange = Range(match.range(at: 2), in: line)!
                    let msRange = Range(match.range(at: 3), in: line)!
                    let textRange = Range(match.range(at: 4), in: line)!
                    
                    let minutes = Int(line[minRange]) ?? 0
                    let seconds = Int(line[secRange]) ?? 0
                    let milliseconds = match.numberOfRanges >= 4 && !line[msRange].isEmpty ? Int(line[msRange]) ?? 0 : 0
                    
                    let timestamp = Double(minutes * 60 + seconds) + Double(milliseconds) / 1000.0
                    let text = String(line[textRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !text.isEmpty {
                        result.append(LyricLine(timestamp: timestamp, text: text))
                    }
                }
            }
        }
        
        return result.sorted { $0.timestamp < $1.timestamp }
    }
    
    public func findCurrentLineIndex(_ lines: [LyricLine], currentTime: Double) -> Int? {
        guard !lines.isEmpty else { return nil }
        
        for i in (0..<lines.count).reversed() {
            if currentTime >= lines[i].timestamp {
                return i
            }
        }
        
        return 0  // 返回第一行而不是 nil
    }
}