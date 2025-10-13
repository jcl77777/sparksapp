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
        if showingSuccessView {
            ScrollView {
                VStack(spacing: 0) {
                    // Success Header
                    GradientHeader(
                        title: "✓ " + NSLocalizedString("video_success", comment: "儲存成功！"),
                        gradientColors: AppDesign.Colors.purpleGradient
                    )

                    VStack(spacing: AppDesign.Spacing.large) {
                        Text("✓")
                            .font(.system(size: 80, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.purple)

                        Text(NSLocalizedString("video_saved", comment: "影片已成功儲存到收藏"))
                            .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textSecondary)

                        VStack(spacing: AppDesign.Spacing.small) {
                            PixelButton(
                                "➕ " + NSLocalizedString("video_add_task", comment: "新增任務"),
                                color: AppDesign.Colors.green
                            ) {
                                showAddTaskSheet = true
                            }

                            PixelButton(
                                "✓ " + NSLocalizedString("video_done", comment: "完成"),
                                style: .secondary,
                                color: AppDesign.Colors.gray
                            ) {
                                onComplete(0) // 跳到 Collection 分頁
                            }
                        }
                    }
                    .padding(AppDesign.Spacing.standard)
                }
            }
            .sheet(isPresented: $showAddTaskSheet) {
                AddTaskView(inspiration: savedInspiration)
            }
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    // Gradient Header
                    GradientHeader(
                        title: "🎬 " + NSLocalizedString("add_video_title", comment: "新增影片"),
                        gradientColors: AppDesign.Colors.purpleGradient
                    )

                    VStack(spacing: AppDesign.Spacing.standard) {
                        // 影片連結
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("video_url_title", comment: "影片連結"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            HStack(spacing: AppDesign.Spacing.small) {
                                PixelTextField(
                                    text: $videoURL,
                                    placeholder: NSLocalizedString("video_url_placeholder", comment: "輸入影片連結"),
                                    icon: "🎬",
                                    keyboardType: .URL,
                                    autocapitalization: .never
                                )
                                .onChange(of: videoURL) { _, newValue in
                                    // 當URL變化時，自動抓取影片資訊
                                    if !newValue.isEmpty && isValidVideoURL(newValue) {
                                        fetchVideoInfo()
                                    }
                                }

                                Button(action: fetchVideoInfo) {
                                    Text("⬇️")
                                        .font(.system(size: 20))
                                }
                                .disabled(videoURL.isEmpty || isLoading)
                                .opacity(videoURL.isEmpty || isLoading ? 0.5 : 1.0)
                            }

                            if isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text(NSLocalizedString("video_loading", comment: "正在抓取影片資訊..."))
                                        .font(.system(size: AppDesign.Typography.labelSize, design: .monospaced))
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                }
                            }

                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: AppDesign.Typography.labelSize, design: .monospaced))
                                    .foregroundColor(.red)
                            }
                        }


                        // 影片預覽
                        if !videoTitle.isEmpty {
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                                Text(NSLocalizedString("video_preview", comment: "影片預覽"))
                                    .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppDesign.Colors.textPrimary)

                                PixelCard(borderColor: AppDesign.Colors.purple) {
                                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                                        HStack {
                                            Text("🎬")
                                                .font(.system(size: 20))
                                            Text(videoTitle)
                                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                                .foregroundColor(AppDesign.Colors.textPrimary)
                                                .lineLimit(2)
                                        }

                                        Text(videoURL)
                                            .font(.system(size: AppDesign.Typography.labelSize, design: .monospaced))
                                            .foregroundColor(AppDesign.Colors.textSecondary)
                                            .lineLimit(1)

                                        // 影片預覽圖示
                                        RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 120)
                                            .overlay(
                                                VStack(spacing: AppDesign.Spacing.small) {
                                                    Text("🎬")
                                                        .font(.system(size: 32))
                                                    Text(NSLocalizedString("video_preview", comment: "影片預覽"))
                                                        .font(.system(size: AppDesign.Typography.labelSize, design: .monospaced))
                                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                                }
                                            )
                                    }
                                    .padding(AppDesign.Spacing.standard)
                                }
                            }
                        }

                        // 標題
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("video_title", comment: "標題"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            PixelTextField(
                                text: $videoTitle,
                                placeholder: NSLocalizedString("video_title_placeholder", comment: "輸入標題"),
                                icon: "📝"
                            )
                        }

                        // 描述
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("video_description_optional", comment: "描述（可選）"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            PixelTextEditor(
                                text: $description,
                                placeholder: NSLocalizedString("video_description_optional", comment: "輸入描述"),
                                minHeight: 100,
                                icon: "📝"
                            )
                        }

                        // 標籤
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("video_tags_optional", comment: "標籤（可選）"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            if viewModel.availableTags.isEmpty {
                                Text(NSLocalizedString("video_no_tags", comment: "無可用標籤，請至設定頁新增"))
                                    .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                    .italic()
                            } else {
                                VStack(spacing: AppDesign.Spacing.small) {
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

                        // 按鈕區域
                        VStack(spacing: AppDesign.Spacing.small) {
                            PixelButton(
                                "💾 " + NSLocalizedString("video_save", comment: "儲存"),
                                color: AppDesign.Colors.purple
                            ) {
                                saveVideoInspiration()
                            }
                            .disabled(videoTitle.trimmingCharacters(in: .whitespaces).isEmpty || videoURL.isEmpty)
                            .opacity((videoTitle.trimmingCharacters(in: .whitespaces).isEmpty || videoURL.isEmpty) ? 0.5 : 1.0)

                            PixelButton(
                                NSLocalizedString("video_cancel", comment: "取消"),
                                style: .secondary,
                                color: AppDesign.Colors.gray
                            ) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .padding(.top, AppDesign.Spacing.small)
                    }
                    .padding(AppDesign.Spacing.standard)
                }
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
        if URL(string: videoURL) != nil {
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
        } else {
            errorMessage = "無效的影片連結格式"
        }
    }
    
    private func saveVideoInspiration() {
        let inspiration = Inspiration(context: viewModel.context)
        inspiration.id = UUID()
        inspiration.title = videoTitle.isEmpty ? "（未命名）" : videoTitle
        inspiration.content = description.isEmpty ? nil : description
        inspiration.url = videoURL.isEmpty ? "" : videoURL
        inspiration.type = 3 // 影片類型
        inspiration.createdAt = Date()
        inspiration.updatedAt = Date()
        
        // 設定標籤
        for tagName in selectedTags {
            if let tag = viewModel.availableTags.first(where: { $0.name == tagName }) {
                inspiration.addToTags(tag)
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