//
//  SetupFeedsView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//
import AlertToast
import FeedKit
import SwiftUI

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

struct ParsedFeed: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let description: String?
    let imageURL: String?
}

class ToastState: ObservableObject {
    @Published var showToast = false
    @Published var title: String = ""
    @Published var message: String = ""
}

struct SetupFeedsView: View {
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
            Text("Setup Feeds")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)

            Text("Add your favorite publications to get started. You can always add more later.")
                .font(.subheadline)
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
                // TODO: show added feeds here

                Divider()

                if hasLoadedRecommendedFeeds {
                    Text("Suggested")
                        .font(.title2)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(recommendedFeeds) { feed in
                        HStack(alignment: .center, spacing: 10) {

                            if let imageURL = feed.imageURL, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: ImageSize, height: ImageSize)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                } placeholder: {
                                    ImagePlaceholder()
                                }
                            } else {
                                // Newspaper in gray box
                                ImagePlaceholder()
                            }

                            VStack {
                                Text(feed.title)
                                    .font(.headline)
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
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.accent)
                                    .font(.title2)
                                    .padding(.trailing, 8)
                            } else {
                                Button(action: {}) {
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
                }
            }
        }
        .toast(isPresenting: $toastState.showToast) {
            AlertToast(type: .error(.red), title: toastState.title, subTitle: toastState.message, )
        }
        .padding()
        .navigationBarBackButtonHidden()
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
    func ImagePlaceholder() -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.gray.opacity(0.5))
            .frame(width: ImageSize, height: ImageSize)
            .overlay(
                Image(systemName: "newspaper")
                    .foregroundStyle(.white)
                    .font(.system(size: 13))
            )
    }

    private func loadRecommendedFeeds() async {
        for feedURL in defaultFeeds {
            let feed = await loadFeed(url: feedURL)
            switch feed {
            case .success(let parsedFeed):
                if let parsedFeed = parsedFeed {
                    recommendedFeeds.append(parsedFeed)
                }

            case .failure(let error):
                Log.withScope("SetupFeedsView").error("Failed to load feed: \(error)")
                continue
            }
        }

        hasLoadedRecommendedFeeds = true
    }

    private func loadFeed(url: String) async -> Result<ParsedFeed?, FeedError> {
        do {
            guard let parsedURL = URL(string: url) else {
                print("Invalid URL: \(url)")
                return .failure(.rawError("Invalid URL: \(url)"))
            }

            let host = parsedURL.host ?? parsedURL.absoluteString

            let parsedFeed = try await FeedKit.Feed(urlString: url)
            switch parsedFeed {
            case .rss(let feed):
                return .success(
                    ParsedFeed(
                        title: feed.channel?.title ?? host,
                        url: url,
                        description: feed.channel?.description ?? host,
                        imageURL: feed.channel?.image?.url
                    )
                )
            case .json(let feed):
                return .success(
                    ParsedFeed(
                        title: feed.title ?? host,
                        url: url,
                        description: feed.description == nil ? host : feed.description,
                        imageURL: feed.icon
                    )
                )
            case .atom(let feed):
                return .success(
                    ParsedFeed(
                        title: feed.title?.text ?? host,
                        url: url,
                        description: feed.subtitle?.text ?? host,
                        imageURL: feed.icon
                    )
                )
            }
        } catch {
            print("Failed to load feed from \(url): \(error)")
            return .failure(
                .rawError("Failed to load feed from \(url): \(error.localizedDescription)")
            )
        }
    }
}

#Preview {
    SetupFeedsView()
}
