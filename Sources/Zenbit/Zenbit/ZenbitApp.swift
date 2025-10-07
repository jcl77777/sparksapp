//
//  ZenbitApp.swift
//  Zenbit
//
//  Created by JC Lee on 2025/7/31.
//

import SwiftUI

@main
struct ZenbitApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
