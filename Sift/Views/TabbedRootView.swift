//
//  TabbedRootView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//

import SwiftUI

enum Tabs: String, Identifiable, CaseIterable, Equatable, Hashable {
    case forYou = "For You"
    case articles = "Articles"
    case search = "Search"

    var id: String { self.rawValue }

    var iconName: String {
        switch self {
        case .forYou: return "star.fill"
        case .articles: return "newspaper.fill"
        case .search: return "magnifyingglass"
        }
    }

    @ViewBuilder
    var associatedView: some View {
        switch self {
        case .forYou: ForYouView()
        case .articles: ArticlesListView()
        case .search: SearchView()
        }
    }
}

struct TabbedRootView: View {
    @State private var selectedTab: Tabs = .forYou
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(Tabs.forYou.rawValue, systemImage: Tabs.forYou.iconName, value: .forYou) {
                Tabs.forYou.associatedView
            }
            
            Tab(Tabs.articles.rawValue, systemImage: Tabs.articles.iconName, value: .articles) {
                Tabs.articles.associatedView
            }
            
            Tab(Tabs.search.rawValue, systemImage: Tabs.search.iconName, value: .search) {
                Tabs.search.associatedView
            }
        }
    }
}

#Preview {
    TabbedRootView()
}
