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

        var localized: String {
            switch self {
            case .all: return NSLocalizedString("task_status_all", comment: "全部")
            case .pending: return NSLocalizedString("task_status_pending", comment: "待處理")
            case .inProgress: return NSLocalizedString("task_status_inprogress", comment: "進行中")
            case .completed: return NSLocalizedString("task_status_completed", comment: "已完成")
            }
        }
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
                SearchBar(text: $searchText, placeholder: NSLocalizedString("tasklist_search_placeholder", comment: "搜尋任務"))
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // 狀態篩選
                Picker(NSLocalizedString("tasklist_status", comment: "狀態"), selection: $selectedStatus) {
                    ForEach(TaskStatusFilter.allCases, id: \.self) { status in
                        Text(status.localized).tag(status)
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
                            .font(.custom("HelveticaNeue-Light", size: 17))
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
            .navigationTitle(NSLocalizedString("tasks_navigation_title", comment: "任務"))
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
            return String(format: NSLocalizedString("tasklist_empty_search", comment: "沒有找到符合"), searchText)
        }
        
        switch selectedStatus {
        case .pending:
            return NSLocalizedString("tasklist_empty_pending", comment: "沒有待處理的任務")
        case .inProgress:
            return NSLocalizedString("tasklist_empty_inprogress", comment: "沒有進行中的任務")
        case .completed:
            return NSLocalizedString("tasklist_empty_completed", comment: "沒有已完成的任務")
        case .all:
            return NSLocalizedString("tasklist_empty_all", comment: "還沒有任何任務")
        }
    }
}

// 任務狀態名稱本地化
fileprivate func taskStatusName(_ status: Int16) -> String {
    switch status {
    case 0:
        return NSLocalizedString("taskstatus_todo", comment: "待處理")
    case 1:
        return NSLocalizedString("taskstatus_doing", comment: "進行中")
    case 2:
        return NSLocalizedString("taskstatus_done", comment: "已完成")
    default:
        return NSLocalizedString("taskstatus_unknown", comment: "未知")
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
                        .font(.system(size: 22))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // 標題
                        Text(task.title ?? "Untitled")
                            .font(.custom("HelveticaNeue-Light", size: 17))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        // 建立時間
                        if let createdAt = task.createdAt {
                            Text(taskViewModel.getFormattedDate(createdAt))
                                .font(.custom("HelveticaNeue-Light", size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // 狀態指示器和提醒圖示
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        Text(taskStatusName(task.status))
                            .font(.custom("HelveticaNeue-Light", size: 10))
                            .foregroundColor(statusColor)
                        
                        // 提醒圖示
                        if task.reminderDate != nil {
                            Image(systemName: "bell")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // 描述
                if let details = task.details, !details.isEmpty {
                    Text(details)
                        .font(.custom("HelveticaNeue-Light", size: 12))
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
                                .font(.system(size: 12))
                            Text(typeName(for: inspiration.type))
                                .font(.custom("HelveticaNeue-Light", size: 10))
                                .foregroundColor(.secondary)
                            Text(inspiration.title ?? "Untitled")
                                .font(.custom("HelveticaNeue-Light", size: 12))
                                .foregroundColor(.orange)
                                .lineLimit(1)
                        }
                        // 標籤 badge
                        let tagNames = (inspiration.tags as? Set<Tag>)?.compactMap { $0.name }.sorted() ?? []
                        if !tagNames.isEmpty {
                            HStack {
                                ForEach(tagNames, id: \.self) { tagName in
                                    Text(tagName)
                                        .font(.custom("HelveticaNeue-Light", size: 10))
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
        case 0: return NSLocalizedString("task_type_note", comment: "筆記")
        case 1: return NSLocalizedString("task_type_image", comment: "圖片")
        case 2: return NSLocalizedString("task_type_url", comment: "連結")
        case 3: return NSLocalizedString("task_type_video", comment: "影片")
        default: return NSLocalizedString("task_type_inspiration", comment: "靈感")
        }
    }
}

// 任務詳情頁面
struct TaskDetailView: View {
    let task: TaskItem
    let taskViewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditSheet = false
    @State private var showingAlert = false
    @State private var alertType: AlertType = .delete
    @State private var currentTask: TaskItem?
    
    enum AlertType {
        case delete
        case complete
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 標題
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("taskdetail_title", comment: "標題"))
                                .font(.custom("HelveticaNeue-Light", size: 17))
                                .foregroundColor(.secondary)
                            Text(currentTask?.title ?? task.title ?? NSLocalizedString("taskdetail_untitled", comment: "未命名"))
                                .font(.custom("HelveticaNeue-Light", size: 22))
                        }
                        
                        // 描述
                        if let details = currentTask?.details ?? task.details, !details.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("taskdetail_description", comment: "描述"))
                                    .font(.custom("HelveticaNeue-Light", size: 17))
                                    .foregroundColor(.secondary)
                                Text(details)
                                    .font(.custom("HelveticaNeue-Light", size: 16))
                            }
                        }
                        
                        // 狀態
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("taskdetail_status", comment: "狀態"))
                                .font(.custom("HelveticaNeue-Light", size: 17))
                                .foregroundColor(.secondary)
                            HStack {
                                Image(systemName: statusIcon)
                                    .foregroundColor(statusColor)
                                Text(taskStatusName((currentTask ?? task).status))
                                    .font(.custom("HelveticaNeue-Light", size: 15))
                                    .foregroundColor(statusColor)
                            }
                        }
                        
                        // 關聯靈感
                        if let inspiration = (currentTask ?? task).inspiration {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("taskdetail_related_spark", comment: "關聯靈感"))
                                    .font(.custom("HelveticaNeue-Light", size: 17))
                                    .foregroundColor(.secondary)
                                HStack {
                                    Image(systemName: typeIcon(for: inspiration.type))
                                        .foregroundColor(typeColor(for: inspiration.type))
                                    Text(typeName(for: inspiration.type))
                                        .font(.custom("HelveticaNeue-Light", size: 12))
                                        .foregroundColor(.secondary)
                                }
                                Text(inspiration.title ?? NSLocalizedString("taskdetail_untitled", comment: "未命名"))
                                    .font(.custom("HelveticaNeue-Light", size: 16))
                            }
                        }
                        
                        // 提醒設定
                        if let reminderDate = (currentTask ?? task).reminderDate {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("taskdetail_reminder", comment: "提醒設定"))
                                    .font(.custom("HelveticaNeue-Light", size: 17))
                                    .foregroundColor(.secondary)
                                HStack {
                                    Image(systemName: "bell")
                                        .foregroundColor(.orange)
                                    Text(NSLocalizedString("taskdetail_reminder_time", comment: "提醒時間：") + taskViewModel.getFormattedDate(reminderDate))
                                        .font(.custom("HelveticaNeue-Light", size: 12))
                                }
                            }
                        }
                        
                        // 時間資訊
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("taskdetail_time_info", comment: "時間資訊"))
                                .font(.custom("HelveticaNeue-Light", size: 17))
                                .foregroundColor(.secondary)
                            VStack(alignment: .leading, spacing: 4) {
                                if let createdAt = (currentTask ?? task).createdAt {
                                    Text(NSLocalizedString("taskdetail_created_at", comment: "建立時間：") + taskViewModel.getFormattedDate(createdAt))
                                        .font(.custom("HelveticaNeue-Light", size: 12))
                                }
                                if let updatedAt = (currentTask ?? task).updatedAt {
                                    Text(NSLocalizedString("taskdetail_updated_at", comment: "更新時間：") + taskViewModel.getFormattedDate(updatedAt))
                                        .font(.custom("HelveticaNeue-Light", size: 12))
                                }
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 100) // 預留底部icon列空間
                }
                // 操作icon列永遠置底
                HStack(spacing: 0) {
                    Button(action: {
                        alertType = .complete
                        showingAlert = true
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 28, weight: .regular))
                            Text(NSLocalizedString("taskdetail_done", comment: "完成"))
                                .font(.system(size: 15))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                    }
                    Divider()
                        .frame(height: 36)
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: "pencil")
                                .font(.system(size: 28, weight: .regular))
                            Text(NSLocalizedString("taskdetail_edit", comment: "編輯"))
                                .font(.system(size: 15))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                    }
                    Divider()
                        .frame(height: 36)
                    Button(action: {
                        alertType = .delete
                        showingAlert = true
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: "trash")
                                .font(.system(size: 28, weight: .regular))
                            Text(NSLocalizedString("taskdetail_delete", comment: "刪除"))
                                .font(.system(size: 15))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground).ignoresSafeArea())
            }
            .navigationTitle(NSLocalizedString("taskdetail_title_page", comment: "任務詳情"))
            .navigationBarItems(
                leading: Button(NSLocalizedString("taskdetail_close", comment: "關閉")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showingEditSheet) {
                EditTaskView(task: currentTask ?? task, taskViewModel: taskViewModel)
            }
            .alert(isPresented: $showingAlert) {
                switch alertType {
                case .delete:
                    return Alert(
                        title: Text(NSLocalizedString("taskdetail_confirm_delete", comment: "確認刪除")),
                        message: Text(NSLocalizedString("taskdetail_delete_message", comment: "確定要刪除這個任務嗎？此操作無法復原。")),
                        primaryButton: .destructive(Text(NSLocalizedString("taskdetail_delete", comment: "刪除"))) {
                            taskViewModel.deleteTask(task)
                            presentationMode.wrappedValue.dismiss()
                        },
                        secondaryButton: .cancel(Text(NSLocalizedString("taskdetail_close", comment: "關閉")))
                    )
                case .complete:
                    return Alert(
                        title: Text(NSLocalizedString("taskdetail_mark_done", comment: "標記完成")),
                        message: Text(NSLocalizedString("taskdetail_mark_done_message", comment: "確定要將此任務標記為已完成嗎？")),
                        primaryButton: .default(Text(NSLocalizedString("taskdetail_done", comment: "完成"))) {
                            taskViewModel.updateTaskStatus(currentTask ?? task, status: .completed)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        },
                        secondaryButton: .cancel(Text(NSLocalizedString("taskdetail_close", comment: "關閉")))
                    )
                }
            }
            .onAppear {
                if let updated = taskViewModel.tasks.first(where: { $0.objectID == task.objectID }) {
                    currentTask = updated
                }
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
        case 0: return NSLocalizedString("task_type_note", comment: "筆記")
        case 1: return NSLocalizedString("task_type_image", comment: "圖片")
        case 2: return NSLocalizedString("task_type_link", comment: "連結")
        case 3: return NSLocalizedString("task_type_video", comment: "影片")
        default: return NSLocalizedString("task_type_inspiration", comment: "靈感")
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