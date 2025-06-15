//
//  TimeManagementApp.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//

import SwiftUI

@main
struct TimeManagementApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
