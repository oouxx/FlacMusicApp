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

public func parseLRC(_ lrc: String) -> [LyricLine] {
    var lines: [LyricLine] = []
    let pattern = #"\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)"#
    
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        return lines
    }
    
    let lrcLines = lrc.components(separatedBy: .newlines)
    
    for line in lrcLines {
        let range = NSRange(line.startIndex..., in: line)
        if let match = regex.firstMatch(in: line, options: [], range: range) {
            guard let minutesRange = Range(match.range(at: 1), in: line),
                  let secondsRange = Range(match.range(at: 2), in: line),
                  let millisecondsRange = Range(match.range(at: 3), in: line),
                  let textRange = Range(match.range(at: 4), in: line) else {
                continue
            }
            
            let minutes = Double(line[minutesRange]) ?? 0
            let seconds = Double(line[secondsRange]) ?? 0
            let millisecondsStr = String(line[millisecondsRange])
            let milliseconds = (Double(millisecondsStr) ?? 0) / (millisecondsStr.count == 2 ? 100 : 1000)
            
            let timestamp = minutes * 60 + seconds + milliseconds
            let text = String(line[textRange]).trimmingCharacters(in: .whitespaces)
            
            if !text.isEmpty {
                lines.append(LyricLine(timestamp: timestamp, text: text))
            }
        }
    }
    
    return lines.sorted { $0.timestamp < $1.timestamp }
}

public func findCurrentLineIndex(_ lines: [LyricLine], currentTime: Double) -> Int? {
    guard !lines.isEmpty else { return nil }
    
    for i in (0..<lines.count).reversed() {
        if currentTime >= lines[i].timestamp {
            return i
        }
    }
    
    return nil
}
