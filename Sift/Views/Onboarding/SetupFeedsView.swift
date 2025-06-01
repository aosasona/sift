//
//  SetupFeedsView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//
import Foundation
import SwiftUI

import AlertToast
import Dependencies
import FeedKit

let ImageSize: CGFloat = 28

enum FeedError: Error {
    case rawError(String)
}

let defaultFeeds: [String] = [
    "https://andreabergia.com/index.xml",
    "https://www.gingerbill.org/article/index.xml",
    "https://fasterthanli.me/index.xml",
    "https://hypercritical.co/feeds/main",
    "https://world.hey.com/jason/feed.atom",
    "https://jvns.ca/atom.xml",
    "https://www.manton.org/feed.xml",
    "https://steveklabnik.com/feed.xml",
]

class ToastState: ObservableObject {
    @Published var showToast = false
    @Published var title: String = ""
    @Published var message: String = ""
}

struct SetupFeedsView: View {
    @Dependency(\.defaultDatabase) private var database
    @EnvironmentObject private var feedManager: FeedManager

    #if DEBUG
        @State private var recommendedFeeds: [ParsedFeed] = [
            ParsedFeed(
                title: "Andrea Bergia's Website",
                url: "https://andreabergia.com/index.xml",
                description: "Recent content on Andrea Bergia's Website",
                imageURL: nil
            ),
            ParsedFeed(
                title: "Articles on gingerBill",
                url: "https://www.gingerbill.org/article/index.xml",
                description: "Recent content in Articles on gingerBill",
                imageURL: nil
            ),
            ParsedFeed(
                title: "fasterthanli.me",
                url: "https://fasterthanli.me/index.xml",
                description: "amos likes to tinker",
                imageURL:
                "https://cdn.fasterthanli.me/content/img/logo-square-2~d615b662ee99387f.w900.webp"
            ),
            ParsedFeed(
                title: "Jason Fried",
                url: "https://world.hey.com/jason/feed.atom",
                description: nil,
                imageURL: nil
            ),
            ParsedFeed(
                title: "Julia Evans",
                url: "https://jvns.ca/atom.xml",
                description: nil,
                imageURL: nil
            ),
        ]
        @State private var hasLoadedRecommendedFeeds = true
    #else
        @State private var recommendedFeeds: [ParsedFeed] = []
        @State private var hasLoadedRecommendedFeeds = false
    #endif

    @State private var currentFeedURL: String = ""
    @State private var feeds: [ParsedFeed] = []

    @State private var isAddingFeed = false

    @StateObject private var toastState = ToastState()

    var body: some View {
        VStack {
            Text("Your Feeds")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)

            Text("Add your favorite publications to get started.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            HStack {
                TextField("Enter feed URL", text: $currentFeedURL)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .submitLabel(.done)
                    .textFieldStyle(.roundedBorder)
                    .padding(.trailing, 8)
                    .onSubmit {
                        guard !currentFeedURL.isEmpty else { return }

                        isAddingFeed = true
                        Task {
                            let result = await loadFeed(url: currentFeedURL)
                            switch result {
                            case let .success(parsedFeed):
                                if let parsedFeed = parsedFeed {
                                    withAnimation {
                                        feeds.append(parsedFeed)
                                    }
                                    currentFeedURL = ""
                                } else {
                                    toastState.title = "Invalid Feed"
                                    toastState.message = "The feed URL you entered is invalid."
                                    toastState.showToast = true
                                }
                            case let .failure(error):
                                toastState.title = "Error"
                                toastState.message = error.localizedDescription
                                toastState.showToast = true
                            }
                            isAddingFeed = false
                        }
                    }

                if isAddingFeed {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(.trailing, 8)
                        .tint(.accentColor)
                }
            }
            .padding(.bottom, 8)

            Spacer()

            ScrollView {
                if feeds.count > 0 {
                    ForEach(feeds) { feed in
                        FeedCard(feed: feed)
                    }
                } else {
                    VStack {
                        Image(systemName: "newspaper")
                            .font(.system(size: 35))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 6)

                        Text("No feeds added yet.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 36)
                    .padding(.horizontal, 16)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                if hasLoadedRecommendedFeeds {
                    VStack {
                        Text("Suggested")
                            .font(.title2)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(recommendedFeeds) { feed in
                            FeedCard(feed: feed)
                        }
                    }
                    .padding(.top, 16)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .padding()
        .safeAreaInset(edge: .bottom) {
            VStack {
                NavigationLink(destination: ForYouView()) {
                    Text("Save")
                }
                .disabled(feeds.isEmpty)
                .buttonStyle(.fullWidth)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        Task {
                            saveFeeds()
                        }
                    }
                )

                Text("You can always add or remove feeds later.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .toast(isPresenting: $toastState.showToast) {
            AlertToast(type: .error(.red), title: toastState.title, subTitle: toastState.message)
        }
        .task {
            #if DEBUG
            #else
                if !hasLoadedRecommendedFeeds {
                    await loadRecommendedFeeds()
                }
            #endif
        }
    }

    @ViewBuilder
    func FeedCard(feed: ParsedFeed) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack {
                FeedImage(imageURL: feed.imageURL)

                if feed.description != nil {
                    Spacer()
                }
            }

            VStack {
                Text(feed.title)
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let description = feed.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer()

            if feeds.contains(where: { $0.url == feed.url }) {
                Button(action: {
                    withAnimation {
                        feeds.removeAll { $0.url == feed.url }
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundStyle(.accent)
                        .font(.title2)
                        .padding(.trailing, 8)
                }
            } else {
                Button(action: {
                    withAnimation {
                        feeds.append(feed)
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.accent)
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }

    private func saveFeeds() {
        withErrorReporting {
            try database.write { db in
                // Upsert feeds into the database
                for feed in feeds {
                    try db.execute(
                        sql: """
                        INSERT INTO feeds (title, url, description, icon, addedAt) VALUES (?, ?, ?, ?, ?)
                        ON CONFLICT(url) DO UPDATE SET
                            title = excluded.title,
                            description = excluded.description,
                            icon = excluded.icon
                        """,
                        arguments: [
                            feed.title, feed.url, feed.description ?? "", feed.imageURL ?? "",
                            Date(),
                        ]
                    )
                }
            }

            Task { await feedManager.refreshAll() }

            UserDefaults().setValue(true, forKey: AppStorageKey.hasCompletedOnboarding.rawValue)
        }
    }

    private func loadRecommendedFeeds() async {
        for feedURL in defaultFeeds {
            let feed = await loadFeed(url: feedURL)
            switch feed {
            case let .success(parsedFeed):
                if let parsedFeed = parsedFeed {
                    recommendedFeeds.append(parsedFeed)
                }

            case let .failure(error):
                Log.withScope("SetupFeedsView").error("Failed to load feed: \(error)")
                continue
            }
        }

        hasLoadedRecommendedFeeds = true
    }
}

#Preview {
    SetupFeedsView()
}
