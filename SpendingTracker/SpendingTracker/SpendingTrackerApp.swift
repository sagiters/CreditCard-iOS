//
//  SpendingTrackerApp.swift
//  SpendingTracker
//
//  Created by Lien-Tai Kuo on 2021/8/28.
//

import SwiftUI

@main
struct SpendingTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
