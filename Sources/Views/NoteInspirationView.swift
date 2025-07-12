import SwiftUI
import CoreData

struct NoteInspirationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: InspirationViewModel
    @EnvironmentObject var appState: AppState
    let onComplete: (Int) -> Void
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var showingSuccessView = false
    @State private var savedInspiration: Inspiration?
    @State private var showAddTaskSheet = false
    
    var body: some View {
        NavigationView {
            if showingSuccessView {
                VStack(spacing: 30) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    VStack(spacing: 8) {
                        Text("儲存成功！")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("筆記已成功儲存到收藏")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    VStack(spacing: 16) {
                        Button(action: {
                            appState.addTaskDefaultTitle = savedInspiration?.title ?? ""
                            onComplete(1) // 跳到 Tasks 分頁
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("新增任務")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        Button(action: {
                            onComplete(0) // 跳到 Collection 分頁
                        }) {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("完成")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .navigationBarHidden(true)
                .sheet(isPresented: $showAddTaskSheet) {
                    AddTaskView(inspiration: savedInspiration)
                }
            } else {
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
    }
    
    private func saveNote() {
        // 呼叫 ViewModel 儲存筆記，不包含標籤
        let newInspiration = viewModel.addInspiration(title: title, content: content, type: 0, tagNames: [])
        savedInspiration = newInspiration
        withAnimation(.easeInOut(duration: 0.3)) {
            showingSuccessView = true
        }
    }
}

struct NoteInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        Text("NoteInspirationView Preview")
            .environmentObject(InspirationViewModel(context: PersistenceController.preview.container.viewContext))
    }
} 