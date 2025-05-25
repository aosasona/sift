//
//  FollowedFeedsView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//

import SharingGRDB
import SwiftUI

struct FollowedFeedsView: View {
    @Dependency(\.defaultDatabase) private var database

    @FetchAll var followedFeeds: [Feed]

    @State private var searchText: String = ""
    @State private var showAddFeedSheet: Bool = false

    var body: some View {
        List {
            // MARK: feeds
            Section("Followed Feeds") {
                ForEach(
                    followedFeeds.filter {
                        searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText)
                    }
                ) { feed in
                    HStack(alignment: .center, spacing: 10) {
                        FeedImage(imageURL: feed.imageURL)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(feed.title)

                            Text(feed.url)
                                .font(.footnote)
                                .foregroundColor(.secondary)

                            if let syncedAt = feed.lastSyncedAt {
                                Text(
                                    "Last synced: \(syncedAt.formatted(date: .abbreviated, time: .shortened))"
                                )
                                .font(.caption)
                                .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                    .contextMenu {
                        if let syncedAt = feed.lastSyncedAt {
                            Label(
                                "Last synced: \(syncedAt.formatted(date: .abbreviated, time: .shortened))",
                                systemImage: "clock"
                            )
                            .foregroundColor(.secondary)
                        }

                        Button {
                            UIPasteboard.general.string = feed.url
                        } label: {
                            Label("Copy Link", systemImage: "doc.on.doc")
                        }

                        if let host = URL(string: feed.url)?.host {
                            Button {
                                if let hostURL = URL(string: "https://\(host)") {
                                    UIApplication.shared.open(hostURL)
                                }
                            } label: {
                                Label("Open website in Browser", systemImage: "safari")
                            }
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            removeFeed(feed)
                        } label: {
                            Label("Unfollow", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search feeds")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddFeedSheet) {
        }
    }

    private func removeFeed(_ feed: Feed) {
        withErrorReporting {
            do {
                try database.write { db in
                    try Feed.delete(feed).execute(db)
                }
            } catch {
                Log.shared.error("Failed to remove feed: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    let _ = try! prepareDependencies {
        let database = try AppDatabase.init().getDatabase()
        $0.defaultDatabase = database
    }

    FollowedFeedsView()
}
