//
//  Schema.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//

import CryptoKit
import Foundation
import SharingGRDB
import SwiftUI

@Table("preferred_categories")
struct PreferredTopic: Hashable, Identifiable {
    var id: Int?
    @Column("category")
    var name: String

    @Column(as: Date.ISO8601Representation?.self)
    var createdAt: Date? = Date()
}

@Table("feeds")
struct Feed: Hashable, Identifiable {
    var id: Int?
    var title: String
    var url: String
    var description: String?

    @Column("icon")
    var imageURL: String? = ""

    @Column(as: Date.ISO8601Representation?.self)
    var addedAt: Date? = Date()

    @Column(as: Date.ISO8601Representation?.self)
    var lastSyncedAt: Date? = Date()
}

@Table("articles")
struct Article: Hashable, Identifiable {
    var id: Int?
    var title: String
    var url: String
    var description: String?

    var htmlContent: String?
    var textContent: String?
    var summary: String?
    var label: String

    @Column("feedId")
    var feedID: Feed.ID

    @Column("createdAt", as: Date.ISO8601Representation?.self)
    var createdAt: Date? = Date()

    @Column("publishedAt", as: Date.ISO8601Representation?.self)
    var publishedAt: Date?
    
    @Column("markdownContent")
    var markdownContent: String?
    
    @Column("imageURL")
    var imageURL: String? = nil
    
    @Column("author")
    var author: String? = nil
    @Column("faviconURL")
    var faviconURL: String? = nil
    
    @Column("siteName")
    var siteName: String? = nil
    
    @Column("isBookmarked")
    var isBookmarked: Bool = false
    
    @Column("isRead")
    var isRead: Bool = false
}

@Table("label_sets")
struct LabelSet: Hashable, Identifiable {
    @Column("version")
    var id: Int

    var labelsJson: String

    @Column(as: Date.ISO8601Representation?.self)
    var createdAt: Date? = Date()
}

@Table("labels")
struct Category: Hashable, Identifiable {
    var id: Int?

    @Column("set")
    var labelSetVersion: LabelSet.ID
    var name: String
    var index: Int

    @Column(as: Date.ISO8601Representation?.self)
    var createdAt: Date? = Date()
}

@Table("predictions")
struct Prediction: Hashable, Identifiable {
    var id: Int?
    var articleId: Article.ID
    var label: String
    var confidence: Double

    @Column(as: Date.ISO8601Representation?.self)
    var createdAt: Date? = Date()
}

extension Article {
    var labelColor: Color {
        // Generate a hash of the label
        let hash = Insecure.MD5.hash(data: Data(label.utf8))
        let bytes = Array(hash) // To array

        // Use the first three bytes to make RGB
        let r = Double(bytes[0]) / 255.0
        let g = Double(bytes[1]) / 255.0
        let b = Double(bytes[2]) / 255.0

        return Color(red: r * 0.7 + 0.25, green: g * 0.7 + 0.25, blue: b * 0.7 + 0.25)
    }
}
