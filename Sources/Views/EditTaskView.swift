import SwiftUI
import CoreData

struct EditTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var inspirationViewModel: InspirationViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var title: String
    @State private var details: String
    @State private var status: TaskStatus
    @State private var isSaved = false
    @State private var selectedInspiration: Inspiration?
    @State private var showInspirationPicker = false
    @State private var reminderDate: Date?
    @State private var showReminderPicker = false
    @State private var isReminderEnabled = false
    
    let task: TaskItem
    
    init(task: TaskItem, taskViewModel: TaskViewModel) {
        self.task = task
        _title = State(initialValue: task.title ?? "")
        _details = State(initialValue: task.details ?? "")
        _status = State(initialValue: taskViewModel.getTaskStatus(task))
        _selectedInspiration = State(initialValue: task.inspiration)
        _reminderDate = State(initialValue: task.reminderDate)
        _isReminderEnabled = State(initialValue: task.reminderDate != nil)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("tasklist_title", comment: "標題"))) {
                    TextField(NSLocalizedString("task_title_placeholder", comment: "輸入任務標題"), text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text(NSLocalizedString("tasklist_description", comment: "描述"))) {
                    TextEditor(text: $details)
                        .frame(minHeight: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                Section(header: Text(NSLocalizedString("tasklist_status", comment: "狀態"))) {
                    Picker(NSLocalizedString("tasklist_status", comment: "狀態"), selection: $status) {
                        ForEach(TaskStatus.allCases, id: \.self) { taskStatus in
                            TaskStatusPickerRow(taskStatus: taskStatus, color: statusColor(for: taskStatus), statusName: taskStatusName(taskStatus.rawValue))
                                .tag(taskStatus)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // 任務提醒設定
                Section(header: Text(NSLocalizedString("tasklist_reminder", comment: "任務提醒"))) {
                    Toggle(NSLocalizedString("tasklist_enable_reminder", comment: "啟用提醒"), isOn: $isReminderEnabled)
                        .onChange(of: isReminderEnabled) { _, newValue in
                            if !newValue {
                                reminderDate = nil
                                // 取消現有提醒
                                if let taskId = task.id?.uuidString {
                                    notificationManager.cancelTaskReminder(for: taskId)
                                }
                            }
                        }
                    
                    if isReminderEnabled {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                if let reminderDate = reminderDate {
                                    Text(NSLocalizedString("tasklist_reminder_time", comment: "提醒時間") + ": \(formatReminderDate(reminderDate))")
                                        .font(.system(size: 14))
                                        .foregroundColor(.primary)
                                } else {
                                    Text(NSLocalizedString("tasklist_reminder_not_set", comment: "尚未設定提醒時間"))
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Button(NSLocalizedString("tasklist_set_time", comment: "設定時間")) {
                                showReminderPicker = true
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // 顯示與選擇關聯靈感
                Section(header: Text(NSLocalizedString("tasklist_related_inspiration", comment: "關聯靈感"))) {
                    if let inspiration = selectedInspiration {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
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
                    } else {
                        Text(NSLocalizedString("tasklist_no_related_inspiration", comment: "尚未選擇關聯靈感"))
                            .font(.custom("HelveticaNeue-Light", size: 12))
                            .foregroundColor(.secondary)
                    }
                    Button(NSLocalizedString("tasklist_select_inspiration", comment: "選擇靈感")) {
                        showInspirationPicker = true
                    }
                }
            }
            .navigationTitle(NSLocalizedString("tasklist_edit_task", comment: "編輯任務"))
            .navigationBarItems(
                leading: Button(NSLocalizedString("tasklist_cancel", comment: "取消")) {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(NSLocalizedString("tasklist_save", comment: "儲存")) {
                    saveTask()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            )
            .alert(isPresented: $isSaved) {
                Alert(title: Text(NSLocalizedString("tasklist_updated", comment: "任務已更新")), dismissButton: .default(Text(NSLocalizedString("tasklist_done", comment: "完成"))) {
                    presentationMode.wrappedValue.dismiss()
                })
            }
            .sheet(isPresented: $showInspirationPicker) {
                InspirationPickerView(selectedInspiration: $selectedInspiration)
                    .environmentObject(inspirationViewModel)
            }
            .sheet(isPresented: $showReminderPicker) {
                ReminderPickerView(reminderDate: $reminderDate)
            }
        }
    }
    
    private func saveTask() {
        taskViewModel.updateTask(task, title: title, details: details.isEmpty ? nil : details)
        taskViewModel.updateTaskStatus(task, status: status)
        
        // 更新關聯靈感
        task.inspiration = selectedInspiration
        
        // 更新提醒設定
        task.reminderDate = isReminderEnabled ? reminderDate : nil
        
        // 處理提醒通知
        if isReminderEnabled, let reminderDate = reminderDate {
            notificationManager.scheduleTaskReminder(for: task, at: reminderDate)
        } else {
            // 取消提醒
            if let taskId = task.id?.uuidString {
                notificationManager.cancelTaskReminder(for: taskId)
            }
        }
        
        taskViewModel.saveContext()
        isSaved = true
    }
    
    private func formatReminderDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func statusColor(for status: TaskStatus) -> Color {
        switch status {
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
        case 0: return NSLocalizedString("note_title", comment: "筆記")
        case 1: return NSLocalizedString("image_title", comment: "圖片")
        case 2: return NSLocalizedString("url_title", comment: "連結")
        case 3: return NSLocalizedString("video_url_title", comment: "影片")
        default: return NSLocalizedString("inspiration_title", comment: "靈感")
        }
    }
}

// 將 taskStatusName 移到檔案最外層
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

struct TaskStatusPickerRow: View {
    let taskStatus: TaskStatus
    let color: Color
    let statusName: String
    var body: some View {
        HStack {
            Image(systemName: taskStatus.iconName)
                .foregroundColor(color)
            Text(statusName)
        }
    }
}

// 靈感選擇器
struct InspirationPickerView: View {
    @EnvironmentObject var inspirationViewModel: InspirationViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedInspiration: Inspiration?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(inspirationViewModel.inspirations, id: \.objectID) { inspiration in
                    Button(action: {
                        selectedInspiration = inspiration
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: typeIcon(for: inspiration.type))
                                .foregroundColor(typeColor(for: inspiration.type))
                            Text(inspiration.title ?? "Untitled")
                            Spacer()
                            if selectedInspiration == inspiration {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("tasklist_select_inspiration", comment: "選擇靈感"))
            .navigationBarItems(leading: Button(NSLocalizedString("tasklist_cancel", comment: "取消")) {
                presentationMode.wrappedValue.dismiss()
            })
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
}

// 提醒時間選擇器
struct ReminderPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var reminderDate: Date?
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(NSLocalizedString("tasklist_select_reminder_time", comment: "選擇提醒時間"))
                    .font(.headline)
                    .padding(.top)
                
                DatePicker(NSLocalizedString("tasklist_reminder_time", comment: "提醒時間"), selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
                
                HStack(spacing: 12) {
                    Button(NSLocalizedString("tasklist_cancel", comment: "取消")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button(NSLocalizedString("tasklist_set_reminder", comment: "設定提醒")) {
                        reminderDate = selectedDate
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct EditTaskView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let taskViewModel = TaskViewModel(context: context)
        let inspirationViewModel = InspirationViewModel(context: context)
        let notificationManager = NotificationManager.shared
        let task = TaskItem(context: context)
        task.title = "測試任務"
        task.details = "這是一個測試任務"
        return EditTaskView(task: task, taskViewModel: taskViewModel)
            .environmentObject(taskViewModel)
            .environmentObject(inspirationViewModel)
            .environmentObject(notificationManager)
    }
}