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

    @FetchAll(
        #sql(
            """
            SELECT * FROM articles
            WHERE label IN (SELECT category from preferred_categories)
            ORDER BY createdAt DESC
            """
        )
    ) var articles: [Article]

    var body: some View {
        NavigationStack {
            ArticlesList(articles: articles) {}
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
                }
        }
    }
}

//#Preview {
//    ForYouView()
//}
