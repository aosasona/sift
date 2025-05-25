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
    
//    @FetchAll(
//        #sql(
//            """
//            SELECT publishedAt FROM articles
//            """
//        )
//    ) var dates: [String]

    var body: some View {
        NavigationStack {
            List {
                Text("\(articles)")
                Section(header: Text("Recommended for You")) {
                    ForEach(0..<5) { index in
                        HStack(alignment: .top, spacing: 12) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sample Article Title \(index + 1)")
                                    .font(.headline)
                                Text(
                                    "Brief summary of the article goes here. It should be concise and engaging."
                                )
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
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
