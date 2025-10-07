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
        if showingSuccessView {
            ScrollView {
                VStack(spacing: 0) {
                    // Success Header
                    GradientHeader(
                        title: "✓ " + NSLocalizedString("url_success", comment: "儲存成功！"),
                        gradientColors: AppDesign.Colors.orangeGradient
                    )

                    VStack(spacing: AppDesign.Spacing.large) {
                        Text("✓")
                            .font(.system(size: 80, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.orange)

                        Text(NSLocalizedString("url_saved", comment: "網址已成功儲存到收藏"))
                            .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textSecondary)

                        VStack(spacing: AppDesign.Spacing.small) {
                            PixelButton(
                                "✓ " + NSLocalizedString("url_done", comment: "完成"),
                                color: AppDesign.Colors.orange
                            ) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .padding(AppDesign.Spacing.standard)
                }
            }
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    // Gradient Header
                    GradientHeader(
                        title: "🔗 " + NSLocalizedString("add_url_title", comment: "新增網址"),
                        gradientColors: AppDesign.Colors.orangeGradient
                    )

                    VStack(spacing: AppDesign.Spacing.standard) {
                        // 網址輸入
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("url_title", comment: "網址"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            HStack(spacing: AppDesign.Spacing.small) {
                                TextField(NSLocalizedString("url_placeholder", comment: "輸入網址"), text: $urlString)
                                    .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                    .padding(AppDesign.Spacing.small)
                                    .background(Color.white)
                                    .cornerRadius(AppDesign.Borders.radiusCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                                            .stroke(AppDesign.Colors.borderPrimary, lineWidth: AppDesign.Borders.thin)
                                    )
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)

                                Button(action: fetchWebsiteInfo) {
                                    Text("⬇️")
                                        .font(.system(size: 20))
                                }
                                .disabled(urlString.isEmpty || isLoading)
                                .opacity(urlString.isEmpty || isLoading ? 0.5 : 1.0)
                            }

                            if isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text(NSLocalizedString("url_loading", comment: "正在抓取網站資訊..."))
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

                        // 預覽
                        if !websiteTitle.isEmpty {
                            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                                Text(NSLocalizedString("url_preview", comment: "預覽"))
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

                                        Text(urlString)
                                            .font(.system(size: AppDesign.Typography.labelSize, design: .monospaced))
                                            .foregroundColor(AppDesign.Colors.textSecondary)
                                            .lineLimit(1)
                                    }
                                    .padding(AppDesign.Spacing.standard)
                                }
                            }
                        }

                        // 描述
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("url_description_optional", comment: "描述（可選）"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            TextEditor(text: $description)
                                .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                .frame(minHeight: 100)
                                .padding(AppDesign.Spacing.small)
                                .background(Color.white)
                                .cornerRadius(AppDesign.Borders.radiusCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                                        .stroke(AppDesign.Colors.borderPrimary, lineWidth: AppDesign.Borders.thin)
                                )
                        }

                        // 標籤
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("url_tags_optional", comment: "標籤（可選）"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            if viewModel.availableTags.isEmpty {
                                Text(NSLocalizedString("url_no_tags", comment: "還沒有標籤，請先在設定中新增標籤"))
                                    .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                            } else {
                                VStack(spacing: AppDesign.Spacing.small) {
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

                        // 按鈕區域
                        VStack(spacing: AppDesign.Spacing.small) {
                            PixelButton(
                                "💾 " + NSLocalizedString("url_save", comment: "儲存"),
                                color: AppDesign.Colors.orange
                            ) {
                                saveURL()
                            }
                            .disabled(urlString.isEmpty || websiteTitle.isEmpty)
                            .opacity((urlString.isEmpty || websiteTitle.isEmpty) ? 0.5 : 1.0)

                            PixelButton(
                                NSLocalizedString("url_cancel", comment: "取消"),
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
                inspiration.addToTags(tag)
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