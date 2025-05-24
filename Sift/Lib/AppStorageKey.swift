//
//  AppStorageKey.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//
import SwiftUI

enum AppStorageKey: String {
    case hasCompletedOnboarding
    case colorScheme
}

enum PreferredColorScheme: String, Identifiable, CaseIterable {
    var id: Self { return self }

    case system
    case light
    case dark

    static func fromString(_ string: String) -> PreferredColorScheme {
        guard let theme = PreferredColorScheme(rawValue: string) else {
            return .system
        }
        return theme
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
