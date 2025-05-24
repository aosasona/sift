//
//  Router.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//
import Foundation
import SwiftUI

@MainActor
class Router: ObservableObject {
    static let shared = Router()
    
    @Published var path = NavigationPath()
    
    enum Page: Identifiable, Hashable, Codable {
        case welcome
        case selectPreferedCategories
        
        var id: String {
            switch self {
                case .welcome: "welcome"
                case .selectPreferedCategories: "selectPreferedCategories"
            }
        }
    }
    
    @ViewBuilder
    func pageView(for page: Page) -> some View {
        switch page {
            case .welcome: WelcomeView()
            case .selectPreferedCategories: SelectPreferedCategoriesView()
        }
    }
}
