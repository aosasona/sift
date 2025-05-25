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
    case settings = "Settings"

    var id: String { self.rawValue }

    var iconName: String {
        switch self {
        case .forYou: return "star.fill"
        case .articles: return "newspaper.fill"
        case .settings: return "gear"
        }
    }

    @ViewBuilder
    var associatedView: some View {
        switch self {
        case .forYou: ForYouView()
        case .articles: ArticlesListView()
        case .settings: SettingsView()
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

            Tab(Tabs.settings.rawValue, systemImage: Tabs.settings.iconName, value: .settings) {
                Tabs.settings.associatedView
            }
        }
    }
}

#Preview {
    TabbedRootView()
}
