//
//  TimeManagementApp.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//

import SwiftUI
import SwiftData

@main
struct TimeManagementApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ActivityLog.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TimelineView()
        }
        .modelContainer(sharedModelContainer)
    }
}
