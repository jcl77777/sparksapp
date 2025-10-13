import SwiftUI
import CoreData

struct EditInspirationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: InspirationViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    
    let inspiration: Inspiration
    
    @State private var title: String
    @State private var content: String
    @State private var url: String
    @State private var websiteTitle: String
    @State private var isURLLoading = false
    @State private var urlErrorMessage: String?
    @State private var showTaskSheet = false
    @State private var selectedTags: Set<String> = []
    
    init(inspiration: Inspiration) {
        self.inspiration = inspiration
        _title = State(initialValue: inspiration.title ?? "")
        _content = State(initialValue: inspiration.content ?? "")
        _url = State(initialValue: inspiration.url ?? "")
        _websiteTitle = State(initialValue: inspiration.title ?? "")
        let tagNames = (inspiration.tags as? Set<Tag>)?.compactMap { $0.name } ?? []
        _selectedTags = State(initialValue: Set(tagNames))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Gradient Header
                GradientHeader(
                    title: "✏️ " + NSLocalizedString("editspark_navigation_title", comment: "編輯靈感"),
                    gradientColors: AppDesign.Colors.purpleGradient
                )

                VStack(spacing: AppDesign.Spacing.standard) {
                    // 標題
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("editspark_title_section", comment: "標題"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        PixelTextField(
                            text: $title,
                            placeholder: NSLocalizedString("editspark_title_placeholder", comment: "輸入標題"),
                            icon: "✏️"
                        )
                    }

                    // 圖片類型
                    if inspiration.type == 1 {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("editspark_image_section", comment: "圖片"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            PixelCard(borderColor: AppDesign.Colors.green) {
                                if let imageData = inspiration.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 200)
                                        .cornerRadius(AppDesign.Borders.radiusCard)
                                        .padding(AppDesign.Spacing.standard)
                                } else {
                                    Text(NSLocalizedString("editspark_image_load_failed", comment: "圖片載入失敗"))
                                        .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                        .padding(AppDesign.Spacing.standard)
                                }
                            }
                        }
                    }

                    // 網址類型
                    if inspiration.type == 2 {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("editspark_url_section", comment: "網址"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            HStack(spacing: AppDesign.Spacing.small) {
                                PixelTextField(
                                    text: $url,
                                    placeholder: NSLocalizedString("editspark_url_placeholder", comment: "輸入網址"),
                                    icon: "🔗",
                                    keyboardType: .URL,
                                    autocapitalization: .never
                                )

                                Button(action: fetchWebsiteInfo) {
                                    Text("⬇️")
                                        .font(.system(size: 20))
                                }
                                .disabled(url.isEmpty || isURLLoading)
                                .opacity(url.isEmpty || isURLLoading ? 0.5 : 1.0)
                            }

                            if isURLLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text(NSLocalizedString("editspark_url_loading", comment: "正在抓取網站資訊..."))
                                        .font(.system(size: AppDesign.Typography.labelSize, design: .monospaced))
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                }
                            }

                            if let urlErrorMessage = urlErrorMessage {
                                Text(urlErrorMessage)
                                    .font(.system(size: AppDesign.Typography.labelSize, design: .monospaced))
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    // 影片類型
                    if inspiration.type == 3 {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("editspark_video_section", comment: "影片連結"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            PixelCard(borderColor: AppDesign.Colors.purple) {
                                HStack {
                                    Text("🎬")
                                        .font(.system(size: 20))
                                    Text(inspiration.url ?? "")
                                        .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                        .lineLimit(1)
                                }
                                .padding(AppDesign.Spacing.standard)
                            }
                        }
                    }

                    // 預覽
                    if (inspiration.type == 2 || inspiration.type == 3), !websiteTitle.isEmpty {
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("editspark_preview_section", comment: "預覽"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            PixelCard(borderColor: AppDesign.Colors.blue) {
                                VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                                    HStack {
                                        Text("🔗")
                                            .font(.system(size: 20))
                                        Text(websiteTitle)
                                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                            .foregroundColor(AppDesign.Colors.textPrimary)
                                            .lineLimit(2)
                                    }

                                    Text(url)
                                        .font(.system(size: AppDesign.Typography.labelSize, design: .monospaced))
                                        .foregroundColor(AppDesign.Colors.textSecondary)
                                        .lineLimit(1)
                                }
                                .padding(AppDesign.Spacing.standard)
                            }
                        }
                    }

                    // 內容
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("editspark_content_section", comment: "內容"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        PixelTextEditor(
                            text: $content,
                            placeholder: NSLocalizedString("editspark_content_section", comment: "內容"),
                            minHeight: 120,
                            icon: "📝"
                        )
                    }

                    // 標籤
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("editspark_tags_section", comment: "標籤（可選）"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        if viewModel.availableTags.isEmpty {
                            Text(NSLocalizedString("editspark_no_tags", comment: "無可用標籤，請至設定頁新增"))
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

                    // 關聯任務
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("editspark_related_tasks_section", comment: "關聯任務"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        let tasks = viewModel.getTasks(for: inspiration)

                        if tasks.isEmpty {
                            PixelCard(borderColor: AppDesign.Colors.gray) {
                                Text(NSLocalizedString("editspark_no_related_task", comment: "尚未有關聯任務"))
                                    .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                    .padding(AppDesign.Spacing.standard)
                            }
                        } else {
                            PixelCard(borderColor: AppDesign.Colors.green) {
                                VStack(spacing: AppDesign.Spacing.small) {
                                    ForEach(tasks, id: \.objectID) { task in
                                        HStack(spacing: 8) {
                                            Text(taskStatusEmoji(task.status))
                                                .font(.system(size: 16))

                                            Text(task.title ?? NSLocalizedString("editspark_unnamed_task", comment: "未命名任務"))
                                                .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                                .foregroundColor(AppDesign.Colors.textPrimary)

                                            Spacer()

                                            Text(taskStatusName(task.status))
                                                .font(.system(size: AppDesign.Typography.labelSize, weight: .bold, design: .monospaced))
                                                .foregroundColor(taskStatusColor(task.status))
                                        }
                                        .padding(.vertical, 4)

                                        if task != tasks.last {
                                            Divider()
                                        }
                                    }
                                }
                                .padding(AppDesign.Spacing.standard)
                            }
                        }

                        PixelButton(
                            "➕ " + NSLocalizedString("editspark_add_task", comment: "新增任務"),
                            style: .secondary,
                            color: AppDesign.Colors.green
                        ) {
                            showTaskSheet = true
                        }
                    }

                    // 按鈕區域
                    VStack(spacing: AppDesign.Spacing.small) {
                        PixelButton(
                            "💾 " + NSLocalizedString("editspark_save", comment: "儲存"),
                            color: AppDesign.Colors.purple
                        ) {
                            saveChanges()
                        }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(title.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)

                        PixelButton(
                            NSLocalizedString("editspark_cancel", comment: "取消"),
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
        .sheet(isPresented: $showTaskSheet, onDismiss: {
            viewModel.fetchInspirations()
        }) {
            InspirationTaskSheetView(inspiration: inspiration, viewModel: viewModel, taskViewModel: taskViewModel, onComplete: {
                showTaskSheet = false
            })
        }
    }
    
    private func fetchWebsiteInfo() {
        guard let fetchURL = URL(string: url) else {
            urlErrorMessage = "無效的網址格式"
            return
        }
        isURLLoading = true
        urlErrorMessage = nil
        let task = URLSession.shared.dataTask(with: fetchURL) { data, response, error in
            DispatchQueue.main.async {
                isURLLoading = false
                if let error = error {
                    urlErrorMessage = "無法連接到網站：\(error.localizedDescription)"
                    return
                }
                guard let data = data,
                      let htmlString = String(data: data, encoding: .utf8) else {
                    urlErrorMessage = "無法讀取網站內容"
                    return
                }
                if let titleRange = htmlString.range(of: "<title>"),
                   let titleEndRange = htmlString.range(of: "</title>") {
                    let titleStart = htmlString.index(titleRange.upperBound, offsetBy: 0)
                    let extractedTitle = String(htmlString[titleStart..<titleEndRange.lowerBound])
                    websiteTitle = extractedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    websiteTitle = fetchURL.host ?? url
                }
            }
        }
        task.resume()
    }
    
    private func saveChanges() {
        if inspiration.type == 2 {
            // 網址類型，更新網址與標題
            inspiration.title = websiteTitle.isEmpty ? title : websiteTitle
            inspiration.url = url
        } else if inspiration.type == 3 {
            // 影片類型，只更新標題（連結不變）
            inspiration.title = title
        } else {
            // 其他類型（包括圖片）
            inspiration.title = title
        }
        inspiration.content = content
        inspiration.updatedAt = Date()
        // 更新標籤
        viewModel.updateInspiration(inspiration, title: inspiration.title ?? "", content: content, type: inspiration.type, tagNames: Array(selectedTags))
        presentationMode.wrappedValue.dismiss()
    }
    
    private func taskStatusEmoji(_ status: Int16) -> String {
        switch status {
        case 0: return "⚪"
        case 1: return "⏱️"
        case 2: return "✓"
        default: return "⚪"
        }
    }

    private func taskStatusIcon(_ status: Int16) -> String {
        switch status {
        case 0: return "circle"
        case 1: return "clock"
        case 2: return "checkmark.circle.fill"
        default: return "circle"
        }
    }
    private func taskStatusColor(_ status: Int16) -> Color {
        switch status {
        case 0: return AppDesign.Colors.gray
        case 1: return AppDesign.Colors.blue
        case 2: return AppDesign.Colors.green
        default: return AppDesign.Colors.gray
        }
    }
    private func taskStatusName(_ status: Int16) -> String {
        switch status {
        case 0:
            return NSLocalizedString("taskstatus_todo", comment: "待處理")
        case 1:
            return NSLocalizedString("taskstatus_doing", comment: "進行中")
        case 2:
            return NSLocalizedString("taskstatus_done", comment: "已完成")
        default:
            return NSLocalizedString("taskstatus_unknown", comment: "未知")
        }
    }
}

struct EditInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        Text("EditInspirationView Preview")
            .environmentObject(InspirationViewModel(context: PersistenceController.preview.container.viewContext))
    }
} 
