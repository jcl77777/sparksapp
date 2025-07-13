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
                    
                    // 週趨勢圖表區塊
                    WeeklyTrendSection()
                }
                .padding()
            }
            .navigationTitle("Dashboard")
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
                Text("今日統計")
                    .font(.custom("HelveticaNeue-Light", size: 20))
                    .fontWeight(.medium)
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "新增靈感",
                    value: "\(dashboardViewModel.todayInspirations)",
                    icon: "lightbulb",
                    color: .orange
                )
                
                StatCard(
                    title: "新增任務",
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
                Text("總覽統計")
                    .font(.custom("HelveticaNeue-Light", size: 20))
                    .fontWeight(.medium)
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "總靈感數",
                    value: "\(dashboardViewModel.totalInspirations)",
                    icon: "lightbulb.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "總任務數",
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
                Text("任務狀態")
                    .font(.custom("HelveticaNeue-Light", size: 20))
                    .fontWeight(.medium)
                Spacer()
            }
            
            VStack(spacing: 12) {
                TaskStatusRow(
                    title: "待處理",
                    count: dashboardViewModel.pendingTasks,
                    icon: "circle",
                    color: .gray
                )
                
                TaskStatusRow(
                    title: "進行中",
                    count: dashboardViewModel.inProgressTasks,
                    icon: "clock",
                    color: .blue
                )
                
                TaskStatusRow(
                    title: "已完成",
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
                Text("靈感整理狀態")
                    .font(.custom("HelveticaNeue-Light", size: 20))
                    .fontWeight(.medium)
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "已整理",
                    value: "\(dashboardViewModel.organizedInspirations)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "未整理",
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

// 週趨勢圖表區塊
struct WeeklyTrendSection: View {
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.purple)
                    .font(.title2)
                Text("週趨勢")
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
            Text("過去7天新增靈感數量")
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