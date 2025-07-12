import SwiftUI
import CoreData

struct EditInspirationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: InspirationViewModel
    
    let inspiration: Inspiration
    
    @State private var title: String
    @State private var content: String
    
    init(inspiration: Inspiration) {
        self.inspiration = inspiration
        _title = State(initialValue: inspiration.title ?? "")
        _content = State(initialValue: inspiration.content ?? "")
    }
    
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
            .navigationTitle("編輯靈感")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("儲存") {
                    saveChanges()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            )
        }
    }
    
    private func saveChanges() {
        // 更新靈感內容，不包含標籤
        viewModel.updateInspiration(inspiration, title: title, content: content, type: inspiration.type, tagNames: [])
        
        // 關閉畫面
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        Text("EditInspirationView Preview")
            .environmentObject(InspirationViewModel(context: PersistenceController.preview.container.viewContext))
    }
} 