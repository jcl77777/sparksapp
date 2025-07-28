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
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("task_title", comment: "任務標題"))) {
                    TextField(NSLocalizedString("task_title_placeholder", comment: "輸入任務標題"), text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Section(header: Text(NSLocalizedString("task_details_optional", comment: "任務描述（可選）"))) {
                    TextEditor(text: $details)
                        .frame(minHeight: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                // 顯示關聯的靈感資訊
                if let inspiration = inspiration {
                    Section(header: Text(NSLocalizedString("related_inspiration", comment: "關聯靈感"))) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(inspiration.title ?? NSLocalizedString("unnamed_task", comment: "未命名任務"))
                                .font(.custom("HelveticaNeue-Light", size: 17))
                            if let content = inspiration.content, !content.isEmpty {
                                Text(content)
                                    .font(.custom("HelveticaNeue-Light", size: 12))
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("add_task_title", comment: "新增任務"))
            .navigationBarItems(
                leading: Button(NSLocalizedString("common_cancel", comment: "取消")) {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(NSLocalizedString("common_save", comment: "儲存")) {
                    saveTask()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            )
            .alert(isPresented: $isSaved) {
                Alert(title: Text("任務已儲存"), dismissButton: .default(Text("完成")) {
                    presentationMode.wrappedValue.dismiss()
                })
            }
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