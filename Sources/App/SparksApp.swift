import SwiftUI

@main
struct SparksApp: App {
    // Initialize the persistence controller for CoreData
    let persistenceController = PersistenceController.shared
    
    // Initialize app state
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
        }
    }
}
