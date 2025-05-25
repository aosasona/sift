//
//  ForYouView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//

import SharingGRDB
import SwiftUI

struct ForYouView: View {
    @EnvironmentObject var feedManager: FeedManager

    @State private var showSettings = false

    @FetchAll(
        #sql(
            """
            SELECT * FROM articles
            WHERE label IN (SELECT category from preferred_categories)
            """
        )
    ) var articles: [Article]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(articles) { article in
                        NavigationLink(destination: ArticleView(article: article)) {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(article.title)
                                        .font(.headline)
                                    Text(article.summary ?? "No description available")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("For You")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if feedManager.isRefreshing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Button(action: {
                            Task {
                                await feedManager.refreshAll()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.accentColor)
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

//#Preview {
//    ForYouView()
//}
