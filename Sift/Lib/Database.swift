//
//  Database.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//
import Foundation
import GRDB

public final class AppDatabase: Sendable {
    private let db: any DatabaseWriter

    public init(db: any DatabaseWriter) throws {
        self.db = db
        try migrator.migrate(db)
    }
}

extension AppDatabase {
    public var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("version_1") { db in
            try db.create(table: "preferred_categories") { t in
                t.column("id", .integer).primaryKey()
                t.column("category", .text).notNull()
                t.column("created_at", .datetime).notNull()
            }
        }

        return migrator
    }
}
