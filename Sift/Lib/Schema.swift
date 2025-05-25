//
//  Schame.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//

import Foundation
import SharingGRDB

@Table("preferred_categories")
struct PreferredTopic: Hashable, Identifiable {
    var id: Int?
    @Column("category")
    var name: String

    @Column(as: Date.ISO8601Representation?.self)
    var createdAt: Date? = Date()
}

@Table("feeds")
struct Feed: Hashable, Identifiable  {
    var id: Int?
    var title: String
    var url: String
    var description: String?
    
    @Column("icon")
    var imageURL: String? = ""
    
    @Column(as: Date.ISO8601Representation?.self)
    var addedAt: Date? = Date()
    
    @Column(as: Date.ISO8601Representation?.self)
    var lastSyncedAt: Date?
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
    
    @Column(as: Date.ISO8601Representation?.self)
    var createdAt: Date? = Date()
    
    @Column("feedId")
    var feedID: Feed.ID
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
