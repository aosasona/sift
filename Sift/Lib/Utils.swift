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

func importLabelSets(db: any DatabaseWriter) throws {
    guard let labels: [String] = loadJson(from: "label_map") else {
        Log.shared.error("Failed to load label map from JSON")
        throw NSError(
            domain: "AppDatabaseError",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Failed to load label map from JSON"]
        )
    }
}
