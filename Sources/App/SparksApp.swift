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
                ContentView(context: persistenceController.container.viewContext)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                InspirationListView(context: persistenceController.container.viewContext)
                    .tabItem {
                        Label("Inspiration", systemImage: "lightbulb")
                    }
            }
            .environmentObject(appState)
        }
    }
}
