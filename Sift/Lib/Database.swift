import Dependencies
//
//  Database.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//
import Foundation
import SharingGRDB

public final class AppDatabase: Sendable {
    private let db: any DatabaseWriter

    public init() throws {
        @Dependency(\.context) var context

        let db: any DatabaseWriter

        var config = Configuration()
        config.foreignKeysEnabled = true
        config.prepareDatabase { db in
            #if DEBUG
                db.trace(options: .profile) {
                    if context == .live {
                        Log.shared.debug("\($0.expandedDescription)")
                    } else {
                        print("\($0.expandedDescription)")
                    }
                }
            #endif
        }

        if context == .live {
            let path = URL.documentsDirectory.appending(component: "db.sqlite").path()
            Log.shared.info("open \(path)")
            db = try DatabasePool(path: path, configuration: config)
        } else {
            db = try DatabaseQueue(configuration: config)
        }

        self.db = db
        try migrator.migrate(db)

        // Load label map
        try importLabelSets(db)
    }

    public func getDatabase() -> any DatabaseWriter {
        return db
    }
}

extension AppDatabase {
    public var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
            migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("create tables") { db in
            // Preferred Categories
            try db.create(table: "preferred_categories") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("category", .text).notNull()
                t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            }

            // Feeds
            try db.create(table: "feeds") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).notNull()
                t.column("url", .text).notNull().unique(onConflict: .ignore)
                t.column("description", .text).defaults(to: "")
                t.column("icon", .text).defaults(to: "")
                t.column("addedAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
                t.column("lastSyncedAt", .datetime)
            }

            // Articles
            try db.create(table: "articles") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).notNull()
                t.column("url", .text).notNull().unique(onConflict: .ignore)
                t.column("description", .text).notNull().defaults(to: "")
                t.column("htmlContent", .text).notNull().defaults(to: "")
                t.column("textContent", .text).notNull().defaults(to: "")
                t.column("summary", .text).notNull().defaults(to: "")
                t.column("publishedAt", .datetime).notNull()
                t.column("feedId", .integer).notNull().references(
                    "feeds",
                    column: "id",
                    onDelete: .cascade
                )
                t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            }

            // LabelSets
            try db.create(table: "label_sets") { t in
                t.column("version", .integer).primaryKey().unique().notNull().defaults(to: 1)  // Version of the label set
                t.column("labelsJson", .text).notNull().unique(onConflict: .ignore)  // JSON representation of the labels
                t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            }

            // Labels
            try db.create(table: "labels") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("set", .integer).notNull().references(
                    "label_sets",
                    column: "version",
                    onDelete: .cascade
                )
                t.column("name", .text).notNull()  // Label name (category)
                t.column("index", .integer).notNull().defaults(to: 0)  // The index of the label in the list (this is what will be outputted by the text classifier model)
                t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")

                t.uniqueKey(["set", "name"])
            }

            // Predictions
            try db.create(table: "predictions") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("articleId", .integer).notNull().references(
                    "articles",
                    column: "id",
                    onDelete: .cascade
                )
                t.column("labelId", .integer).notNull().references(
                    "labels",
                    column: "id",
                    onDelete: .cascade
                )
                t.column("confidence", .real).notNull().defaults(to: 0.0)
                t.column("createdAt", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")

                t.uniqueKey(["articleId", "labelId"])
            }
        }

        return migrator
    }
}
