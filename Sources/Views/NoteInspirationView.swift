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
                            .font(.custom("HelveticaNeue-Light", size: 28))
                        Text("筆記已成功儲存到收藏")
                            .font(.custom("HelveticaNeue-Light", size: 15))
                            .foregroundColor(.secondary)
                    }
                    VStack(spacing: 16) {
                        Button(action: {
                            showAddTaskSheet = true
                            // 不再只設 appState.addTaskDefaultTitle
                            // 直接觸發 sheet，AddTaskView 會自動帶入 savedInspiration
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
                        if viewModel.availableTags.isEmpty {
                            Text("無可用標籤，請至設定頁新增")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            // 多選現有標籤
                            ForEach(viewModel.availableTags, id: \.objectID) { tag in
                                MultipleSelectionRow(title: tag.name ?? "", isSelected: selectedTags.contains(tag.name ?? "")) {
                                    let name = tag.name ?? ""
                                    if selectedTags.contains(name) {
                                        selectedTags.remove(name)
                                    } else {
                                        selectedTags.insert(name)
                                    }
                                }
                            }
                        }
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
        // 呼叫 ViewModel 儲存筆記，包含所選標籤
        let newInspiration = viewModel.addInspiration(title: title, content: content, type: 0, tagNames: Array(selectedTags))
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