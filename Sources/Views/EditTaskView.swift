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
                Section(header: Text("任務標題")) {
                    TextField("輸入任務標題", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("任務描述（可選）")) {
                    TextEditor(text: $details)
                        .frame(minHeight: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                Section(header: Text("任務狀態")) {
                    Picker("狀態", selection: $status) {
                        ForEach(TaskStatus.allCases, id: \.self) { taskStatus in
                            HStack {
                                Image(systemName: taskStatus.iconName)
                                    .foregroundColor(statusColor(for: taskStatus))
                                Text(taskStatus.name)
                            }
                            .tag(taskStatus)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // 任務提醒設定
                Section(header: Text("任務提醒")) {
                    Toggle("啟用提醒", isOn: $isReminderEnabled)
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
                                    Text("提醒時間：\(formatReminderDate(reminderDate))")
                                        .font(.system(size: 14))
                                        .foregroundColor(.primary)
                                } else {
                                    Text("尚未設定提醒時間")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Button("設定時間") {
                                showReminderPicker = true
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // 顯示與選擇關聯靈感
                Section(header: Text("關聯靈感")) {
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
                            let tagNames = (inspiration.tag as? Set<Tag>)?.compactMap { $0.name }.sorted() ?? []
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
                        Text("尚未選擇關聯靈感")
                            .font(.custom("HelveticaNeue-Light", size: 12))
                            .foregroundColor(.secondary)
                    }
                    Button("選擇靈感") {
                        showInspirationPicker = true
                    }
                }
            }
            .navigationTitle("編輯任務")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("儲存") {
                    saveTask()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            )
            .alert(isPresented: $isSaved) {
                Alert(title: Text("任務已更新"), dismissButton: .default(Text("完成")) {
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
        case 0: return "筆記"
        case 1: return "圖片"
        case 2: return "連結"
        case 3: return "影片"
        default: return "靈感"
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
            .navigationTitle("選擇靈感")
            .navigationBarItems(leading: Button("取消") {
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
                Text("選擇提醒時間")
                    .font(.headline)
                    .padding(.top)
                
                DatePicker("提醒時間", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
                
                VStack(spacing: 12) {
                    Button("設定提醒") {
                        reminderDate = selectedDate
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(.bordered)
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