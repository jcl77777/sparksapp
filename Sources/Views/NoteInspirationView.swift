import SwiftUI
import CoreData

struct NoteInspirationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: InspirationViewModel
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var showingSuccessView = false
    @State private var savedInspiration: Inspiration?
    
    var body: some View {
        NavigationView {
            if showingSuccessView {
                // 儲存成功後的選擇介面
                VStack(spacing: 30) {
                    // 成功圖示
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    // 成功訊息
                    VStack(spacing: 8) {
                        Text("儲存成功！")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("筆記已成功儲存到收藏")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // 選擇按鈕
                    VStack(spacing: 16) {
                        Button(action: {
                            // 跳轉到任務頁面
                            presentationMode.wrappedValue.dismiss()
                            // 這裡可以加入跳轉到任務頁面的邏輯
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
                            // 回到 Collection 頁面
                            presentationMode.wrappedValue.dismiss()
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
            } else {
                // 原有的輸入表單
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
        viewModel.addInspiration(title: title, content: content, tagNames: [])
        
        // 顯示成功介面
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