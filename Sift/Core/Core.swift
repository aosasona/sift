//
//  Shared.swift
//  Sift
//
//  Created by Ayodeji Osasona on 01/06/2025.
//
import Foundation
import Shared

enum CoreError: Error {
    case rawError(String)
}

struct ExtractedContent {
//    Title           string
//    Author          string
//    HTMLContent     string
//    TextContent     string
//    MarkdownContent string
//    Length          int
//    Excerpt         string
//    SiteName        string
//    Image           string
//    Favicon         string
//    Language        string
//    PublishedAt     *string // ISO 8601 format
//    ModifiedAt      *string // ISO 8601 format
}

class Core {
    public static func extractUrlContent(url: String) -> Result<ExtractedContent, CoreError> {
        let error: NSErrorPointer = nil

        Shared.CoreExtractURLContent(url, error)
    }
}
