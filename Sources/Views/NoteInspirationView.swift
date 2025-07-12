import SwiftUI
import CoreData

struct NoteInspirationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: InspirationViewModel
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedTags: Set<String> = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("標題")) {
                    TextField("輸入標題", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("內容")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                Section(header: Text("標籤（可選）")) {
                    Text("標籤功能開發中...")
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .navigationTitle("新增筆記")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("儲存") {
                    saveNote()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            )
        }
    }
    
    private func saveNote() {
        // 呼叫 ViewModel 儲存筆記，不包含標籤
        viewModel.addInspiration(title: title, content: content, tagNames: [])
        
        // 儲存成功後關閉畫面
        presentationMode.wrappedValue.dismiss()
    }
}

struct NoteInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        Text("NoteInspirationView Preview")
            .environmentObject(InspirationViewModel(context: PersistenceController.preview.container.viewContext))
    }
} 