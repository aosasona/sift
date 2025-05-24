//
//  Logger.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//
import Foundation

enum Level: String {
    case debug, info, warning, error
}

private struct Log {
    let scope: String
    let level: Level
    let message: String
    let date: Date

    static func new(scope: String, level: Level, message: String) -> Log {
        .init(scope: scope, level: level, message: message, date: .now)
    }

    func toString() -> String {
        let emoji =
            switch level {
            case .debug: "⬛️"
            case .info: "🟦"
            case .warning: "🟧"
            case .error: "🟥"
            }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: Date())

        return "\(emoji) [\(timestamp)] [\(level.rawValue.uppercased())] \(scope): \(message)"
    }
}

class Logger {
    static let shared = Logger()

    private let logDirectory: String
    private var logFilename: String
    private var logFile: FileHandle?
    private let dispatchQueue: DispatchQueue
    private var bufferedLogs: [Log] = []

    init(
        directory: String = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first!.appending("/logs"),
        dispatchQueue: DispatchQueue = .global(qos: .background)
    ) {
        self.logDirectory = directory
        Logger.createLogDirectoryIfNeeded(directory: directory)

        self.dispatchQueue = dispatchQueue
        self.logFilename = Logger.getFilename()
        guard let fileHandle = Logger.openFile(directory: directory, filename: logFilename) else {
            print("Could not open log file at \(directory)/\(logFilename)")
            return
        }
        self.logFile = fileHandle
        commitAfterInterval()
    }

    deinit {
        if !bufferedLogs.isEmpty {
            flushBufferedLogs()
        }

        guard let logFile else { return }
        logFile.closeFile()
    }

    func downloadLogFile(to url: URL) {
        guard let logFile else { return }

        let data = logFile.readDataToEndOfFile()
        try? data.write(to: url)
    }

    // Flush the log's buffer to the file system after `interval` (defaults to 5 seconds)
    func commitAfterInterval(interval: TimeInterval = 5) {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.dispatchQueue.async {
                if !self.bufferedLogs.isEmpty {
                    self.flushBufferedLogs()
                }
            }
        }

        if logFile == nil { timer.invalidate() }
    }

    func log(scope: String, message: String, level: Level) {
        let log = Log.new(scope: scope, level: level, message: message)
        bufferedLogs.append(log)

        #if DEBUG
            print(log.toString())
        #endif
    }

    func warn(scope: String, _ message: String) {
        log(scope: scope, message: message, level: .warning)
    }

    func error(scope: String, _ message: String) {
        log(scope: scope, message: message, level: .error)
    }

    func debug(scope: String, _ message: String) {
        log(scope: scope, message: message, level: .debug)
    }

    func info(scope: String, _ message: String) {
        log(scope: scope, message: message, level: .info)
    }

    func getCurrentLogFileName() -> String? {
        return logFilename
    }

    private func flushBufferedLogs() {
        do {
            guard let logFile else { return }

            for log in bufferedLogs {
                let logString = log.toString()
                // Append to log file
                try logFile.seekToEnd()
                logFile.write(logString.data(using: .utf8)!)
            }

            bufferedLogs.removeAll()

            // If it is a new day, change the logfile (some logs will spill over but that is okay)
            if logFilename != Logger.getFilename() {
                let newLogFilename = Logger.getFilename()
                logFile.closeFile()
                setLogfile(filename: newLogFilename)
            }
        } catch {
            print("Could not flush buffered logs: \(error)")
        }
    }

    private static func createLogDirectoryIfNeeded(directory: String) {
        if !FileManager.default.fileExists(atPath: directory) {
            do {
                try FileManager.default.createDirectory(
                    atPath: directory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                print("Could not create log directory at \(directory)")
            }
        }
    }

    private func setLogfile(filename: String) {
        logFilename = filename
        guard let logFile = Logger.openFile(directory: logDirectory, filename: logFilename) else {
            print("Could not open log file at \(logDirectory)/\(logFilename)")
            return
        }
        self.logFile = logFile
    }

    private static func openFile(directory: String, filename: String) -> FileHandle? {
        do {
            let logFileURL = URL(fileURLWithPath: directory).appendingPathComponent(filename)
            if !FileManager.default.fileExists(atPath: logFileURL.path) {
                FileManager.default.createFile(
                    atPath: logFileURL.path,
                    contents: nil,
                    attributes: nil
                )
            }

            return try FileHandle(forUpdating: logFileURL)
        } catch {
            print("Could not open log file: \(error)")
            return nil
        }
    }

    // Returns a log file with today's date as the file name
    static func getFilename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: Date())
        return "\(date).log"
    }
}
