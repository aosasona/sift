//
//  ArticlesList.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//

import SwiftUI

struct ArticlesList: View {
    var articles: [Article]
    
    @State private var searchText = ""
    
    var body: some View {
        List {
            Section {
                ForEach(
                    articles.filter { article in
                        searchText.isEmpty || article.title.localizedCaseInsensitiveContains(searchText)
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
                                }
                                
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search")
    }
}
