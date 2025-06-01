//
//  Error.swift
//  Sift
//
//  Created by Ayodeji Osasona on 01/06/2025.
//
import Foundation

public enum CoreError: Error {
    case presentable(String)
    case raw(Error)
    case rawString(String)
    case nilPointer
    
    var localizedDescription: String {
        switch self {
            case .presentable(let message):
                return message
            case .raw(let error):
                return error.localizedDescription
            case .rawString(let message):
                return message
            case .nilPointer:
                return "Received a nil pointer when an error was expected."
        }
    }
}

func unwrapNSErrorPointer(_ rawError: NSErrorPointer?) -> Error? {
    guard let err = rawError else { return nil }
    return err?.pointee
}

// Takes in a function that can produce an NSErrorPointer and converts it into a thrown error instead
func unwrapCoreError<T>(_ body: @escaping ((NSErrorPointer) -> T)) throws -> T {
    let error: NSErrorPointer = nil
    
    let result = body(error)
    if let err = unwrapNSErrorPointer(error) {
        throw CoreError.presentable(err.localizedDescription)
    }
    
    return result
}
