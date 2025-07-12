import SwiftUI
import CoreData

struct TaskListView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var taskViewModel: TaskViewModel
    @State private var showAddTaskSheet = false
    @State private var defaultTitle: String = ""
    @State private var selectedStatus: TaskStatusFilter = .all
    @State private var searchText = ""
    
    enum TaskStatusFilter: String, CaseIterable {
        case all = "全部"
        case pending = "待處理"
        case inProgress = "進行中"
        case completed = "已完成"
    }
    
    var filteredTasks: [TaskItem] {
        var tasks = taskViewModel.tasks
        
        // 根據狀態篩選
        switch selectedStatus {
        case .pending:
            tasks = tasks.filter { taskViewModel.getTaskStatus($0) == .pending }
        case .inProgress:
            tasks = tasks.filter { taskViewModel.getTaskStatus($0) == .inProgress }
        case .completed:
            tasks = tasks.filter { taskViewModel.getTaskStatus($0) == .completed }
        case .all:
            break
        }
        
        // 根據搜尋文字篩選
        if !searchText.isEmpty {
            tasks = tasks.filter { task in
                let title = task.title ?? ""
                let details = task.details ?? ""
                return title.localizedCaseInsensitiveContains(searchText) ||
                       details.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return tasks
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜尋欄位
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // 狀態篩選
                Picker("狀態", selection: $selectedStatus) {
                    ForEach(TaskStatusFilter.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // 任務列表
                if filteredTasks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(emptyStateMessage)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        ForEach(filteredTasks, id: \.objectID) { task in
                            TaskCardView(task: task, taskViewModel: taskViewModel)
                        }
                        .onDelete { indexSet in
                            indexSet.map { filteredTasks[$0] }.forEach(taskViewModel.deleteTask)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTaskSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                if let title = appState.addTaskDefaultTitle {
                    defaultTitle = title
                    showAddTaskSheet = true
                    appState.addTaskDefaultTitle = nil // 清空，避免重複彈出
                }
            }
            .sheet(isPresented: $showAddTaskSheet) {
                AddTaskView(inspiration: nil, defaultTitle: defaultTitle)
            }
        }
    }
    
    private var emptyStateMessage: String {
        if !searchText.isEmpty {
            return "沒有找到符合「\(searchText)」的任務"
        }
        
        switch selectedStatus {
        case .pending:
            return "沒有待處理的任務\n點擊「+」開始新增"
        case .inProgress:
            return "沒有進行中的任務"
        case .completed:
            return "沒有已完成的任務"
        case .all:
            return "還沒有任何任務\n點擊「+」開始新增"
        }
    }
}

// 任務卡片元件
struct TaskCardView: View {
    let task: TaskItem
    let taskViewModel: TaskViewModel
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // 狀態圖示
                    Image(systemName: statusIcon)
                        .foregroundColor(statusColor)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // 標題
                        Text(task.title ?? "Untitled")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        // 建立時間
                        if let createdAt = task.createdAt {
                            Text(taskViewModel.getFormattedDate(createdAt))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // 狀態指示器
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        Text(taskViewModel.getTaskStatus(task).name)
                            .font(.caption2)
                            .foregroundColor(statusColor)
                    }
                }
                
                // 描述
                if let details = task.details, !details.isEmpty {
                    Text(details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // 關聯靈感資訊
                if let inspiration = task.inspiration {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            // 類型icon
                            Image(systemName: typeIcon(for: inspiration.type))
                                .foregroundColor(typeColor(for: inspiration.type))
                                .font(.caption)
                            Text(typeName(for: inspiration.type))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(inspiration.title ?? "Untitled")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .lineLimit(1)
                        }
                        // 標籤 badge
                        let tagNames = (inspiration.tag as? Set<Tag>)?.compactMap { $0.name }.sorted() ?? []
                        if !tagNames.isEmpty {
                            HStack {
                                ForEach(tagNames, id: \.self) { tagName in
                                    Text(tagName)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            TaskDetailView(task: task, taskViewModel: taskViewModel)
        }
    }
    
    private var statusIcon: String {
        switch taskViewModel.getTaskStatus(task) {
        case .pending:
            return "circle"
        case .inProgress:
            return "clock"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch taskViewModel.getTaskStatus(task) {
        case .pending:
            return .gray
        case .inProgress:
            return .blue
        case .completed:
            return .green
        }
    }
    
    private func typeIcon(for type: Int16) -> String {
        switch type {
        case 0: return "doc.text"
        case 1: return "photo"
        case 2: return "link"
        case 3: return "video"
        default: return "lightbulb"
        }
    }
    private func typeColor(for type: Int16) -> Color {
        switch type {
        case 0: return .blue
        case 1: return .green
        case 2: return .orange
        case 3: return .purple
        default: return .gray
        }
    }
    private func typeName(for type: Int16) -> String {
        switch type {
        case 0: return "筆記"
        case 1: return "圖片"
        case 2: return "連結"
        case 3: return "影片"
        default: return "靈感"
        }
    }
}

// 任務詳情頁面
struct TaskDetailView: View {
    let task: TaskItem
    let taskViewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 標題
                    VStack(alignment: .leading, spacing: 8) {
                        Text("標題")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(task.title ?? "Untitled")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    // 描述
                    if let details = task.details, !details.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("描述")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(details)
                                .font(.body)
                        }
                    }
                    
                    // 狀態
                    VStack(alignment: .leading, spacing: 8) {
                        Text("狀態")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        HStack {
                            Image(systemName: statusIcon)
                                .foregroundColor(statusColor)
                            Text(taskViewModel.getTaskStatus(task).name)
                                .foregroundColor(statusColor)
                        }
                    }
                    
                    // 關聯靈感
                    if let inspiration = task.inspiration {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("關聯靈感")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(inspiration.title ?? "Untitled")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                if let content = inspiration.content, !content.isEmpty {
                                    Text(content)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(3)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    // 時間資訊
                    VStack(alignment: .leading, spacing: 8) {
                        Text("時間資訊")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        VStack(alignment: .leading, spacing: 4) {
                            if let createdAt = task.createdAt {
                                Text("建立時間：\(taskViewModel.getFormattedDate(createdAt))")
                                    .font(.caption)
                            }
                            if let updatedAt = task.updatedAt {
                                Text("更新時間：\(taskViewModel.getFormattedDate(updatedAt))")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("任務詳情")
            .navigationBarItems(
                leading: Button("關閉") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("編輯") {
                    showingEditSheet = true
                }
            )
            .sheet(isPresented: $showingEditSheet) {
                EditTaskView(task: task, taskViewModel: taskViewModel)
            }
        }
    }
    
    private var statusIcon: String {
        switch taskViewModel.getTaskStatus(task) {
        case .pending:
            return "circle"
        case .inProgress:
            return "clock"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch taskViewModel.getTaskStatus(task) {
        case .pending:
            return .gray
        case .inProgress:
            return .blue
        case .completed:
            return .green
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        TaskListView()
            .environmentObject(AppState.shared)
            .environmentObject(TaskViewModel(context: context))
    }
} 