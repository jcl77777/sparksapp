import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: InspirationViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showTagManager: Bool = false
    @State private var showAbout: Bool = false
    @State private var showNotification: Bool = false

    var body: some View {
        NavigationView {
            List {
                Button(action: { showNotification = true }) {
                    Label(NSLocalizedString("settings_notification", comment: "通知設定"), systemImage: "bell")
                }
                .sheet(isPresented: $showNotification) {
                    NotificationSettingsView()
                        .environmentObject(notificationManager)
                }
                Button(action: { showTagManager = true }) {
                    Label(NSLocalizedString("settings_tag_manager", comment: "標籤管理"), systemImage: "tag")
                }
                .sheet(isPresented: $showTagManager) {
                    TagManagerView()
                        .environmentObject(viewModel)
                }
                Button(action: { showAbout = true }) {
                    Label(NSLocalizedString("settings_about", comment: "關於頁面"), systemImage: "info.circle")
                }
                .sheet(isPresented: $showAbout) {
                    AboutView()
                }
            }
            .navigationTitle(NSLocalizedString("settings_title", comment: "設定"))
        }
    }
}

// 標籤管理子頁面
struct TagManagerView: View {
    @EnvironmentObject var viewModel: InspirationViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var newTagName: String = ""
    @State private var editingTag: Tag?
    @State private var editingTagName: String = ""
    @State private var showEditSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var tagToDelete: Tag?
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("tag_manager_section_title", comment: "標籤管理"))) {
                    HStack {
                        TextField(NSLocalizedString("tag_manager_new_tag_placeholder", comment: "新增標籤名稱"), text: $newTagName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isTextFieldFocused)
                        Button(action: addTag) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    if viewModel.availableTags.isEmpty {
                        Text(NSLocalizedString("tag_manager_no_tag", comment: "目前沒有標籤"))
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.availableTags, id: \.objectID) { tag in
                            HStack {
                                Text(tag.name ?? "")
                                Spacer()
                                Button(action: {
                                    editingTag = tag
                                    editingTagName = tag.name ?? ""
                                    showEditSheet = true
                                }) {
                                    Image(systemName: "pencil")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                Button(action: {
                                    tagToDelete = tag
                                    showDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("tag_manager_section_title", comment: "標籤管理"))
            .navigationBarItems(leading: Button(NSLocalizedString("common_close", comment: "關閉")) {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTextFieldFocused = true
                }
            }
            .sheet(isPresented: $showEditSheet) {
                NavigationView {
                    Form {
                        Section(header: Text(NSLocalizedString("tag_manager_edit_section", comment: "編輯標籤"))) {
                            TextField(NSLocalizedString("tag_manager_edit_placeholder", comment: "標籤名稱"), text: $editingTagName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .navigationBarItems(leading: Button(NSLocalizedString("common_cancel", comment: "取消")) {
                        showEditSheet = false
                    }, trailing: Button(NSLocalizedString("common_save", comment: "儲存")) {
                        if let tag = editingTag {
                            updateTag(tag: tag, newName: editingTagName)
                        }
                        showEditSheet = false
                    }.disabled(editingTagName.trimmingCharacters(in: .whitespaces).isEmpty))
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(title: Text(NSLocalizedString("tag_manager_delete_confirm_title", comment: "確定要刪除這個標籤嗎？")), message: Text(tagToDelete?.name ?? ""), primaryButton: .destructive(Text(NSLocalizedString("common_delete", comment: "刪除"))) {
                    if let tag = tagToDelete {
                        deleteTag(tag: tag)
                    }
                }, secondaryButton: .cancel())
            }
        }
    }
    private func addTag() {
        viewModel.addTag(name: newTagName)
        newTagName = ""
    }
    private func updateTag(tag: Tag, newName: String) {
        viewModel.updateTag(tag: tag, newName: newName)
    }
    private func deleteTag(tag: Tag) {
        viewModel.deleteTag(tag: tag)
    }
}

// 通知設定頁面
struct NotificationSettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("unorganizedReminderSetting") private var unorganizedReminderSettingData: Data = Data()
    @State private var setting: UnorganizedReminderSetting = UnorganizedReminderSetting()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("notification_unorganized_section_title", comment: "未整理靈感提醒"))) {
                    Toggle(NSLocalizedString("notification_unorganized_toggle", comment: "未整理提醒"), isOn: $setting.enabled)
                        .onChange(of: setting.enabled) { _, _ in saveAndSchedule() }
                    if setting.enabled {
                        Picker(NSLocalizedString("notification_unorganized_frequency", comment: "提醒頻率"), selection: $setting.frequency) {
                            ForEach(ReminderFrequency.allCases) { freq in
                                Text(freq.displayName).tag(freq)
                            }
                        }
                        .onChange(of: setting.frequency) { _, _ in saveAndSchedule() }
                        if setting.frequency == .weekly {
                            Picker(NSLocalizedString("notification_unorganized_weekday", comment: "提醒星期"), selection: Binding(get: { setting.weekday ?? 2 }, set: { setting.weekday = $0; saveAndSchedule() })) {
                                ForEach(1...7, id: \ .self) { i in
                                    Text(weekdayName(i)).tag(i)
                                }
                            }
                        }
                        if setting.frequency == .monthly {
                            Picker(NSLocalizedString("notification_unorganized_day", comment: "提醒日"), selection: Binding(get: { setting.day ?? 1 }, set: { setting.day = $0; saveAndSchedule() })) {
                                ForEach(1...31, id: \ .self) { d in
                                    Text(String(format: NSLocalizedString("notification_unorganized_day_format", comment: "每月%d日"), d)).tag(d)
                                }
                            }
                        }
                        DatePicker(NSLocalizedString("notification_unorganized_time", comment: "提醒時間"), selection: $setting.time, displayedComponents: .hourAndMinute)
                            .onChange(of: setting.time) { _, _ in saveAndSchedule() }
                        Text(NSLocalizedString("notification_unorganized_hint", comment: "提醒您整理未分類的靈感，保持創意流暢"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("notification_settings_title", comment: "通知設定"))
            .navigationBarItems(leading: Button(NSLocalizedString("common_close", comment: "關閉")) {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                if let loaded = try? JSONDecoder().decode(UnorganizedReminderSetting.self, from: unorganizedReminderSettingData), unorganizedReminderSettingData.count > 0 {
                    setting = loaded
                }
            }
        }
    }
    
    private func saveAndSchedule() {
        if let data = try? JSONEncoder().encode(setting) {
            unorganizedReminderSettingData = data
        }
        notificationManager.scheduleUnorganizedReminder(setting: setting)
    }
    
    private func weekdayName(_ i: Int) -> String {
        let names = ["週日", "週一", "週二", "週三", "週四", "週五", "週六"]
        return names[(i-1)%7]
    }
}

// 關於頁面（佔位）
struct AboutView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                Text("Sparks")
                    .font(.custom("HelveticaNeue-Light", size: 28))
                Text(NSLocalizedString("about_version_and_desc", comment: "版本 1.0.0\n\n記下讓你心動的瞬間，等你準備好出發。\n\n© 2025 NanNova Labs"))
                    .font(.custom("HelveticaNeue-Light", size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Button(action: {
                    let subject = NSLocalizedString("about_feedback_subject", comment: "Sparks App 意見回饋")
                    let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "mailto:feedback@nannova.com?subject=\(encodedSubject)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "envelope")
                        Text(NSLocalizedString("about_feedback", comment: "意見回饋"))
                    }
                    .font(.custom("HelveticaNeue-Light", size: 18))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle(NSLocalizedString("about_title", comment: "關於"))
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 