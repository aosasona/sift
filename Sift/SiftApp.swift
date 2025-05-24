//
//  SiftApp.swift
//  Sift
//
//  Created by Ayodeji Osasona on 23/05/2025.
//

import SwiftUI
import SharingGRDB

@main
struct SiftApp: App {
    init() {
        try! prepareDependencies {
            $0.defaultDatabase = try AppDatabase.init().getDatabase()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
