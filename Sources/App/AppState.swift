import SwiftUI

class AppState: ObservableObject {
    // Global app state properties will go here
    
    // Navigation state
    @Published var selectedTab: Int = 0
    
    // Singleton instance for easy access throughout the app
    static let shared = AppState()
    
    private init() {
        // Private initializer to enforce singleton pattern
    }
}
