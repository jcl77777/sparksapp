import SwiftUI
import CoreData

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
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
        // 這裡可以串接 CoreData 儲存 TaskItem
        // 目前僅顯示儲存成功
        isSaved = true
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(inspiration: nil)
    }
} 