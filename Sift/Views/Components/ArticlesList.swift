//
//  ArticlesList.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//

import Dependencies
import SwiftUI

enum OrderBy: Hashable {
    case title(OrderDirection)
    case createdAt(OrderDirection)
    case publishedAt(OrderDirection)
    case label(OrderDirection)

    enum OrderDirection {
        case ascending
        case descending
    }
}

struct ArticlesList<Content: View>: View {
    @Dependency(\.defaultDatabase) private var database
    @EnvironmentObject var feedManager: FeedManager

    var articles: [Article]
    @ViewBuilder let content: Content?

    @State private var orderBy: OrderBy = .publishedAt(.descending)
    @State private var searchText = ""

    var body: some View {
        List {
            if let content = content {
                Section {
                    content
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowSeparatorTint(.clear)
            }

            if articles.isEmpty {
                emptyView()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowSeparatorTint(.clear)
            }

            Section {
                ForEach(
                    sortArticles(
                        articles.filter { article in
                            searchText.isEmpty
                                || article.title.localizedCaseInsensitiveContains(searchText)
                        }
                    )
                ) { article in
                    NavigationLink(destination: ArticleView(article: article)) {
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(article.title)
                                    .font(.headline)
                                    .lineLimit(2)

                                Text(article.summary ?? "No description available")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                    .truncationMode(.tail)

                                HStack {
                                    Text(article.label.capitalized)
                                        .font(.caption)
                                        .foregroundColor(article.labelColor)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 6)
                                        .background(article.labelColor.opacity(0.2))
                                        .cornerRadius(12)

                                    Spacer()

                                    publishDateView(article: article)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task {
                                try database.write { db in
                                    try Article.delete(article).execute(db)
                                }
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search")
        .refreshable {
            await feedManager.refreshAll()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if feedManager.isRefreshing {
                    ProgressView()
                        .tint(.accentColor)
                }

                Menu {
                    Picker("Sort by", selection: $orderBy) {
                        Text("Title (A-Z)").tag(OrderBy.title(.ascending))
                        Text("Title (Z-A)").tag(OrderBy.title(.descending))
                        Text("Created At (Newest First)").tag(OrderBy.createdAt(.descending))
                        Text("Created At (Oldest First)").tag(OrderBy.createdAt(.ascending))
                        Text("Published At (Newest First)").tag(OrderBy.publishedAt(.descending))
                        Text("Published At (Oldest First)").tag(OrderBy.publishedAt(.ascending))
                        Text("Label (A-Z)").tag(OrderBy.label(.ascending))
                        Text("Label (Z-A)").tag(OrderBy.label(.descending))
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }

    @ViewBuilder
    func emptyView() -> some View {
        VStack {
            Spacer()

            Image(systemName: "newspaper")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .padding()

            Text("No articles found")
                .foregroundColor(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minHeight: UIScreen.main.bounds.height * 0.6)
        .background(Color.clear)
    }

    @ViewBuilder func publishDateView(article: Article) -> some View {
        if let publishedAt = article.publishedAt {
            Text(publishedAt, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    func sortArticles(_ articles: [Article]) -> [Article] {
        switch orderBy {
        case let .title(direction):
            return articles.sorted { direction == .ascending ? $0.title < $1.title : $0.title > $1.title }
        case let .createdAt(direction):
            if direction == .ascending {
                return articles.sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }
            } else {
                return articles.sorted { $0.createdAt ?? Date() > $1.createdAt ?? Date() }
            }
        case let .publishedAt(direction):
            if direction == .ascending {
                return articles.sorted { $0.publishedAt ?? Date() < $1.publishedAt ?? Date() }
            } else {
                return articles.sorted { $0.publishedAt ?? Date() > $1.publishedAt ?? Date() }
            }
        case let .label(direction):
            return articles.sorted { direction == .ascending ? $0.label < $1.label : $0.label > $1.label }
        }
    }
}
