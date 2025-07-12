import SwiftUI

@main
struct SparksApp: App {
    // Initialize the persistence controller for CoreData
    let persistenceController = PersistenceController.shared
    
    // Initialize app state
    @StateObject private var appState = AppState.shared
    
    // Initialize shared ViewModels
    @StateObject private var inspirationViewModel: InspirationViewModel
    @StateObject private var taskViewModel: TaskViewModel
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _inspirationViewModel = StateObject(wrappedValue: InspirationViewModel(context: context))
        _taskViewModel = StateObject(wrappedValue: TaskViewModel(context: context))
    }
    
    var body: some Scene {
        WindowGroup {
            AppContentView()
                .environmentObject(appState)
                .environmentObject(inspirationViewModel)
                .environmentObject(taskViewModel)
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
    @EnvironmentObject var inspirationViewModel: InspirationViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            InspirationListView()
                .tabItem {
                    Label("Collection", systemImage: "lightbulb")
                }
                .tag(0)
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.circle")
                }
                .tag(1)
            AddInspirationView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                }
                .tag(2)
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
                .tag(3)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
    }
}
