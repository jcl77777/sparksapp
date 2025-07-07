import SwiftUI

@main
struct SparksApp: App {
    // Initialize the persistence controller for CoreData
    let persistenceController = PersistenceController.shared
    
    // Initialize app state
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            TabView {
                InspirationListView(context: persistenceController.container.viewContext)
                    .tabItem {
                        Label("Collection", systemImage: "lightbulb")
                    }
                TaskListView()
                    .tabItem {
                        Label("Tasks", systemImage: "checkmark.circle")
                    }
                ContentView(context: persistenceController.container.viewContext)
                    .tabItem {
                        Label("Add", systemImage: "plus.circle")
                    }
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.bar")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .environmentObject(appState)
        }
    }
}
