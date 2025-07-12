import SwiftUI

@main
struct SparksApp: App {
    // Initialize the persistence controller for CoreData
    let persistenceController = PersistenceController.shared
    
    // Initialize app state
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            AppContentView()
                .environmentObject(appState)
        }
    }
}

struct AppContentView: View {
    @State private var showingLaunchScreen = true
    
    var body: some View {
        ZStack {
            if showingLaunchScreen {
                LaunchScreenView()
                    .transition(.opacity)
                    .onAppear {
                        // 3秒後自動切換到主畫面
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showingLaunchScreen = false
                            }
                        }
                    }
            } else {
                MainTabView()
            }
        }
    }
}

struct MainTabView: View {
    let persistenceController = PersistenceController.shared
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        TabView {
            InspirationListView(context: persistenceController.container.viewContext)
                .tabItem {
                    Label("Collection", systemImage: "lightbulb")
                }
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.circle")
                }
            AddInspirationView()
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
