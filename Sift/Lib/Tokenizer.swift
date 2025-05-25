//
//  Tokenizer.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//
import Foundation

typealias Vocab = [String: Int]

struct Tokenizer {
    let vocab: Vocab
    let maxLength: Int
    let padToken: String
    let unkToken: String
    let padIndex: Int
    let unkIndex: Int

    init() {
        guard let url = Bundle.main.url(forResource: "tokenizer", withExtension: "json") else {
            Log.shared.error("Tokenizer file not found at tokenizer.json")
            fatalError("Tokenizer file not found")
        }

        do {
            let data = try Data(contentsOf: url)
            let raw = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            let rawVocab = raw?["vocab"] as? [String: Int] ?? [:]
            self.vocab = rawVocab
            self.maxLength = raw?["max_length"] as? Int ?? 40

            self.padToken = raw?["pad_token"] as? String ?? "[PAD]"
            self.unkToken = raw?["unk_token"] as? String ?? "[UNK]"

            self.padIndex = rawVocab[self.padToken] ?? 0
            self.unkIndex = rawVocab[self.unkToken] ?? 1
        } catch {
            Log.shared.error(
                "Error loading JSON from tokenizer.json: \(error.localizedDescription)"
            )
            fatalError("Error loading tokenizer file")
        }
    }

    public func tokenize(_ text: String) -> [Int32] {
        let normalizedText = text.lowercased()
            .replacingOccurrences(of: "[^\\w\\s]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let tokens = normalizedText.split(separator: " ").map { String($0) }
        let ids = tokens.map { vocab[$0] ?? unkIndex }  // Map each token to its ID, defaulting to unkIndex if not found (unk for unknown)

        let padded = Array(
            ids.prefix(maxLength) + Array(repeating: padIndex, count: max(0, maxLength - ids.count))
        )
        return padded.map { Int32($0) }  // Convert to Int32
    }
}
