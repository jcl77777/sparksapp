import SwiftUI
import CoreData

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskViewModel: TaskViewModel
    @State private var title: String
    @State private var details: String
    @State private var isSaved = false

    // 可選：帶入靈感 id 以建立關聯
    let inspiration: Inspiration?
    var onSave: (() -> Void)? = nil

    init(inspiration: Inspiration?, defaultTitle: String = "", onSave: (() -> Void)? = nil) {
        self.inspiration = inspiration
        self.onSave = onSave
        if !defaultTitle.isEmpty {
            _title = State(initialValue: defaultTitle)
        } else {
            _title = State(initialValue: inspiration?.title ?? "")
        }
        _details = State(initialValue: inspiration?.content ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Gradient Header
                GradientHeader(
                    title: "➕ " + NSLocalizedString("add_task_title", comment: "新增任務"),
                    gradientColors: AppDesign.Colors.greenGradient
                )

                VStack(spacing: AppDesign.Spacing.standard) {
                    // 任務標題
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("task_title", comment: "任務標題"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        PixelTextField(
                            text: $title,
                            placeholder: NSLocalizedString("task_title_placeholder", comment: "輸入任務標題"),
                            icon: "✓"
                        )
                    }

                    // 任務描述
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("task_details_optional", comment: "任務描述（可選）"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        PixelTextEditor(
                            text: $details,
                            placeholder: NSLocalizedString("task_details_placeholder", comment: "輸入任務描述"),
                            minHeight: 100,
                            icon: "📝"
                        )
                    }

                    // 顯示關聯的靈感資訊
                    if let inspiration = inspiration {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("related_inspiration", comment: "關聯靈感"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            PixelCard(borderColor: AppDesign.Colors.purple) {
                                VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                                    Text(inspiration.title ?? NSLocalizedString("unnamed_task", comment: "未命名任務"))
                                        .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                        .foregroundColor(AppDesign.Colors.textPrimary)

                                    if let content = inspiration.content, !content.isEmpty {
                                        Text(content)
                                            .font(.system(size: AppDesign.Typography.labelSize, design: .monospaced))
                                            .foregroundColor(AppDesign.Colors.textSecondary)
                                            .lineLimit(2)
                                    }
                                }
                                .padding(AppDesign.Spacing.standard)
                            }
                        }
                    }

                    // 按鈕區域
                    VStack(spacing: AppDesign.Spacing.small) {
                        PixelButton(
                            "💾 " + NSLocalizedString("common_save", comment: "儲存"),
                            color: AppDesign.Colors.green
                        ) {
                            saveTask()
                        }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(title.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)

                        PixelButton(
                            NSLocalizedString("common_cancel", comment: "取消"),
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
            Alert(title: Text("任務已儲存"), dismissButton: .default(Text("完成")) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveTask() {
        taskViewModel.addTask(title: title, details: details.isEmpty ? nil : details, inspiration: inspiration)
        isSaved = true
        onSave?()
        // 立即 dismiss，避免用戶感覺不到刷新
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        AddTaskView(inspiration: nil)
            .environmentObject(TaskViewModel(context: context))
    }
} 