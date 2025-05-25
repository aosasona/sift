//
//  FeedUtils.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//

import Foundation
import FeedKit

struct ParsedFeed: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let url: String
    let description: String?
    let imageURL: String?
}

func loadFeed(url: String) async -> Result<ParsedFeed?, FeedError> {
    do {
        guard let parsedURL = URL(string: url) else {
            print("Invalid URL: \(url)")
            return .failure(.rawError("Invalid URL: \(url)"))
        }
        
        let host = parsedURL.host ?? parsedURL.absoluteString
        
        let parsedFeed = try await FeedKit.Feed(urlString: url)
        switch parsedFeed {
            case .rss(let feed):
                return .success(
                    ParsedFeed(
                        title: feed.channel?.title ?? host,
                        url: url,
                        description: feed.channel?.description ?? host,
                        imageURL: feed.channel?.image?.url
                    )
                )
            case .json(let feed):
                return .success(
                    ParsedFeed(
                        title: feed.title ?? host,
                        url: url,
                        description: feed.description == nil ? host : feed.description,
                        imageURL: feed.icon
                    )
                )
            case .atom(let feed):
                return .success(
                    ParsedFeed(
                        title: feed.title?.text ?? host,
                        url: url,
                        description: feed.subtitle?.text ?? host,
                        imageURL: feed.icon
                    )
                )
        }
    } catch {
        print("Failed to load feed from \(url): \(error)")
        return .failure(
            .rawError("Failed to load feed from \(url): \(error.localizedDescription)")
        )
    }
}

