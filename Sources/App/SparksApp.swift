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
    @StateObject private var dashboardViewModel: DashboardViewModel
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _inspirationViewModel = StateObject(wrappedValue: InspirationViewModel(context: context))
        _taskViewModel = StateObject(wrappedValue: TaskViewModel(context: context))
        _dashboardViewModel = StateObject(wrappedValue: DashboardViewModel(context: context))
    }
    
    var body: some Scene {
        WindowGroup {
            AppContentView()
                .environmentObject(appState)
                .environmentObject(inspirationViewModel)
                .environmentObject(taskViewModel)
                .environmentObject(dashboardViewModel)
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
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            InspirationListView()
                .tabItem {
                    Image(systemName: "lightbulb")
                    Text("Collection")
                }
                .tag(0)
            TaskListView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Tasks")
                }
                .tag(1)
            AddInspirationView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Add")
                }
                .tag(2)
            DashboardView()
                .environmentObject(dashboardViewModel)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Dashboard")
                }
                .tag(3)
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
        }
    }
}
