import FeedKit
//
//  FeedManager.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//
import Foundation
import CoreML
import GRDB
import NaturalLanguage
import Readability
import SharingGRDB

struct FeedItem {
    let title: String
    let description: String?
    let link: String
    let htmlContent: String?
    let textContent: String?
}

class FeedManager: ObservableObject {
    private let database: any DatabaseWriter
    private let tokenMap: Vocab

    @MainActor
    private let readability = Readability()

    //    @Published var followedFeeds: [Feed] = []

    init(db: any DatabaseWriter) {
        self.database = db
        
        guard let tokenMap: Vocab = loadJson(from: "tokenizer") else {
            fatalError("Failed to load tokenizer data")
        }
        self.tokenMap = tokenMap
    }

    func refreshAll() async {
        do {
            try await database.read { db in
                let feeds = try #sql<Feed>("SELECT * FROM feeds").fetchAll(db)

                for feed in feeds {
                    Task {
                        do {
                            try await self.refreshFeed(feed, db: db)
                        } catch {
                            Log.shared.error(
                                "Failed to refresh feed \(feed.title): \(error.localizedDescription)",
                                error: error
                            )
                        }
                    }
                }
            }
        } catch {
            Log.shared.error("Failed to refresh feeds: \(error.localizedDescription)", error: error)
        }
    }

    private func refreshFeed(_ feed: Feed, db: Database) async throws {
        guard let items = try await self.loadFeedDetails(feed) else {
            Log.shared.error("Failed to load feed details for \(feed.title)")
            return
        }

        let feedItems = try #sql<Article>("SELECT * FROM articles WHERE feedId = \(feed.id!)")
            .fetchAll(db)

        for item in items {
            // Check if the item already exists
            if feedItems.contains(where: { $0.url == item.link }) {
                Log.shared.debug("Item already exists: \(item.title)")
                continue
            }

            // Extract text content and HTML
            let parsed = try await readability.parse(url: URL(string: item.link)!)

            let title = parsed.title
            let htmlContent = parsed.content
            let textContent = parsed.textContent
            let excerpt = parsed.excerpt

            let article = Article(
                title: title,
                url: item.link,
                htmlContent: htmlContent,
                textContent: textContent,
                summary: excerpt.isEmpty
                    ? self.sumamrizeContent(title: title, text: textContent)
                    : excerpt,
                publishedAt: Date(),
                feedID: feed.id!,
            )
            
            // Generate predictions for the article

            try await self.database.write { db in
                // Insert the article into the database
                try Article.insert(article).execute(db)

                // Update the feed's last sync date
                try db.execute(
                    sql: """
                        UPDATE feeds SET lastSyncedAt = CURRENT_TIMESTAMP WHERE id = ?
                        """,
                    arguments: [feed.id!]
                )
            }
        }
    }

    private func loadFeedDetails(_ feed: Feed) async throws -> [FeedItem]? {
        let parsedFeed = try await FeedKit.Feed(urlString: feed.url)

        switch parsedFeed {
        case .rss(let rss):
            return rss.channel?.items?.compactMap { item in
                return FeedItem(
                    title: item.title ?? item.link ?? "Untitled",
                    description: item.description,
                    link: item.link ?? "",
                    htmlContent: nil,
                    textContent: nil
                )
            }

        case .atom(let atom):
            return atom.entries?.compactMap { entry in
                return FeedItem(
                    title: entry.title ?? entry.links?.first?.attributes?.href ?? feed.url,
                    description: entry.summary?.text,
                    link: entry.links?.first?.attributes?.href ?? feed.url,
                    htmlContent: nil,
                    textContent: nil
                )
            }

        case .json(let json):
            return json.items?.compactMap { item in
                return FeedItem(
                    title: item.title ?? item.url ?? "Untitled",
                    description: item.summary,
                    link: item.url ?? feed.url,
                    htmlContent: item.contentHtml,
                    textContent: item.contentText
                )
            }

        }
    }

    private func loadHTML(url: String) async throws -> String? {
        guard let url = URL(string: url) else {
            Log.shared.error("Invalid URL: \(url)")
            return nil
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return String(data: data, encoding: .utf8)
    }

    private func sumamrizeContent(title: String, text: String) -> String {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text

        var scoredSentences: [(sentence: String, score: Double)] = []
        let titleKeywords = Set(title.lowercased().split(separator: " ").map { String($0) })

        // Use the tokenizer to enumerate sentences instead of splitting on naive newlines
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { (range, _) -> Bool in
            let sentence = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !sentence.isEmpty else { return true }

            let lengthScore = min(Double(sentence.count) / 100.0, 1.0)  // normalize length to a 0-1 scale
            let positionScore = Double(scoredSentences.count) * 0.1  // earlier = better
            let keywordScore = titleKeywords.reduce(0) { (currentScore, keyword) in
                currentScore + (sentence.lowercased().contains(keyword) ? 1.0 : 0.0)
            }  // normalize keyword presence to a 0-1 scale

            let totalScore = (lengthScore + positionScore + keywordScore)
            scoredSentences.append((sentence, totalScore))
            return true
        }

        // Sort by score and take the top 2
        let topSentences =
            scoredSentences
            .sorted(by: { $0.score > $1.score })
            .prefix(2)
            .map { $0.sentence }

        return topSentences.joined(separator: " ")
    }
}
