import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: InspirationViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var appState: AppState
    @State private var showTagManager: Bool = false
    @State private var showAbout: Bool = false
    @State private var showNotification: Bool = false
    @State private var showLanguageSettings: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Gradient Header
            GradientHeader(
                title: "⚙️ " + NSLocalizedString("settings_title", comment: "設定"),
                gradientColors: AppDesign.Colors.grayGradient
            )

            ScrollView {
                VStack(spacing: AppDesign.Spacing.standard) {
                    // 通知設定
                    SettingButton(
                        icon: "🔔",
                        title: NSLocalizedString("settings_notification", comment: "通知設定")
                    ) {
                        showNotification = true
                    }

                    // 標籤管理
                    SettingButton(
                        icon: "🏷️",
                        title: NSLocalizedString("settings_tag_manager", comment: "標籤管理")
                    ) {
                        showTagManager = true
                    }

                    // 語言設定
                    SettingButton(
                        icon: "🌐",
                        title: NSLocalizedString("settings_language", comment: "語言")
                    ) {
                        showLanguageSettings = true
                    }

                    // 關於
                    SettingButton(
                        icon: "ℹ️",
                        title: NSLocalizedString("settings_about", comment: "關於頁面")
                    ) {
                        showAbout = true
                    }
                }
                .padding(AppDesign.Spacing.standard)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showNotification) {
            NotificationSettingsView()
                .environmentObject(notificationManager)
        }
        .sheet(isPresented: $showTagManager) {
            TagManagerView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .sheet(isPresented: $showLanguageSettings) {
            LanguageSettingsView()
                .environmentObject(appState)
        }
    }
}

// 設定按鈕元件
struct SettingButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            PixelCard(borderColor: AppDesign.Colors.borderPrimary) {
                HStack(spacing: AppDesign.Spacing.small) {
                    Text(icon)
                        .font(.system(size: 32))

                    Text(title)
                        .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                        .foregroundColor(AppDesign.Colors.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
                .padding(AppDesign.Spacing.standard)
            }
        }
        .buttonStyle(PixelButtonStyle())
    }
}

// 編輯標籤子頁面
struct EditTagView: View {
    @EnvironmentObject var viewModel: InspirationViewModel
    @Environment(\.presentationMode) var presentationMode
    let tag: Tag
    @Binding var tagName: String
    let onSave: () -> Void
    let onCancel: () -> Void
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Gradient Header
            GradientHeader(
                title: "✏️ " + NSLocalizedString("tag_manager_edit_tag", comment: "編輯標籤"),
                gradientColors: AppDesign.Colors.blueGradient
            )

            VStack(spacing: AppDesign.Spacing.standard) {
                // 編輯標籤名稱
                VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                    Text(NSLocalizedString("tag_manager_new_tag_placeholder", comment: "標籤名稱"))
                        .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                        .foregroundColor(AppDesign.Colors.textPrimary)

                    PixelTextField(
                        text: $tagName,
                        placeholder: NSLocalizedString("tag_manager_new_tag_placeholder", comment: "輸入標籤名稱"),
                        icon: "�️"
                    )
                    .focused($isTextFieldFocused)
                }

                Spacer()

                // 按鈕區域
                VStack(spacing: AppDesign.Spacing.small) {
                    PixelButton(
                        "💾 " + NSLocalizedString("common_save", comment: "儲存"),
                        color: AppDesign.Colors.green
                    ) {
                        onSave()
                    }
                    .disabled(tagName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(tagName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)

                    PixelButton(
                        NSLocalizedString("common_cancel", comment: "取消"),
                        style: .secondary,
                        color: AppDesign.Colors.gray
                    ) {
                        onCancel()
                    }
                }
            }
            .padding(AppDesign.Spacing.standard)
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
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
        VStack(spacing: 0) {
            // Gradient Header
            GradientHeader(
                title: "🏷️ " + NSLocalizedString("tag_manager_section_title", comment: "標籤管理"),
                gradientColors: AppDesign.Colors.blueGradient
            )

            ScrollView {
                VStack(spacing: AppDesign.Spacing.standard) {
                    // 新增標籤區域
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("tag_manager_new_tag_placeholder", comment: "新增標籤名稱"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        HStack(spacing: AppDesign.Spacing.small) {
                            PixelTextField(
                                text: $newTagName,
                                placeholder: NSLocalizedString("tag_manager_new_tag_placeholder", comment: "新增標籤名稱"),
                                icon: "🏷️"
                            )
                            .focused($isTextFieldFocused)

                            PixelButton(
                                "➕",
                                color: AppDesign.Colors.green
                            ) {
                                addTag()
                            }
                            .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                            .opacity(newTagName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                            .frame(width: 60)
                        }
                    }

                    // 標籤列表
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("tag_manager_section_title", comment: "標籤管理"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        if viewModel.availableTags.isEmpty {
                            PixelCard(borderColor: AppDesign.Colors.gray) {
                                Text(NSLocalizedString("tag_manager_no_tag", comment: "目前沒有標籤"))
                                    .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                    .padding(AppDesign.Spacing.standard)
                            }
                        } else {
                            VStack(spacing: AppDesign.Spacing.small) {
                                ForEach(viewModel.availableTags, id: \.objectID) { tag in
                                    PixelCard(borderColor: AppDesign.Colors.purple) {
                                        HStack {
                                            Text("🏷️")
                                                .font(.system(size: 20))

                                            Text(tag.name ?? "")
                                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                                .foregroundColor(AppDesign.Colors.textPrimary)

                                            Spacer()

                                            Button(action: {
                                                editingTag = tag
                                                editingTagName = tag.name ?? ""
                                                showEditSheet = true
                                            }) {
                                                Text("✏️")
                                                    .font(.system(size: 18))
                                            }

                                            Button(action: {
                                                tagToDelete = tag
                                                showDeleteAlert = true
                                            }) {
                                                Text("🗑️")
                                                    .font(.system(size: 18))
                                            }
                                        }
                                        .padding(AppDesign.Spacing.standard)
                                    }
                                }
                            }
                        }
                    }

                    // 關閉按鈕
                    PixelButton(
                        NSLocalizedString("common_close", comment: "關閉"),
                        style: .secondary,
                        color: AppDesign.Colors.gray
                    ) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding(AppDesign.Spacing.standard)
            }
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let tag = editingTag {
                EditTagView(tag: tag, tagName: $editingTagName) {
                    updateTag(tag: tag, newName: editingTagName)
                    showEditSheet = false
                } onCancel: {
                    showEditSheet = false
                }
                .environmentObject(viewModel)
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text(NSLocalizedString("tag_manager_delete_confirm_title", comment: "確定要刪除這個標籤嗎？")),
                message: Text(tagToDelete?.name ?? ""),
                primaryButton: .destructive(Text(NSLocalizedString("common_delete", comment: "刪除"))) {
                    if let tag = tagToDelete {
                        deleteTag(tag: tag)
                    }
                },
                secondaryButton: .cancel()
            )
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
        VStack(spacing: 0) {
            // Gradient Header
            GradientHeader(
                title: "🔔 " + NSLocalizedString("notification_settings_title", comment: "通知設定"),
                gradientColors: AppDesign.Colors.blueGradient
            )

            ScrollView {
                VStack(spacing: AppDesign.Spacing.standard) {
                    // 啟用/停用提醒
                    PixelCard(borderColor: AppDesign.Colors.blue) {
                        HStack(spacing: AppDesign.Spacing.standard) {
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                                Text(NSLocalizedString("notification_unorganized_toggle", comment: "未整理提醒"))
                                    .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppDesign.Colors.textPrimary)

                                Text(NSLocalizedString("notification_unorganized_section_title", comment: "未整理靈感提醒"))
                                    .font(.system(size: AppDesign.Typography.captionSize, design: .monospaced))
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }

                            Spacer()

                            Toggle("", isOn: $setting.enabled)
                                .labelsHidden()
                                .onChange(of: setting.enabled) { _, _ in saveAndSchedule() }
                        }
                        .padding(AppDesign.Spacing.standard)
                    }

                    if setting.enabled {
                        // 提醒頻率
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("notification_unorganized_frequency", comment: "提醒頻率"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            PixelCard(borderColor: AppDesign.Colors.blue) {
                                Picker("", selection: $setting.frequency) {
                                    ForEach(ReminderFrequency.allCases) { freq in
                                        Text(freq.displayName).tag(freq)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .onChange(of: setting.frequency) { _, _ in saveAndSchedule() }
                                .padding(AppDesign.Spacing.standard)
                            }
                        }

                        // 週幾提醒
                        if setting.frequency == .weekly {
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                                Text(NSLocalizedString("notification_unorganized_weekday", comment: "提醒星期"))
                                    .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppDesign.Colors.textPrimary)

                                PixelCard(borderColor: AppDesign.Colors.blue) {
                                    Picker("", selection: Binding(get: { setting.weekday ?? 2 }, set: { setting.weekday = $0; saveAndSchedule() })) {
                                        ForEach(1...7, id: \.self) { i in
                                            Text(weekdayName(i)).tag(i)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 120)
                                    .padding(AppDesign.Spacing.small)
                                }
                            }
                        }

                        // 每月幾號提醒
                        if setting.frequency == .monthly {
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                                Text(NSLocalizedString("notification_unorganized_day", comment: "提醒日"))
                                    .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppDesign.Colors.textPrimary)

                                PixelCard(borderColor: AppDesign.Colors.blue) {
                                    Picker("", selection: Binding(get: { setting.day ?? 1 }, set: { setting.day = $0; saveAndSchedule() })) {
                                        ForEach(1...31, id: \.self) { d in
                                            Text("\(d)").tag(d)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 120)
                                    .padding(AppDesign.Spacing.small)
                                }
                            }
                        }

                        // 提醒時間
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("notification_unorganized_time", comment: "提醒時間"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            PixelCard(borderColor: AppDesign.Colors.blue) {
                                DatePicker("", selection: $setting.time, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .datePickerStyle(.wheel)
                                    .frame(maxWidth: .infinity)
                                    .onChange(of: setting.time) { _, _ in saveAndSchedule() }
                                    .padding(AppDesign.Spacing.standard)
                            }
                        }

                        // 提示文字
                        PixelCard(borderColor: AppDesign.Colors.gray) {
                            HStack {
                                Text("💡")
                                    .font(.system(size: 20))

                                Text(NSLocalizedString("notification_unorganized_hint", comment: "提醒您整理未分類的靈感，保持創意流暢"))
                                    .font(.system(size: AppDesign.Typography.captionSize, design: .monospaced))
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            }
                            .padding(AppDesign.Spacing.standard)
                        }
                    }

                    // 關閉按鈕
                    PixelButton(
                        NSLocalizedString("common_close", comment: "關閉"),
                        style: .secondary,
                        color: AppDesign.Colors.gray
                    ) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding(AppDesign.Spacing.standard)
            }
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            if let loaded = try? JSONDecoder().decode(UnorganizedReminderSetting.self, from: unorganizedReminderSettingData), unorganizedReminderSettingData.count > 0 {
                setting = loaded
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
        let keys = [
            "notification_weekday_sunday",
            "notification_weekday_monday",
            "notification_weekday_tuesday",
            "notification_weekday_wednesday",
            "notification_weekday_thursday",
            "notification_weekday_friday",
            "notification_weekday_saturday"
        ]
        let comments = ["週日", "週一", "週二", "週三", "週四", "週五", "週六"]
        let index = (i-1) % 7
        return NSLocalizedString(keys[index], comment: comments[index])
    }
}

// 關於頁面
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Gradient Header
                GradientHeader(
                    title: "ℹ️ " + NSLocalizedString("about_title", comment: "關於"),
                    gradientColors: AppDesign.Colors.greenGradient
                )

                VStack(spacing: AppDesign.Spacing.large) {
                    // App Icon & Name
                    VStack(spacing: AppDesign.Spacing.standard) {
                        Text("✨")
                            .font(.system(size: 80))

                        Text("Sparks")
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)
                    }

                    // Version & Description
                    PixelCard(borderColor: AppDesign.Colors.purple) {
                        VStack(spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("about_version_and_desc", comment: "版本 1.0.0\n\n記下讓你心動的瞬間，等你準備好出發。\n\n© 2025 NanNova Labs"))
                                .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(AppDesign.Spacing.large)
                    }

                    // Feedback Button
                    PixelButton(
                        "✉️ " + NSLocalizedString("about_feedback", comment: "意見回饋"),
                        color: AppDesign.Colors.blue
                    ) {
                        let subject = NSLocalizedString("about_feedback_subject", comment: "Sparks App 意見回饋")
                        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        if let url = URL(string: "mailto:feedback@nannova.com?subject=\(encodedSubject)") {
                            UIApplication.shared.open(url)
                        }
                    }

                    // Close Button
                    PixelButton(
                        NSLocalizedString("common_close", comment: "關閉"),
                        style: .secondary,
                        color: AppDesign.Colors.gray
                    ) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding(AppDesign.Spacing.standard)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 