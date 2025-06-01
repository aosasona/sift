//
//  Shared.swift
//  Sift
//
//  Created by Ayodeji Osasona on 01/06/2025.
//
import Foundation
import Shared

public struct ExtractedContent {
    let title: String
    let author: String
    let htmlContent: String
    let textContent: String
    let markdownContent: String
    let length: Int
    let excerpt: String
    let siteName: String
    let image: String
    let favicon: String
    let language: String
    let publishedAt: Date?
    let modifiedAt: Date?
}

public class Core {
    public static func extractUrlContent(url: String) -> Result<ExtractedContent, CoreError> {
        do {
            let result = try unwrapCoreError { Shared.CoreExtractURLContent(url, $0) }
            guard let content = result else {
                return .failure(CoreError.nilPointer)
            }

            let extractedContent = ExtractedContent(
                title: content.title,
                author: content.author,
                htmlContent: content.htmlContent,
                textContent: content.textContent,
                markdownContent: content.markdownContent,
                length: content.length,
                excerpt: content.excerpt,
                siteName: content.siteName,
                image: content.image,
                favicon: content.favicon,
                language: content.language,
                publishedAt: content.publishedAt > 0
                    ? Date(timeIntervalSince1970: TimeInterval(content.publishedAt)) : nil,
                modifiedAt: content.modifiedAt > 0
                    ? Date(timeIntervalSince1970: TimeInterval(content.modifiedAt)) : nil
            )

            return .success(extractedContent)
        } catch let error as CoreError {
            return .failure(error)
        } catch {
            return .failure(.raw(error))
        }
    }
}
