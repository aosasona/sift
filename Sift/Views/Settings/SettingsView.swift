//
//  SettingsView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//
import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage(AppStorageKey.colorScheme.rawValue) private var preferredColorScheme: String =
        PreferredColorScheme.system.rawValue

    var body: some View {
        NavigationStack {
            List {
                // MARK: Colorscheme

                Section {
                    Picker("Color scheme", selection: $preferredColorScheme) {
                        ForEach(PreferredColorScheme.allCases) { colorScheme in
                            Text(colorScheme.rawValue.capitalized)
                                .tag(colorScheme.rawValue)
                        }
                    }
                } header: {
                    Text("General")
                }

                Section {
                    NavigationLink(destination: PreferredTopicsView()) {
                        Label("Preferred Topics", systemImage: "star")
                    }

                    NavigationLink(destination: FollowedFeedsView()) {
                        Label("Followed Feeds", systemImage: "newspaper")
                    }
                } header: {
                    Text("Personalization")
                }

                Section {
                    Button(action: {
                        // Reset the onboarding state
                        UserDefaults.standard.set(
                            false,
                            forKey: AppStorageKey.hasCompletedOnboarding.rawValue
                        )
                    }) {
                        Label("Reset onboarding state", systemImage: "arrow.clockwise")
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Debug")
                }
            }
            .navigationTitle("Settings")
        }
    }

    // Present the user with the raw file and allow them save it to their device
    private func downloadSqliteDatabase() {
        let path = URL.documentsDirectory.appending(component: "db.sqlite")
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path.path) else {
            Log.shared.error("Database file does not exist at path: \(path.path)")
            return
        }

        let activityVC = UIActivityViewController(activityItems: [path], applicationActivities: nil)

        // Present from the root window
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootVC = scene.windows.first?.rootViewController
        {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

#Preview {
    SettingsView()
}
