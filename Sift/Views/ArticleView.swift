//
//  ArticleView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//

import MarkdownUI
import SharingGRDB
import SwiftUI
import WebKit

enum ViewMode: Hashable {
    case reader
    case web
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct ArticleView: View {
    @State private var viewMode: ViewMode = .reader

    let article: Article

    var body: some View {
        VStack {
            if viewMode == .reader {
                // Display the article content in reader mode
                if let md = article.markdownContent {
                    ScrollView {
                        if let imageURL = article.imageURL, !imageURL.isEmpty {
                            if let thumbnail = URL(string: imageURL) {
                                AsyncImage(url: thumbnail) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 200)
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                        .frame(height: 200)
                                }
                            }
                        }

                        Markdown(md)
                            .padding()
                    }
                } else {
                    Text("No content available for this article")
                        .padding()
                }
            } else {
                if let url = URL(string: article.url) {
                    WebView(url: url)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Text("Unable to load article")
                        .padding()
                }
            }
        }
        .navigationTitle(article.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("View Mode", selection: $viewMode) {
                        Text("Reader").tag(ViewMode.reader)
                        Text("Web").tag(ViewMode.web)
                    }
                    .pickerStyle(.menu)
                    

                    // Share the article URL
                    Button(action: {
                        if let url = URL(string: article.url) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Open in Browser", systemImage: "arrow.up.right.square")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

#Preview {
    ArticleView(
        article: Article(
            title: "Sample Article",
            url: "https://example.com/sample-article",
            label: "Sample Label",
            feedID: Feed.ID(1),
        )
    )
}
