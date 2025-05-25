//
//  ArticlesListView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//

import Dependencies
import SharingGRDB
import SwiftUI

struct ArticlesListView: View {
    @Dependency(\.defaultDatabase) private var database

    @State private var articles: [Article] = []
    @State private var currentCategory: String? = nil

    @FetchAll(
        #sql(
            """
            SELECT * FROM \(Category.self) WHERE `set` = (SELECT MAX(`version`) FROM \(LabelSet.self))
            """
        )
    ) var categories: [Category]

    var body: some View {
        NavigationStack {

            ArticlesList(articles: articles) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button {
                            currentCategory = nil
                        } label: {
                            Text("All")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(
                                    currentCategory == nil
                                        ? Color.accentColor : Color.gray.opacity(0.2)
                                )
                                .foregroundColor(currentCategory == nil ? .white : .primary)
                                .clipShape(Capsule())
                        }

                        ForEach(categories, id: \.name) { category in
                            Button {
                                withAnimation {
                                    currentCategory = category.name
                                }
                            } label: {
                                Text(category.name.capitalized)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(
                                        currentCategory == category.name
                                            ? Color.accentColor : Color.gray.opacity(0.2)
                                    )
                                    .foregroundColor(
                                        currentCategory == category.name ? .white : .primary
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle(currentCategory?.capitalized ?? "All Articles")
            .task(id: currentCategory) {
                await updateQuery()
            }
        }
    }

    private func updateQuery() async {
        do {
            try await database.read { db in
                let articles = try #sql<Article>(
                    """
                    SELECT * FROM \(Article.self)
                    WHERE \(bind: currentCategory  ?? "") = '' OR label = \(bind: currentCategory ?? "")
                    """
                ).fetchAll(db)

                withAnimation(.easeInOut) {
                    DispatchQueue.main.async {
                        self.articles = articles
                    }
                }
            }
        } catch {
            Log.shared.error(
                "Failed to load articles: \(error.localizedDescription)",
                error: error
            )
        }
    }
}
