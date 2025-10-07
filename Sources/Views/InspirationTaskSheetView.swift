import SwiftUI
import CoreData

struct InspirationTaskSheetView: View {
    let inspiration: Inspiration
    @ObservedObject var viewModel: InspirationViewModel
    @ObservedObject var taskViewModel: TaskViewModel
    var onComplete: () -> Void

    // 新任務欄位
    @State private var newTaskTitle: String = ""
    @State private var newTaskDetails: String = ""
    // 多選未連結任務
    @State private var selectedTaskIDs: Set<NSManagedObjectID> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Gradient Header
                GradientHeader(
                    title: "🔗 " + NSLocalizedString("inspirationtask_add_or_link_title", comment: "新增/連結任務"),
                    gradientColors: AppDesign.Colors.greenGradient
                )

                VStack(spacing: AppDesign.Spacing.standard) {
                    // 已連結任務
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("inspirationtask_linked_tasks", comment: "已連結任務"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        let linkedTasks = viewModel.getTasks(for: inspiration)

                        if linkedTasks.isEmpty {
                            PixelCard(borderColor: AppDesign.Colors.gray) {
                                Text(NSLocalizedString("inspirationtask_no_related_task", comment: "尚未有關聯任務"))
                                    .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                    .padding(AppDesign.Spacing.standard)
                            }
                        } else {
                            PixelCard(borderColor: AppDesign.Colors.green) {
                                VStack(spacing: AppDesign.Spacing.small) {
                                    ForEach(linkedTasks, id: \.objectID) { task in
                                        HStack(spacing: 8) {
                                            Text(taskStatusEmoji(task.status))
                                                .font(.system(size: 16))

                                            Text(task.title ?? NSLocalizedString("inspirationtask_unnamed_task", comment: "未命名任務"))
                                                .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                                .foregroundColor(AppDesign.Colors.textPrimary)

                                            Spacer()

                                            Text(taskStatusName(task.status))
                                                .font(.system(size: AppDesign.Typography.labelSize, weight: .bold, design: .monospaced))
                                                .foregroundColor(taskStatusColor(task.status))
                                        }
                                        .padding(.vertical, 4)

                                        if task != linkedTasks.last {
                                            Divider()
                                        }
                                    }
                                }
                                .padding(AppDesign.Spacing.standard)
                            }
                        }
                    }

                    // 新增任務
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("inspirationtask_add_task_section", comment: "新增任務"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        TextField(NSLocalizedString("inspirationtask_task_title_placeholder", comment: "任務標題"), text: $newTaskTitle)
                            .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                            .padding(AppDesign.Spacing.small)
                            .background(Color.white)
                            .cornerRadius(AppDesign.Borders.radiusCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                                    .stroke(AppDesign.Colors.borderPrimary, lineWidth: AppDesign.Borders.thin)
                            )

                        TextEditor(text: $newTaskDetails)
                            .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                            .frame(minHeight: 80)
                            .padding(AppDesign.Spacing.small)
                            .background(Color.white)
                            .cornerRadius(AppDesign.Borders.radiusCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                                    .stroke(AppDesign.Colors.borderPrimary, lineWidth: AppDesign.Borders.thin)
                            )
                    }

                    // 可連結既有任務
                    let availableTasks = taskViewModel.tasks.filter { $0.inspiration == nil }
                    if !availableTasks.isEmpty {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("inspirationtask_link_existing_section", comment: "可連結既有任務（可多選）"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            VStack(spacing: AppDesign.Spacing.small) {
                                ForEach(availableTasks, id: \.objectID) { task in
                                    MultipleSelectionRow(title: task.title ?? NSLocalizedString("inspirationtask_unnamed_task", comment: "未命名任務"), isSelected: selectedTaskIDs.contains(task.objectID)) {
                                        if selectedTaskIDs.contains(task.objectID) {
                                            selectedTaskIDs.remove(task.objectID)
                                        } else {
                                            selectedTaskIDs.insert(task.objectID)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 按鈕區域
                    VStack(spacing: AppDesign.Spacing.small) {
                        PixelButton(
                            "➕ " + NSLocalizedString("inspirationtask_add", comment: "新增"),
                            color: AppDesign.Colors.green
                        ) {
                            // 新增新任務
                            if !newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                                viewModel.addTask(title: newTaskTitle, details: newTaskDetails.isEmpty ? nil : newTaskDetails, inspiration: inspiration)
                            }
                            // 連結既有任務
                            var didLink = false
                            for id in selectedTaskIDs {
                                if let task = taskViewModel.tasks.first(where: { $0.objectID == id }) {
                                    task.inspiration = inspiration
                                    didLink = true
                                }
                            }
                            if didLink {
                                taskViewModel.saveContext()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                viewModel.fetchInspirations()
                                onComplete()
                            }
                        }
                        .disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty && selectedTaskIDs.isEmpty)
                        .opacity((newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty && selectedTaskIDs.isEmpty) ? 0.5 : 1.0)

                        PixelButton(
                            NSLocalizedString("inspirationtask_cancel", comment: "取消"),
                            style: .secondary,
                            color: AppDesign.Colors.gray
                        ) {
                            onComplete()
                        }
                    }
                    .padding(.top, AppDesign.Spacing.small)
                }
                .padding(AppDesign.Spacing.standard)
            }
        }
    }



    // 狀態輔助
    private func taskStatusEmoji(_ status: Int16) -> String {
        switch status {
        case 0: return "⚪"
        case 1: return "⏱️"
        case 2: return "✓"
        default: return "⚪"
        }
    }

    private func taskStatusIcon(_ status: Int16) -> String {
        switch status {
        case 0: return "circle"
        case 1: return "clock"
        case 2: return "checkmark.circle.fill"
        default: return "circle"
        }
    }
    private func taskStatusColor(_ status: Int16) -> Color {
        switch status {
        case 0: return AppDesign.Colors.gray
        case 1: return AppDesign.Colors.blue
        case 2: return AppDesign.Colors.green
        default: return AppDesign.Colors.gray
        }
    }
    private func taskStatusName(_ status: Int16) -> String {
        switch status {
        case 0: return NSLocalizedString("taskstatus_todo", comment: "待處理")
        case 1: return NSLocalizedString("taskstatus_doing", comment: "進行中")
        case 2: return NSLocalizedString("taskstatus_done", comment: "已完成")
        default: return NSLocalizedString("taskstatus_unknown", comment: "未知")
        }
    }
} 