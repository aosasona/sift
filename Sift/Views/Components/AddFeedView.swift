//
//  AddFeedView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//

import Dependencies
import SwiftUI

struct AddFeedView: View {
    @Dependency(\.defaultDatabase) private var database
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var feedManager: FeedManager

    @State private var feedURL: String = ""
    @State private var isAddingFeed: Bool = false
    @StateObject private var toastState = ToastState()
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("Enter feed URL", text: $feedURL)
                            .keyboardType(.URL)
                            .textContentType(.URL)
                            .focused($isFieldFocused)
                            .onSubmit {
                                guard !feedURL.isEmpty else { return }

                                isAddingFeed = true
                                Task {
                                    let result = await loadFeed(url: feedURL)
                                    switch result {
                                    case .success(let parsedFeed):
                                        if let parsedFeed = parsedFeed {
                                            feedURL = ""
                                            await addFeed(parsedFeed)
                                        } else {
                                            toastState.title = "Invalid Feed"
                                            toastState.message =
                                                "The feed URL you entered is invalid."
                                            toastState.showToast = true
                                        }
                                    case .failure(let error):
                                        toastState.title = "Error"
                                        toastState.message = error.localizedDescription
                                        toastState.showToast = true
                                    }

                                    isAddingFeed = false
                                    await feedManager.refreshAll()
                                    dismiss()
                                }
                            }

                        if isAddingFeed {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(.leading, 8)
                        }
                    }
                }
            }
            .task {
                await MainActor.run {
                    isFieldFocused = true
                }
            }
            .navigationTitle("Add Feed")
        }
    }

    private func addFeed(_ feed: ParsedFeed) async {
        await withErrorReporting {
            do {
                try await database.write { db in
                    let record = Feed(
                        title: feed.title,
                        url: feed.url,
                        description: feed.description ?? "",
                        imageURL: feed.imageURL ?? "",
                        addedAt: Date(),
                    )
                    try Feed.insert(record).execute(db)
                }
            } catch {
                Log.shared.error("Failed to add feed: \(error.localizedDescription)")
                toastState.title = "Error"
                toastState.message = "Failed to add feed. Please try again."
                toastState.showToast = true
            }
        }
    }
}

#Preview {
    AddFeedView()
}
