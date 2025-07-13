import SwiftUI
import UserNotifications

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 僅處理 unorganized-reminder
        if response.notification.request.identifier == "unorganized-reminder" {
            DispatchQueue.main.async {
                let appState = AppState.shared
                appState.selectedTab = 0 // 收藏分頁
                appState.shouldShowUnorganizedOnAppear = true
            }
        }
        completionHandler()
    }
}

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
    
    // Initialize notification manager
    @StateObject private var notificationManager = NotificationManager.shared
    
    // 新增通知處理器
    private let notificationHandler = NotificationHandler()
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _inspirationViewModel = StateObject(wrappedValue: InspirationViewModel(context: context))
        _taskViewModel = StateObject(wrappedValue: TaskViewModel(context: context))
        _dashboardViewModel = StateObject(wrappedValue: DashboardViewModel(context: context))
        _notificationManager = StateObject(wrappedValue: NotificationManager.shared)
        // 註冊 UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = notificationHandler
    }
    
    var body: some Scene {
        WindowGroup {
            AppContentView()
                .environmentObject(appState)
                .environmentObject(inspirationViewModel)
                .environmentObject(taskViewModel)
                .environmentObject(dashboardViewModel)
                .environmentObject(notificationManager)
        }
    }
}

struct AppContentView: View {
    @State private var showingLaunchScreen = true
    @State private var hasRequestedNotificationPermission = false
    @EnvironmentObject var notificationManager: NotificationManager
    
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
                    .onAppear {
                        // 首次啟動時請求通知權限
                        if !hasRequestedNotificationPermission {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                notificationManager.requestNotificationPermission()
                                hasRequestedNotificationPermission = true
                            }
                        }
                    }
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var inspirationViewModel: InspirationViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var appState: AppState
    @Environment(\.scenePhase) private var scenePhase
    
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
                .environmentObject(notificationManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
        }
        .onAppear {
            notificationManager.updateUnorganizedReminderIfNeeded(
                inspirations: inspirationViewModel.inspirations,
                isOrganized: inspirationViewModel.isOrganized
            )
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                notificationManager.updateUnorganizedReminderIfNeeded(
                    inspirations: inspirationViewModel.inspirations,
                    isOrganized: inspirationViewModel.isOrganized
                )
            }
        }
    }
}
