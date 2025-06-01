import CoreML
import FeedKit

//
//  FeedManager.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//
import Foundation
import GRDB
import NaturalLanguage
import SharingGRDB
import SwiftSoup

struct FeedItem {
    let title: String
    let description: String?
    let link: String
    let htmlContent: String?
    let textContent: String?
    let publishedAt: Date?
}

@MainActor
class FeedManager: ObservableObject, @unchecked Sendable {
    private let database: any DatabaseWriter

    @Published var isRefreshing: Bool = false

    init(db: any DatabaseWriter) {
        database = db
    }

    func refreshAll() async {
        DispatchQueue.main.async {
            self.isRefreshing = true
        }

        defer {
            DispatchQueue.main.async {
                self.isRefreshing = false
            }
        }

        do {
            let feeds = try await database.read { db in
                try #sql<Feed>("SELECT * FROM feeds").fetchAll(db)
            }

            for feed in feeds {
                Task {
                    do {
                        try await self.refreshFeed(feed)
                    } catch {
                        print(error)
                        Log.shared.error(
                            "Failed to refresh feed \(feed.title): \(error.localizedDescription)",
                            error: error
                        )
                    }
                }
            }
        } catch {
            Log.shared.error("Failed to refresh feeds: \(error.localizedDescription)", error: error)
        }
    }

    func refreshFeed(_ feed: Feed) async throws {
        Log.shared.info("Refreshing feed: \(feed.title)")

        guard let items = try await loadFeedDetails(feed) else {
            Log.shared.error("Failed to load feed details for \(feed.title)")
            return
        }

        let feedItems = try await database.read { db in
            try #sql<Article>("SELECT * FROM articles WHERE feedId = \(feed.id!)")
                .fetchAll(db)
        }

        for item in items {
            // Check if the item already exists
            if feedItems.contains(where: { $0.url == item.link }) {
                Log.shared.debug("Item already exists: \(item.title)")
                continue
            }

            // Extract text content and HTML
            // TODO: replace this block with a more robust Go readability version
            guard let htmlContent = try? await loadHTML(url: item.link) else {
                Log.shared.error("Failed to load HTML for \(item.link)")
                continue
            }

            guard let parsed = parseHtml(url: item.link, html: htmlContent) else {
                Log.shared.error("Failed to parse HTML for \(item.link)")
                continue
            }

            // Heuristics-based summarization
            let summary = summarizeContent(
                title: parsed.title,
                text: parsed.textContent ?? "",
                n: 2
            )

            // Get predictions
            let model = try ArticleClassifier()
            let output = try await model.prediction(
                input: ArticleClassifierInput(text: summary)
            )

            let article = Article(
                title: parsed.title,
                url: item.link,
                description: item.description ?? "",
                htmlContent: parsed.htmlContent,
                textContent: parsed.textContent,
                summary: summary,
                label: output.label,
                feedID: feed.id!,
                createdAt: Date(),
                publishedAt: item.publishedAt ?? Date()
            )

            //            var articleId: Int?
            try await database.write { db in
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

            //            // Save the probabilities for the article
            //            try await self.database.write { db in
            //                for (label, probability) in output.classLabel_probs {
            //                    try db.execute(
            //                        sql: """
            //                            INSERT INTO predictions (articleId, label, confidence, createdAt)
            //                            VALUES (?, ?, ?, CURRENT_TIMESTAMP)
            //                            """,
            //                        arguments: [label, probability, articleId]
            //                    )
            //                }
            //            }

            Log.shared.info("Inserted article: \(article.title) with label \(article.label)")
        }
    }

    private func loadFeedDetails(_ feed: Feed) async throws -> [FeedItem]? {
        let parsedFeed = try await FeedKit.Feed(urlString: feed.url)

        switch parsedFeed {
        case let .rss(rss):
            return rss.channel?.items?.compactMap { item in
                FeedItem(
                    title: item.title ?? item.link ?? "Untitled",
                    description: item.description,
                    link: item.link ?? "",
                    htmlContent: nil,
                    textContent: nil,
                    publishedAt: item.pubDate
                )
            }

        case let .atom(atom):
            return atom.entries?.compactMap { entry in
                FeedItem(
                    title: entry.title ?? entry.links?.first?.attributes?.href ?? feed.url,
                    description: entry.summary?.text,
                    link: entry.links?.first?.attributes?.href ?? feed.url,
                    htmlContent: nil,
                    textContent: nil,
                    publishedAt: entry.published ?? entry.updated ?? Date()
                )
            }

        case let .json(json):
            return json.items?.compactMap { item in
                FeedItem(
                    title: item.title ?? item.url ?? "Untitled",
                    description: item.summary,
                    link: item.url ?? feed.url,
                    htmlContent: item.contentHtml,
                    textContent: item.contentText,
                    publishedAt: item.datePublished ?? Date()
                )
            }
        }
    }

    private func loadHTML(url: String) async throws -> String? {
        guard let url = URL(string: url) else {
            Log.shared.error("Invalid URL: \(url)")
            return nil
        }

        // Load with Mozilla User-Agent to avoid blocking
        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
            forHTTPHeaderField: "User-Agent"
        )
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let html = String(data: data, encoding: .utf8) else {
            Log.shared.error("Failed to decode HTML from \(url)")
            return nil
        }

        return html
    }

    private func parseHtml(url: String, html: String) -> FeedItem? {
        do {
            let document = try SwiftSoup.parse(html)

            let title = try document.title()
            let description =
                try document.select("meta[name=description]").first()?.attr("content") ?? ""
            let link = try document.select("link[rel=canonical]").first()?.attr("href") ?? ""
            let htmlContent = try document.body()?.html() ?? ""
            let textContent = try document.body()?.text() ?? ""

            return FeedItem(
                title: title,
                description: description.isEmpty ? nil : description,
                link: link.isEmpty ? url : link,
                htmlContent: htmlContent,
                textContent: textContent,
                publishedAt: nil
            )
        } catch {
            return .none
        }
    }

    private func summarizeContent(title: String, text: String, n: Int) -> String {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text

        var scoredSentences: [(sentence: String, score: Double)] = []
        let titleKeywords = Set(title.lowercased().split(separator: " ").map { String($0) })

        // Use the tokenizer to enumerate sentences instead of splitting on naive newlines
        tokenizer.enumerateTokens(in: text.startIndex ..< text.endIndex) { range, _ -> Bool in
            let sentence = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !sentence.isEmpty else { return true }

            let lengthScore = min(Double(sentence.count) / 100.0, 1.0) // normalize length to a 0-1 scale
            let positionScore = Double(scoredSentences.count) * 0.1 // earlier = better
            let keywordScore = titleKeywords.reduce(0) { currentScore, keyword in
                currentScore + (sentence.lowercased().contains(keyword) ? 1.0 : 0.0)
            } // normalize keyword presence to a 0-1 scale

            let totalScore = (lengthScore + positionScore + keywordScore)
            scoredSentences.append((sentence, totalScore))
            return true
        }

        // Sort by score and take the top N
        let topSentences =
            scoredSentences
                .sorted(by: { $0.score > $1.score })
                .prefix(n)
                .map { $0.sentence }

        return topSentences.joined(separator: " ")
    }
}
