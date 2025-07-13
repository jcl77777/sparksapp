import SwiftUI
import CoreData

struct URLInspirationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: InspirationViewModel
    
    @State private var urlString: String = ""
    @State private var websiteTitle: String = ""
    @State private var description: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var isLoading = false
    @State private var showingSuccessView = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            if showingSuccessView {
                // 儲存成功後的選擇介面
                VStack(spacing: 30) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    VStack(spacing: 8) {
                        Text("儲存成功！")
                            .font(.custom("HelveticaNeue-Light", size: 28))
                        
                        Text("網址已成功儲存到收藏")
                            .font(.custom("HelveticaNeue-Light", size: 15))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
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
                Form {
                    Section(header: Text("網址")) {
                        HStack {
                            TextField("輸入網址", text: $urlString)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            Button(action: fetchWebsiteInfo) {
                                Image(systemName: "arrow.down.circle")
                                    .foregroundColor(.blue)
                            }
                            .disabled(urlString.isEmpty || isLoading)
                        }
                        
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("正在抓取網站資訊...")
                                    .font(.custom("HelveticaNeue-Light", size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.custom("HelveticaNeue-Light", size: 12))
                                .foregroundColor(.red)
                        }
                    }
                    
                    if !websiteTitle.isEmpty {
                        Section(header: Text("預覽")) {
                            VStack(alignment: .leading, spacing: 12) {
                                // 預覽卡片
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "link")
                                            .foregroundColor(.blue)
                                        Text(websiteTitle)
                                            .font(.custom("HelveticaNeue-Light", size: 17))
                                            .lineLimit(2)
                                    }
                                    
                                    Text(urlString)
                                        .font(.custom("HelveticaNeue-Light", size: 12))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    Section(header: Text("描述（可選）")) {
                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    
                    Section(header: Text("標籤（可選）")) {
                        if viewModel.availableTags.isEmpty {
                            Text("還沒有標籤，請先在設定中新增標籤")
                                .font(.custom("HelveticaNeue-Light", size: 14))
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(viewModel.availableTags, id: \.objectID) { tag in
                                MultipleSelectionRow(
                                    title: tag.name ?? "",
                                    isSelected: selectedTags.contains(tag.name ?? ""),
                                    action: {
                                        if let tagName = tag.name {
                                            if selectedTags.contains(tagName) {
                                                selectedTags.remove(tagName)
                                            } else {
                                                selectedTags.insert(tagName)
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                .navigationTitle("新增網址")
                .navigationBarItems(
                    leading: Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("儲存") {
                        saveURL()
                    }
                    .disabled(urlString.isEmpty || websiteTitle.isEmpty)
                )
            }
        }
    }
    
    private func fetchWebsiteInfo() {
        guard let url = URL(string: urlString) else {
            errorMessage = "無效的網址格式"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "無法連接到網站：\(error.localizedDescription)"
                    return
                }
                
                guard let data = data,
                      let htmlString = String(data: data, encoding: .utf8) else {
                    errorMessage = "無法讀取網站內容"
                    return
                }
                
                // 簡單的 HTML 標題抓取
                if let titleRange = htmlString.range(of: "<title>"),
                   let titleEndRange = htmlString.range(of: "</title>") {
                    let titleStart = htmlString.index(titleRange.upperBound, offsetBy: 0)
                    let extractedTitle = String(htmlString[titleStart..<titleEndRange.lowerBound])
                    websiteTitle = extractedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    // 如果沒有找到 title 標籤，使用網址作為標題
                    websiteTitle = url.host ?? urlString
                }
            }
        }
        
        task.resume()
    }
    
    private func saveURL() {
        // 建立新的網址靈感
        let inspiration = Inspiration(context: viewModel.context)
        inspiration.id = UUID()
        inspiration.title = websiteTitle.isEmpty ? "（未命名）" : websiteTitle
        inspiration.content = description.isEmpty ? nil : description
        inspiration.url = urlString
        inspiration.type = 2 // 網址類型
        inspiration.createdAt = Date()
        inspiration.updatedAt = Date()
        
        // 設定標籤
        for tagName in selectedTags {
            if let tag = viewModel.availableTags.first(where: { $0.name == tagName }) {
                inspiration.addToTag(tag)
            }
        }
        
        // 使用 ViewModel 儲存
        viewModel.saveContext()
        
        // 顯示成功介面
        withAnimation(.easeInOut(duration: 0.3)) {
            showingSuccessView = true
        }
    }
}

struct URLInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        Text("URLInspirationView Preview")
            .environmentObject(InspirationViewModel(context: PersistenceController.preview.container.viewContext))
    }
} 