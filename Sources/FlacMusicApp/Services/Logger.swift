//
//  Logger.swift
//  FlacMusicApp
//
//  Memory log collector for debugging
//

import Foundation

public class Logger {
    public static let shared = Logger()

    private var logs: [LogEntry] = []
    private let queue = DispatchQueue(label: "com.flacmusic.logger")
    private let maxLogs = 500

    public struct LogEntry: Identifiable {
        public let id = UUID()
        public let timestamp: Date
        public let message: String
        public let category: String

        public init(timestamp: Date, message: String, category: String) {
            self.timestamp = timestamp
            self.message = message
            self.category = category
        }

        public var timeString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            return formatter.string(from: timestamp)
        }
    }

    private init() {}

    public func log(_ message: String, category: String = "App") {
        let entry = LogEntry(timestamp: Date(), message: message, category: category)
        queue.sync {
            logs.insert(entry, at: 0)
            if logs.count > maxLogs {
                logs.removeLast()
            }
        }
        print("[\(category)] \(message)")
    }

    public var allLogs: [LogEntry] {
        queue.sync { logs }
    }

    public func clear() {
        queue.sync { logs.removeAll() }
    }

    public func exportAsText() -> String {
        allLogs.map { "[\($0.timeString)] [\($0.category)] \($0.message)" }.joined(separator: "\n")
    }
}