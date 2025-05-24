//
//  Schame.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//

import Foundation
import SharingGRDB

@Table("preferred_categories")
struct PreferredCategory: Hashable, Identifiable {
    var id: Int?
    var category: String

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
    var imageURL: String?
    
    @Column(as: Date.ISO8601Representation?.self)
    var addedAt: Date? = Date()
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
    
    @Column(as: Date.ISO8601Representation.self)
    var publishedAt: Date
    
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
struct Label: Hashable, Identifiable {
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
    var label: Label.ID
    var confidence: Double
    
    @Column(as: Date.ISO8601Representation?.self)
    var createdAt: Date? = Date()
}
