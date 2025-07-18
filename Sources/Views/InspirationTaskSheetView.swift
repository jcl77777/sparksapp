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
        NavigationView {
            Form {
                // 已連結任務
                Section(header: Text("已連結任務")) {
                    let linkedTasks = viewModel.getTasks(for: inspiration)
                    if linkedTasks.isEmpty {
                        Text("尚未有關聯任務")
                            .font(.custom("HelveticaNeue-Light", size: 12))
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(linkedTasks, id: \.objectID) { task in
                            HStack(spacing: 8) {
                                Image(systemName: taskStatusIcon(task.status))
                                    .foregroundColor(taskStatusColor(task.status))
                                Text(task.title ?? "未命名任務")
                                    .font(.custom("HelveticaNeue-Light", size: 12))
                                Text(taskStatusName(task.status))
                                    .font(.custom("HelveticaNeue-Light", size: 10))
                                    .foregroundColor(taskStatusColor(task.status))
                            }
                        }
                    }
                }
                // 新增任務
                Section(header: Text("新增任務")) {
                    TextField("任務標題", text: $newTaskTitle)
                    TextEditor(text: $newTaskDetails)
                        .frame(minHeight: 60)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray4), lineWidth: 1))
                }
                // 可連結既有任務
                let availableTasks = taskViewModel.tasks.filter { $0.inspiration == nil }
                if !availableTasks.isEmpty {
                    Section(header: Text("可連結既有任務（可多選）")) {
                        ForEach(availableTasks, id: \.objectID) { task in
                            MultipleSelectionRow(title: task.title ?? "未命名任務", isSelected: selectedTaskIDs.contains(task.objectID)) {
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
            .navigationTitle("新增/連結任務")
            .navigationBarItems(leading: Button("取消") { onComplete() }, trailing: Button("新增") {
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
            }.disabled(newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty && selectedTaskIDs.isEmpty))
        }
    }



    // 狀態輔助
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
        case 0: return .gray
        case 1: return .blue
        case 2: return .green
        default: return .gray
        }
    }
    private func taskStatusName(_ status: Int16) -> String {
        switch status {
        case 0: return "待處理"
        case 1: return "進行中"
        case 2: return "已完成"
        default: return "未知"
        }
    }
} 