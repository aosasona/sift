//
//  Log.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//
import Foundation
import os.log

public enum Level: String {
    case debug, info, warning, error, trace

    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .fault
        case .error: return .error
        case .trace: return .debug
        }
    }
}

public class Log {
    public static let shared: Log = Log(scope: "shared")

    private let logger: Logger
    private let scope: String
    private let level: Level

    private init(scope: String, level: Level = .debug) {
        self.scope = scope
        self.level = level

        self.logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "tools.keystroke.sift",
            category: scope
        )
    }

    public static func withScope(_ scope: String) -> Log {
        return Log(scope: scope)
    }

    private func log(
        _ message: String,
        level: Level,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let errorMessage = error.map { " - Error: \($0.localizedDescription)" } ?? ""

        let logMessage = "[\(fileName):\(line) \(function)] \(message)\(errorMessage)"

        let scope_ = scope.isEmpty ? "shared" : scope
        logger.log(
            level: level.osLogType,
            "\(level.rawValue, privacy: .public) |  \(scope_, privacy: .public) | \(logMessage, privacy: .public)"
        )
    }

    public func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
            log(message, level: .debug, error: nil, file: file, function: function, line: line)
        #endif
    }

    public func trace(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard level == .trace else { return }
        // Trace logs are only logged if the level is set to trace and we are in debug mode
        #if DEBUG
            log(message, level: .trace, error: nil, file: file, function: function, line: line)
        #endif
    }

    public func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .info, error: nil, file: file, function: function, line: line)
    }

    public func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .warning, error: nil, file: file, function: function, line: line)
    }

    public func error(
        _ message: String,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .error, error: error, file: file, function: function, line: line)
    }
}
