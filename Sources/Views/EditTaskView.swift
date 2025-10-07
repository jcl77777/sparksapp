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
        ScrollView {
            VStack(spacing: 0) {
                // Gradient Header
                GradientHeader(
                    title: "✏️ " + NSLocalizedString("tasklist_edit_task", comment: "編輯任務"),
                    gradientColors: AppDesign.Colors.blueGradient
                )

                VStack(spacing: AppDesign.Spacing.standard) {
                    // 任務標題
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("tasklist_title", comment: "標題"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        TextField(NSLocalizedString("task_title_placeholder", comment: "輸入任務標題"), text: $title)
                            .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                            .padding(AppDesign.Spacing.small)
                            .background(Color.white)
                            .cornerRadius(AppDesign.Borders.radiusCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                                    .stroke(AppDesign.Colors.borderPrimary, lineWidth: AppDesign.Borders.thin)
                            )
                    }

                    // 任務描述
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("tasklist_description", comment: "描述"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        TextEditor(text: $details)
                            .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                            .frame(minHeight: 100)
                            .padding(AppDesign.Spacing.small)
                            .background(Color.white)
                            .cornerRadius(AppDesign.Borders.radiusCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                                    .stroke(AppDesign.Colors.borderPrimary, lineWidth: AppDesign.Borders.thin)
                            )
                    }

                    // 任務狀態
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("tasklist_status", comment: "狀態"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        Picker(NSLocalizedString("tasklist_status", comment: "狀態"), selection: $status) {
                            ForEach(TaskStatus.allCases, id: \.self) { taskStatus in
                                TaskStatusPickerRow(taskStatus: taskStatus, color: statusColor(for: taskStatus), statusName: taskStatusName(taskStatus.rawValue))
                                    .tag(taskStatus)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(AppDesign.Spacing.small)
                        .background(Color.white)
                        .cornerRadius(AppDesign.Borders.radiusCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                                .stroke(AppDesign.Colors.borderPrimary, lineWidth: AppDesign.Borders.thin)
                        )
                    }

                    // 任務提醒設定
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("tasklist_reminder", comment: "任務提醒"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        PixelCard(borderColor: AppDesign.Colors.orange) {
                            VStack(spacing: AppDesign.Spacing.small) {
                                Toggle(NSLocalizedString("tasklist_enable_reminder", comment: "啟用提醒"), isOn: $isReminderEnabled)
                                    .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
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
                                    Divider()

                                    HStack {
                                        Text("🔔")
                                            .font(.system(size: 20))

                                        VStack(alignment: .leading, spacing: 4) {
                                            if let reminderDate = reminderDate {
                                                Text(NSLocalizedString("tasklist_reminder_time", comment: "提醒時間") + ":")
                                                    .font(.system(size: AppDesign.Typography.labelSize, design: .monospaced))
                                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                                Text(formatReminderDate(reminderDate))
                                                    .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                                    .foregroundColor(AppDesign.Colors.textPrimary)
                                            } else {
                                                Text(NSLocalizedString("tasklist_reminder_not_set", comment: "尚未設定提醒時間"))
                                                    .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                            }
                                        }

                                        Spacer()

                                        Button(action: { showReminderPicker = true }) {
                                            Text(NSLocalizedString("tasklist_set_time", comment: "設定時間"))
                                                .font(.system(size: AppDesign.Typography.labelSize, weight: .bold, design: .monospaced))
                                                .foregroundColor(AppDesign.Colors.orange)
                                        }
                                    }
                                }
                            }
                            .padding(AppDesign.Spacing.standard)
                        }
                    }

                    // 顯示與選擇關聯靈感
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("tasklist_related_inspiration", comment: "關聯靈感"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        if let inspiration = selectedInspiration {
                            PixelCard(borderColor: AppDesign.Colors.purple) {
                                VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                                    HStack(spacing: 8) {
                                        Text(typeEmoji(for: inspiration.type))
                                            .font(.system(size: 20))

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(typeName(for: inspiration.type))
                                                .font(.system(size: AppDesign.Typography.labelSize, design: .monospaced))
                                                .foregroundColor(AppDesign.Colors.textSecondary)

                                            Text(inspiration.title ?? "Untitled")
                                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                                .foregroundColor(AppDesign.Colors.textPrimary)
                                                .lineLimit(1)
                                        }

                                        Spacer()
                                    }

                                    // 標籤 badge
                                    let tagNames = (inspiration.tags as? Set<Tag>)?.compactMap { $0.name }.sorted() ?? []
                                    if !tagNames.isEmpty {
                                        TagList(tags: tagNames, selectedTags: [])
                                    }
                                }
                                .padding(AppDesign.Spacing.standard)
                            }
                        } else {
                            PixelCard(borderColor: AppDesign.Colors.gray) {
                                Text(NSLocalizedString("tasklist_no_related_inspiration", comment: "尚未選擇關聯靈感"))
                                    .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                    .padding(AppDesign.Spacing.standard)
                            }
                        }

                        PixelButton(
                            "🔗 " + NSLocalizedString("tasklist_select_inspiration", comment: "選擇靈感"),
                            style: .secondary,
                            color: AppDesign.Colors.purple
                        ) {
                            showInspirationPicker = true
                        }
                    }

                    // 按鈕區域
                    VStack(spacing: AppDesign.Spacing.small) {
                        PixelButton(
                            "💾 " + NSLocalizedString("tasklist_save", comment: "儲存"),
                            color: AppDesign.Colors.green
                        ) {
                            saveTask()
                        }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(title.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)

                        PixelButton(
                            NSLocalizedString("tasklist_cancel", comment: "取消"),
                            style: .secondary,
                            color: AppDesign.Colors.gray
                        ) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .padding(.top, AppDesign.Spacing.small)
                }
                .padding(AppDesign.Spacing.standard)
            }
        }
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
    private func typeEmoji(for type: Int16) -> String {
        switch type {
        case 0: return "📝"
        case 1: return "🖼️"
        case 2: return "🔗"
        case 3: return "🎬"
        default: return "💡"
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
        ScrollView {
            VStack(spacing: 0) {
                // Gradient Header
                GradientHeader(
                    title: "⏰ " + NSLocalizedString("tasklist_select_reminder_time", comment: "選擇提醒時間"),
                    gradientColors: AppDesign.Colors.orangeGradient
                )

                VStack(spacing: AppDesign.Spacing.large) {
                    DatePicker(NSLocalizedString("tasklist_reminder_time", comment: "提醒時間"), selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding(AppDesign.Spacing.standard)

                    VStack(spacing: AppDesign.Spacing.small) {
                        PixelButton(
                            "✓ " + NSLocalizedString("tasklist_set_reminder", comment: "設定提醒"),
                            color: AppDesign.Colors.orange
                        ) {
                            reminderDate = selectedDate
                            presentationMode.wrappedValue.dismiss()
                        }

                        PixelButton(
                            NSLocalizedString("tasklist_cancel", comment: "取消"),
                            style: .secondary,
                            color: AppDesign.Colors.gray
                        ) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .padding(AppDesign.Spacing.standard)
            }
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