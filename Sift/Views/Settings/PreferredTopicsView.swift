//
//  PreferredTopicsView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//

import SharingGRDB
import SwiftUI

struct PreferredTopicsView: View {
    @Dependency(\.defaultDatabase) private var database

    @FetchOne(
        #sql(
            """
            SELECT MAX(\(LabelSet.id)) FROM \(LabelSet.self)
            """
        )
    ) var latestSet: Int = 0
    @FetchAll var preferredTopics: [PreferredTopic]
    @FetchAll(
        #sql(
            """
            SELECT l.* FROM \(Category.self) l
            LEFT JOIN label_sets ls ON ls."version" = l."set"
            WHERE ls.version = (SELECT MAX(version) FROM label_sets)
            """
        )
    ) var allLabels: [Category]

    var body: some View {
        List {
            Section("Preferred Topics") {
                ForEach(allLabels, id: \.self) { label in
                    Toggle(
                        label.name.capitalized,
                        isOn: Binding(
                            get: { preferredTopics.contains(where: { $0.name == label.name }) },
                            set: { togglePreferredTopic(for: label, isOn: $0) }
                        )
                    )
                }
            }
        }
    }

    private func togglePreferredTopic(for label: Category, isOn: Bool) {
        withErrorReporting {
            do {
                try database.write { db in
                    if isOn {
                        let record = PreferredTopic(name: label.name)
                        try PreferredTopic.insert(record).execute(db)
                        return
                    }
                    
                    // Remove the topic if it is already preferred
                    if let topic = preferredTopics.first(where: { $0.name == label.name }) {
                        try PreferredTopic.delete(topic).execute(db)
                    }
                }
            } catch {
                Log.shared.error("Failed to toggle preferred topic: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    PreferredTopicsView()
}
