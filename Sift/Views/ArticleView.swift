//
//  ArticleView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//

import SharingGRDB
import SwiftUI
import WebKit

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
    let article: Article
    
    var body: some View {
        if let url = URL(string: article.url) {
            WebView(url: url)
                .navigationTitle(article.title)
        } else {
            Text("Unable to load article")
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
