//
//  ForYouView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//

import SharingGRDB
import SwiftUI

struct ForYouView: View {
    @FetchAll(
        #sql(
            """
            SELECT * FROM articles
            WHERE label IN (SELECT category from preferred_categories)
            ORDER BY publishedAt DESC
            """
        )
    ) var articles: [Article]

    var body: some View {
        NavigationStack {
            ArticlesList(articles: articles) {}
                .navigationTitle("For You")
        }
    }
}
