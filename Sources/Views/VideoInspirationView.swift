import SwiftUI
import CoreData

struct VideoInspirationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: InspirationViewModel
    @EnvironmentObject var appState: AppState
    let onComplete: (Int) -> Void
    
    @State private var videoURL: String = ""
    @State private var videoTitle: String = ""
    @State private var videoThumbnail: String = ""
    @State private var description: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var isLoading = false
    @State private var showingSuccessView = false
    @State private var savedInspiration: Inspiration?
    @State private var showAddTaskSheet = false
    @State private var errorMessage: String?
    
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
                        Text("影片已成功儲存到收藏")
                            .font(.custom("HelveticaNeue-Light", size: 15))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            showAddTaskSheet = true
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
                    Section(header: Text("影片連結")) {
                        HStack {
                            TextField("輸入影片連結", text: $videoURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onChange(of: videoURL) { newValue in
                                    // 當URL變化時，自動抓取影片資訊
                                    if !newValue.isEmpty && isValidVideoURL(newValue) {
                                        fetchVideoInfo()
                                    }
                                }
                            
                            Button(action: fetchVideoInfo) {
                                Image(systemName: "arrow.down.circle")
                                    .foregroundColor(.blue)
                            }
                            .disabled(videoURL.isEmpty || isLoading)
                        }
                        .padding(.vertical, 4)
                        
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("正在抓取影片資訊...")
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
                    
                    if !videoTitle.isEmpty {
                        Section(header: Text("預覽")) {
                            VStack(alignment: .leading, spacing: 12) {
                                // 影片預覽卡片
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "video")
                                            .foregroundColor(.purple)
                                        Text(videoTitle)
                                            .font(.custom("HelveticaNeue-Light", size: 17))
                                            .lineLimit(2)
                                    }
                                    
                                    Text(videoURL)
                                        .font(.custom("HelveticaNeue-Light", size: 12))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    
                                    // 影片預覽圖示
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 120)
                                        .cornerRadius(8)
                                        .overlay(
                                            VStack(spacing: 8) {
                                                Image(systemName: "video.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundColor(.purple)
                                                Text("影片預覽")
                                                    .font(.custom("HelveticaNeue-Light", size: 12))
                                                    .foregroundColor(.secondary)
                                            }
                                        )
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    Section(header: Text("標題")) {
                        TextField("輸入標題", text: $videoTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical, 4)
                    }
                    
                    Section(header: Text("描述（可選）")) {
                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .padding(.vertical, 4)
                    }
                    
                    Section(header: Text("標籤（可選）")) {
                        if viewModel.availableTags.isEmpty {
                            Text("無可用標籤，請至設定頁新增")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
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
                .navigationTitle("新增影片")
                .navigationBarItems(
                    leading: Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("儲存") {
                        saveVideoInspiration()
                    }
                    .disabled(videoTitle.trimmingCharacters(in: .whitespaces).isEmpty || videoURL.isEmpty)
                )
            }
        }
    }
    
    private func isValidVideoURL(_ url: String) -> Bool {
        let videoDomains = [
            "youtube.com", "youtu.be", "www.youtube.com",
            "vimeo.com", "www.vimeo.com",
            "dailymotion.com", "www.dailymotion.com",
            "twitch.tv", "www.twitch.tv"
        ]
        
        return videoDomains.contains { domain in
            url.lowercased().contains(domain)
        }
    }
    
    private func fetchVideoInfo() {
        guard let fetchURL = URL(string: videoURL) else {
            errorMessage = "無效的影片連結格式"
            return
        }
        
        // 避免重複抓取
        if isLoading {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // 這裡可以實作影片資訊抓取邏輯
        // 目前先模擬抓取過程
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            
            // 模擬從不同平台抓取影片資訊
            if videoURL.contains("youtube.com") || videoURL.contains("youtu.be") {
                videoTitle = "YouTube 影片"
                videoThumbnail = ""
            } else if videoURL.contains("vimeo.com") {
                videoTitle = "Vimeo 影片"
                videoThumbnail = ""
            } else if videoURL.contains("twitch.tv") {
                videoTitle = "Twitch 影片"
                videoThumbnail = ""
            } else if videoURL.contains("dailymotion.com") {
                videoTitle = "Dailymotion 影片"
                videoThumbnail = ""
            } else {
                videoTitle = "影片連結"
                videoThumbnail = ""
            }
        }
    }
    
    private func saveVideoInspiration() {
        print("儲存前 title: \(videoTitle ?? "nil") url: \(videoURL ?? "nil")")
        let inspiration = Inspiration(context: viewModel.context)
        inspiration.id = UUID()
        inspiration.title = (videoTitle?.isEmpty == false ? videoTitle : "（未命名）") ?? "（未命名）"
        inspiration.content = description.isEmpty ? nil : description
        inspiration.url = (videoURL?.isEmpty == false ? videoURL : "") ?? ""
        inspiration.type = 3 // 影片類型
        inspiration.createdAt = Date()
        inspiration.updatedAt = Date()
        
        // 設定標籤
        for tagName in selectedTags {
            if let tag = viewModel.availableTags.first(where: { $0.name == tagName }) {
                inspiration.addToTag(tag)
            }
        }
        
        // 使用 ViewModel 的 saveContext 方法，確保資料同步
        viewModel.saveContext()
        savedInspiration = inspiration
        
        // 添加延遲來避免 List 渲染問題
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingSuccessView = true
        }
    }
}

struct VideoInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        VideoInspirationView(onComplete: { _ in })
            .environmentObject(InspirationViewModel(context: PersistenceController.preview.container.viewContext))
            .environmentObject(AppState.shared)
    }
} 