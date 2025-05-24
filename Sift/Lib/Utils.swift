//
//  Utils.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//
import Foundation
import SharingGRDB

func loadJson<T: Decodable>(from filename: String) -> T? {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
        Log.shared.error("File \(filename).json not found")
        return nil
    }

    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        Log.shared.error("Error loading JSON from \(filename): \(error.localizedDescription)")
        return nil
    }
}

func importLabelSets(_ databaseWriter: any DatabaseWriter) throws {
    guard let labels: [String] = loadJson(from: "label_map") else {
        Log.shared.error("Failed to load label map from JSON")
        throw NSError(
            domain: "AppDatabaseError",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Failed to load label map from JSON"]
        )
    }

    let labelsJson = try JSONEncoder().encode(labels)

    try databaseWriter.write { db in
        let versions =
            try LabelSet
            .order(by: \.id)
            .fetchAll(db)

        let latestVersion = versions.last

        if let latestVersion {
            if latestVersion.labelsJson == String(data: labelsJson, encoding: .utf8) {
                Log.shared.info("Label set is already up-to-date")
                return
            }
        }

        // Insert the set
        let newVersion = latestVersion?.id ?? 0 + 1
        let labelSet = LabelSet(
            id: newVersion,
            labelsJson: String(data: labelsJson, encoding: .utf8) ?? ""
        )
        try LabelSet.insert(labelSet).execute(db)

        Log.shared.info("Inserted new label set version: \(newVersion)")

        // Insert the labels
        for i in 0..<labels.count {
            let label = Label(labelSetVersion: labelSet.id, name: labels[i], index: i)
            try Label.insert(label).execute(db)
        }
    }
}
