import SwiftUI
import CoreData

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: InspirationViewModel
    @State private var title: String
    @State private var details: String
    @State private var isSaved = false
    
    // 可選：帶入靈感 id 以建立關聯
    let inspiration: Inspiration?
    
    init(inspiration: Inspiration?, defaultTitle: String = "") {
        self.inspiration = inspiration
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
                
                // 顯示關聯的靈感資訊
                if let inspiration = inspiration {
                    Section(header: Text("關聯靈感")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(inspiration.title ?? "Untitled")
                                .font(.headline)
                            if let content = inspiration.content, !content.isEmpty {
                                Text(content)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("新增任務")
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
                Alert(title: Text("任務已儲存"), dismissButton: .default(Text("完成")) {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
    
    private func saveTask() {
        viewModel.addTask(title: title, details: details.isEmpty ? nil : details, inspiration: inspiration)
        isSaved = true
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(inspiration: nil)
    }
} 