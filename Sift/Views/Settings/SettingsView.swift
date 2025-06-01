//
//  SettingsView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//
import Dependencies
import Foundation
import SwiftUI

struct SettingsView: View {
    @Dependency(\.defaultDatabase) private var database

    @AppStorage(AppStorageKey.colorScheme.rawValue) private var preferredColorScheme: String =
        PreferredColorScheme.system.rawValue

    @State private var showResetConfirmation = false

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
                        Label("Topics", systemImage: "star")
                    }

                    NavigationLink(destination: FollowedFeedsView()) {
                        Label("Feeds", systemImage: "newspaper")
                    }
                } header: {
                    Text("Personalization")
                }

                Section {
                    Button(action: {
                        showResetConfirmation = true
                    }) {
                        Label("Reset application", systemImage: "arrow.clockwise")
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Debug")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Are you sure you want to reset the application?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    // Reset the onboarding state
                    UserDefaults.standard.set(
                        false,
                        forKey: AppStorageKey.hasCompletedOnboarding.rawValue
                    )

                    resetDatabase()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func resetDatabase() {
        // Truncate the tables
        withErrorReporting {
            do {
                try database.write { db in
                    try db.execute(sql: "DELETE FROM articles")
                    try db.execute(sql: "DELETE FROM feeds")
                    try db.execute(sql: "DELETE FROM preferred_topics")
                }
            } catch {
                Log.shared.error("Failed to reset database: \(error.localizedDescription)")
            }
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
