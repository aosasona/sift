//
//  ArticlesList.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//

import SwiftUI

// TODO: add sorting options
struct ArticlesList<Content: View>: View {
    var articles: [Article]
    @ViewBuilder let content: Content?

    @State private var searchText = ""

    var body: some View {
        if articles.isEmpty {
            VStack {
                Image(systemName: "newspaper")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)
                    .padding()

                Text("No articles found")
                    .foregroundColor(.secondary)
                    .padding()
            }
        } else {
            articlesListView()
        }
    }

    @ViewBuilder
    func articlesListView() -> some View {
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

            Section {
                ForEach(
                    articles.filter { article in
                        searchText.isEmpty
                            || article.title.localizedCaseInsensitiveContains(searchText)
                    }
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
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search")
    }

    @ViewBuilder func publishDateView(article: Article) -> some View {
        if let publishedAt = article.publishedAt {
            Text(publishedAt, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
