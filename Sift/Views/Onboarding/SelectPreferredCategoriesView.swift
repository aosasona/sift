//
//  SelectPreferredCategoriesView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//

import Dependencies
import Flow
import SharingGRDB
import SwiftUI

let MaxPreferredCategories = 10

struct SelectPreferredCategoriesView: View {
    @Dependency(\.defaultDatabase) private var database

    @State private var selectedCategories: Set<String> = []

    @FetchAll var categories: [Sift.Category]

    var indicatorColor: Color {
        switch selectedCategories.count {
        case 0..<3:
            return .red
        case 3..<6:
            return .orange
        case 6..<MaxPreferredCategories:
            return .yellow
        default:
            return .green
        }
    }

    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Spacer()

                Circle()
                    .fill(indicatorColor)
                    .frame(width: 10, height: 10)
                    .padding(.leading, 4)

                Text("\(selectedCategories.count) out of \(MaxPreferredCategories)")
                    .foregroundStyle(.secondary)
            }

            Text("Select at least 3 topics you are interested in")
                .font(.title)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                HFlow(spacing: 10) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            if selectedCategories.contains(category.name) {
                                selectedCategories.remove(category.name)
                            } else {
                                if selectedCategories.count < MaxPreferredCategories {
                                    selectedCategories.insert(category.name)
                                }
                            }
                        }) {
                            Text(category.name.capitalized)
                                .font(.title3)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedCategories.contains(category.name)
                                        ? .accentColor : Color.gray.opacity(0.2)
                                )
                                .foregroundColor(
                                    selectedCategories.contains(category.name)
                                        ? .white : .secondary
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .animation(
                            .easeInOut(duration: 0.075),
                            value: selectedCategories.contains(category.name)
                        )
                        .accessibilityIdentifier("category-\(category.name)")
                        .accessibilityAddTraits(selectedCategories.contains(category.name) ? .isSelected : [])
                    }
                }
            }

        }
        .navigationBarBackButtonHidden()
        .frame(alignment: .leading)
        .padding()
        .safeAreaInset(edge: .bottom) {
            VStack {
                NavigationLink(destination: SetupFeedsView()) {
                    Text("Continue")
                }
                .disabled(selectedCategories.count < 3)
                .buttonStyle(.fullWidth)
                .simultaneousGesture(TapGesture().onEnded {
                    Task {
                        saveCategories()
                    }
                })
                
                Text("You can change your preferences later in settings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .padding(.horizontal)
        }
    }
    
    private func saveCategories() {
        withErrorReporting {
            try database.write { db in
                // Clear existing preferred categories
                try PreferredTopic.delete().execute(db)
                
                // Insert selected categories
                for category in selectedCategories {
                    let preferredCategory = PreferredTopic(name: category)
                    try PreferredTopic.insert(preferredCategory).execute(db)
                }
                
                Log.shared.info("Saved \(selectedCategories.count) preferred categories")
            }
        }
    }
}

#Preview {
    let _ = try! prepareDependencies {
        $0.defaultDatabase = try AppDatabase.init().getDatabase()
    }

    SelectPreferredCategoriesView()
}
