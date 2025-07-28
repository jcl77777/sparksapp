import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    @State private var showingRefresh = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // 今日統計區塊
                    TodayStatsSection()
                    
                    // 總覽統計區塊
                    OverviewStatsSection()
                    
                    // 任務狀態統計區塊
                    TaskStatsSection()
                    
                    // 靈感整理狀態區塊
                    OrganizationStatsSection()
                    
                    // 連續紀錄顯示區塊
                    StreakSection()
                    
                    // 週趨勢圖表區塊
                    WeeklyTrendSection()
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("dashboard_title", comment: "儀表板"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingRefresh = true
                            dashboardViewModel.refresh()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingRefresh = false
                        }
                    }) {
                        Image(systemName: showingRefresh ? "arrow.clockwise.circle.fill" : "arrow.clockwise")
                            .rotationEffect(.degrees(showingRefresh ? 360 : 0))
                            .animation(.linear(duration: 0.3), value: showingRefresh)
                    }
                }
            }
            .onAppear {
                dashboardViewModel.refresh()
            }
        }
    }
}

// 今日統計區塊
struct TodayStatsSection: View {
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text(NSLocalizedString("dashboard_today_stats", comment: "今日統計"))
                    .font(.custom("HelveticaNeue-Light", size: 20))
                    .fontWeight(.medium)
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: NSLocalizedString("dashboard_new_inspirations", comment: "新增靈感"),
                    value: "\(dashboardViewModel.todayInspirations)",
                    icon: "lightbulb",
                    color: .orange
                )
                
                StatCard(
                    title: NSLocalizedString("dashboard_new_tasks", comment: "新增任務"),
                    value: "\(dashboardViewModel.todayTasks)",
                    icon: "checkmark.circle",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// 總覽統計區塊
struct OverviewStatsSection: View {
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar")
                    .foregroundColor(.purple)
                    .font(.title2)
                Text(NSLocalizedString("dashboard_overview_stats", comment: "總覽統計"))
                    .font(.custom("HelveticaNeue-Light", size: 20))
                    .fontWeight(.medium)
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: NSLocalizedString("dashboard_total_inspirations", comment: "總靈感數"),
                    value: "\(dashboardViewModel.totalInspirations)",
                    icon: "lightbulb.fill",
                    color: .blue
                )
                
                StatCard(
                    title: NSLocalizedString("dashboard_total_tasks", comment: "總任務數"),
                    value: "\(dashboardViewModel.totalTasks)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// 任務狀態統計區塊
struct TaskStatsSection: View {
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.clipboard")
                    .foregroundColor(.green)
                    .font(.title2)
                Text(NSLocalizedString("dashboard_task_status", comment: "任務狀態"))
                    .font(.custom("HelveticaNeue-Light", size: 20))
                    .fontWeight(.medium)
                Spacer()
            }
            
            VStack(spacing: 12) {
                TaskStatusRow(
                    title: NSLocalizedString("taskstatus_todo", comment: "待處理"),
                    count: dashboardViewModel.pendingTasks,
                    icon: "circle",
                    color: .gray
                )
                
                TaskStatusRow(
                    title: NSLocalizedString("taskstatus_doing", comment: "進行中"),
                    count: dashboardViewModel.inProgressTasks,
                    icon: "clock",
                    color: .blue
                )
                
                TaskStatusRow(
                    title: NSLocalizedString("taskstatus_done", comment: "已完成"),
                    count: dashboardViewModel.completedTasks,
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// 靈感整理狀態區塊
struct OrganizationStatsSection: View {
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "folder")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text(NSLocalizedString("dashboard_organization_status", comment: "靈感整理狀態"))
                    .font(.custom("HelveticaNeue-Light", size: 20))
                    .fontWeight(.medium)
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: NSLocalizedString("dashboard_organized", comment: "已整理"),
                    value: "\(dashboardViewModel.organizedInspirations)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: NSLocalizedString("dashboard_unorganized", comment: "未整理"),
                    value: "\(dashboardViewModel.unorganizedInspirations)",
                    icon: "exclamationmark.circle",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// 連續紀錄顯示區塊
struct StreakSection: View {
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "flame")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text(NSLocalizedString("dashboard_streak", comment: "連續紀錄"))
                    .font(.custom("HelveticaNeue-Light", size: 20))
                    .fontWeight(.medium)
                Spacer()
            }
            
            HStack(spacing: 16) {
                StreakCard(
                    title: NSLocalizedString("dashboard_current_streak", comment: "當前連續"),
                    value: "\(dashboardViewModel.currentStreak)",
                    subtitle: NSLocalizedString("dashboard_days", comment: "天"),
                    icon: "flame.fill",
                    color: .orange,
                    badge: getCurrentStreakBadge()
                )
                
                StreakCard(
                    title: NSLocalizedString("dashboard_longest_streak", comment: "最長連續"),
                    value: "\(dashboardViewModel.longestStreak)",
                    subtitle: NSLocalizedString("dashboard_days", comment: "天"),
                    icon: "trophy.fill",
                    color: .yellow,
                    badge: getLongestStreakBadge()
                )
            }
            
            // 成就徽章顯示
            if !getAchievementBadges().isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(NSLocalizedString("dashboard_achievement_badges", comment: "成就徽章"))
                        .font(.custom("HelveticaNeue-Light", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(getAchievementBadges(), id: \.title) { badge in
                            BadgeView(badge: badge)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func getCurrentStreakBadge() -> String? {
        let streak = dashboardViewModel.currentStreak
        if streak >= 7 { return "🔥" }
        if streak >= 3 { return "⚡" }
        return nil
    }
    
    private func getLongestStreakBadge() -> String? {
        let streak = dashboardViewModel.longestStreak
        if streak >= 30 { return "🏆" }
        if streak >= 14 { return "🥇" }
        if streak >= 7 { return "🥈" }
        return nil
    }
    
    private func getAchievementBadges() -> [AchievementBadge] {
        var badges: [AchievementBadge] = []
        
        // 基於連續天數的成就
        let currentStreak = dashboardViewModel.currentStreak
        let longestStreak = dashboardViewModel.longestStreak
        let totalDays = dashboardViewModel.consecutiveDays
        
        if currentStreak >= 7 {
            badges.append(AchievementBadge(title: NSLocalizedString("dashboard_badge_7day", comment: "一週堅持"), icon: "7.circle.fill", color: .blue, unlocked: true))
        }
        if currentStreak >= 14 {
            badges.append(AchievementBadge(title: NSLocalizedString("dashboard_badge_14day", comment: "兩週堅持"), icon: "14.circle.fill", color: .green, unlocked: true))
        }
        if currentStreak >= 30 {
            badges.append(AchievementBadge(title: NSLocalizedString("dashboard_badge_30day", comment: "月堅持"), icon: "30.circle.fill", color: .purple, unlocked: true))
        }
        
        if longestStreak >= 7 {
            badges.append(AchievementBadge(title: NSLocalizedString("dashboard_badge_longest7", comment: "最長7天"), icon: "trophy", color: .orange, unlocked: true))
        }
        if longestStreak >= 14 {
            badges.append(AchievementBadge(title: NSLocalizedString("dashboard_badge_longest14", comment: "最長14天"), icon: "trophy.fill", color: .yellow, unlocked: true))
        }
        if longestStreak >= 30 {
            badges.append(AchievementBadge(title: NSLocalizedString("dashboard_badge_longest30", comment: "最長30天"), icon: "crown.fill", color: .purple, unlocked: true))
        }
        
        // 基於總活動天數的成就
        if totalDays >= 10 {
            badges.append(AchievementBadge(title: NSLocalizedString("dashboard_badge_active", comment: "活躍用戶"), icon: "star.fill", color: .blue, unlocked: true))
        }
        if totalDays >= 30 {
            badges.append(AchievementBadge(title: NSLocalizedString("dashboard_badge_veteran", comment: "資深用戶"), icon: "star.circle.fill", color: .green, unlocked: true))
        }
        if totalDays >= 100 {
            badges.append(AchievementBadge(title: NSLocalizedString("dashboard_badge_master", comment: "大師級"), icon: "crown", color: .purple, unlocked: true))
        }
        
        return badges
    }
}

// 連續天數卡片元件
struct StreakCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let badge: String?
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                if let badge = badge {
                    Text(badge)
                        .font(.title3)
                }
            }
            
            Text(value)
                .font(.custom("HelveticaNeue-Light", size: 28))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.custom("HelveticaNeue-Light", size: 12))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.custom("HelveticaNeue-Light", size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// 成就徽章資料結構
struct AchievementBadge {
    let title: String
    let icon: String
    let color: Color
    let unlocked: Bool
}

// 成就徽章元件
struct BadgeView: View {
    let badge: AchievementBadge
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: badge.icon)
                .foregroundColor(badge.unlocked ? badge.color : .gray)
                .font(.title2)
            
            Text(badge.title)
                .font(.custom("HelveticaNeue-Light", size: 10))
                .foregroundColor(badge.unlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 60, height: 60)
        .background(badge.unlocked ? badge.color.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// 週趨勢圖表區塊
struct WeeklyTrendSection: View {
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.purple)
                    .font(.title2)
                Text(NSLocalizedString("dashboard_weekly_trend", comment: "週趨勢"))
                    .font(.custom("HelveticaNeue-Light", size: 20))
                    .fontWeight(.medium)
                Spacer()
            }
            
            WeeklyChartView(data: dashboardViewModel.weeklyInspirationData)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// 統計卡片元件
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.custom("HelveticaNeue-Light", size: 24))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.custom("HelveticaNeue-Light", size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// 任務狀態行元件
struct TaskStatusRow: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16))
            
            Text(title)
                .font(.custom("HelveticaNeue-Light", size: 16))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(count)")
                .font(.custom("HelveticaNeue-Light", size: 16))
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}

// 週趨勢圖表元件
struct WeeklyChartView: View {
    let data: [Date: Int]
    
    private var sortedData: [(Date, Int)] {
        data.sorted { $0.key < $1.key }
    }
    
    private var maxValue: Int {
        data.values.max() ?? 1
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(sortedData, id: \.0) { date, count in
                    VStack(spacing: 4) {
                        // 柱狀圖
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue.opacity(0.7))
                            .frame(width: 30, height: max(20, CGFloat(count) / CGFloat(maxValue) * 80))
                        
                        // 日期標籤
                        Text(formatDate(date))
                            .font(.custom("HelveticaNeue-Light", size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 100)
            
            // 圖表說明
            Text(NSLocalizedString("dashboard_weekly_inspiration_count", comment: "過去7天新增靈感數量"))
                .font(.custom("HelveticaNeue-Light", size: 12))
                .foregroundColor(.secondary)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        DashboardView()
            .environmentObject(DashboardViewModel(context: context))
    }
} 