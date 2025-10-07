import SwiftUI
import CoreData

struct InspirationListView: View {
    @EnvironmentObject var viewModel: InspirationViewModel
    @EnvironmentObject var appState: AppState
    @State private var showingAddSheet = false
    @State private var selectedInspiration: Inspiration?
    @State private var selectedCategory: OrganizationCategory = .all
    @State private var searchText = ""
    @State private var viewMode: ViewMode = .list
    
    enum OrganizationCategory: String, CaseIterable {
        case all
        case organized
        case unorganized
        
        var localized: String {
            switch self {
            case .all:
                return NSLocalizedString("inspiration_status_all", comment: "全部")
            case .organized:
                return NSLocalizedString("inspiration_status_organized", comment: "已整理")
            case .unorganized:
                return NSLocalizedString("inspiration_status_unorganized", comment: "未整理")
            }
        }
    }
    
    enum ViewMode: String, CaseIterable {
        case list
        case gallery
        
        var icon: String {
            switch self {
            case .list:
                return "list.bullet"
            case .gallery:
                return "square.grid.2x2"
            }
        }
        
        var localized: String {
            switch self {
            case .list:
                return NSLocalizedString("inspiration_viewmode_list", comment: "列表")
            case .gallery:
                return NSLocalizedString("inspiration_viewmode_gallery", comment: "畫廊")
            }
        }
    }
    
    var filteredInspirations: [Inspiration] {
        var inspirations = viewModel.inspirations
        
        // 根據分類篩選
        switch selectedCategory {
        case .organized:
            inspirations = inspirations.filter { viewModel.isOrganized($0) }
        case .unorganized:
            inspirations = inspirations.filter { !viewModel.isOrganized($0) }
        case .all:
            break
        }
        
        // 根據搜尋文字篩選
        if !searchText.isEmpty {
            inspirations = inspirations.filter { inspiration in
                let title = inspiration.title ?? ""
                let content = inspiration.content ?? ""
                let url = inspiration.url ?? ""
                return title.localizedCaseInsensitiveContains(searchText) ||
                       content.localizedCaseInsensitiveContains(searchText) ||
                       url.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return inspirations
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Gradient Header
            GradientHeader(
                title: "💡 " + NSLocalizedString("inspiration_collection", comment: "收藏"),
                gradientColors: AppDesign.Colors.purpleGradient
            ) {
                // Category Filter + View Mode Toggle
                HStack {
                    // Category Segmented Control
                    HStack(spacing: 6) {
                        ForEach(OrganizationCategory.allCases, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(categoryEmoji(category) + " " + category.localized)
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(selectedCategory == category ? .white : .white.opacity(0.7))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(selectedCategory == category ? Color.white.opacity(0.3) : Color.clear)
                                    .cornerRadius(AppDesign.Borders.radiusButton)
                            }
                        }
                    }

                    Spacer()

                    // View Mode Toggle
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewMode = viewMode == .list ? .gallery : .list
                        }
                    }) {
                        Image(systemName: viewMode == .list ? "square.grid.2x2" : "list.bullet")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                }
            }

            // 搜尋欄位
            SearchBar(text: $searchText, placeholder: NSLocalizedString("inspiration_search_placeholder", comment: "搜尋靈感"))
                .padding(.horizontal)
                .padding(.top, 8)
                
            // 靈感列表
            if filteredInspirations.isEmpty {
                VStack(spacing: 16) {
                    Text("💡")
                        .font(.system(size: 60))
                    Text(emptyStateMessage)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                if viewMode == .list {
                    // List 檢視模式
                    ScrollView {
                        VStack(spacing: AppDesign.Spacing.small) {
                            ForEach(filteredInspirations, id: \.objectID) { inspiration in
                                PixelInspirationCard(inspiration: inspiration, viewModel: viewModel)
                                    .onTapGesture {
                                        selectedInspiration = inspiration
                                    }
                            }
                        }
                        .padding(AppDesign.Spacing.standard)
                    }
                } else {
                    // Gallery 檢視模式
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: AppDesign.Spacing.small),
                            GridItem(.flexible(), spacing: AppDesign.Spacing.small)
                        ], spacing: AppDesign.Spacing.small) {
                            ForEach(filteredInspirations, id: \.objectID) { inspiration in
                                PixelInspirationGalleryCard(inspiration: inspiration, viewModel: viewModel)
                                    .onTapGesture {
                                        selectedInspiration = inspiration
                                    }
                            }
                        }
                        .padding(AppDesign.Spacing.standard)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddSheet) {
            AddInspirationView()
        }
        .sheet(item: $selectedInspiration) { inspiration in
            EditInspirationView(inspiration: inspiration)
        }
        .onAppear {
            if appState.shouldShowUnorganizedOnAppear {
                selectedCategory = .unorganized
                appState.shouldShowUnorganizedOnAppear = false
            }
        }
    }

    private func categoryEmoji(_ category: OrganizationCategory) -> String {
        switch category {
        case .all: return "📚"
        case .organized: return "✓"
        case .unorganized: return "⋯"
        }
    }
    
    private var emptyStateMessage: String {
        if !searchText.isEmpty {
            return String(format: NSLocalizedString("inspiration_empty_search", comment: "沒有找到符合"), searchText)
        }
        
        switch selectedCategory {
        case .organized:
            return NSLocalizedString("inspiration_empty_organized", comment: "還沒有已整理的靈感\n為靈感建立任務即可整理")
        case .unorganized:
            return NSLocalizedString("inspiration_empty_unorganized", comment: "所有靈感都已整理完成！\n（都有關聯的任務）")
        case .all:
            return NSLocalizedString("inspiration_empty_all", comment: "還沒有任何靈感\n點擊「+」開始新增")
        }
    }
}

// 搜尋欄位元件
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// 靈感卡片元件 - Pixel Art Style
struct PixelInspirationCard: View {
    let inspiration: Inspiration
    let viewModel: InspirationViewModel

    var body: some View {
        PixelCard(borderColor: typeColor) {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                HStack {
                    // 類型圖示 (emoji)
                    Text(typeEmoji)
                        .font(.system(size: 32))

                    VStack(alignment: .leading, spacing: 4) {
                        // 標題
                        Text(inspiration.title ?? "Untitled")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                            .lineLimit(2)

                        // 建立時間
                        if let createdAt = inspiration.createdAt {
                            Text(formatDate(createdAt))
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    // 整理狀態指示器
                    if viewModel.isOrganized(inspiration) {
                        VStack(spacing: 4) {
                            Text("✓")
                                .font(.system(size: 20))
                                .foregroundColor(AppDesign.Colors.green)
                            Text("\(viewModel.getTaskCount(for: inspiration))")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.green)
                        }
                    }
                }
            
                // 根據類型顯示不同內容
                if inspiration.type == 1 { // 圖片類型
                    if let imageData = inspiration.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                            .cornerRadius(AppDesign.Borders.radiusCard)
                    }
                } else if inspiration.type == 2 { // 網址類型
                    if let url = inspiration.url, !url.isEmpty {
                        HStack {
                            Text("🔗")
                                .font(.system(size: 12))
                            Text(url)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.blue)
                                .lineLimit(1)
                        }
                    }
                } else if inspiration.type == 3 { // 影片類型
                    if let url = inspiration.url, !url.isEmpty {
                        HStack {
                            Text("🎬")
                                .font(.system(size: 12))
                            Text(url)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.orange)
                                .lineLimit(1)
                        }
                    }
                }

                // 內容預覽
                if let content = inspiration.content, !content.isEmpty {
                    Text(content)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // 標籤
                let tagNames = viewModel.getTagNames(for: inspiration)
                if !tagNames.isEmpty {
                    TagList(tags: tagNames)
                }

                // 顯示任務數量
                let taskCount = viewModel.getTaskCount(for: inspiration)
                if taskCount > 0 {
                    HStack(spacing: 4) {
                        Text("✓")
                            .font(.system(size: 12))
                            .foregroundColor(AppDesign.Colors.green)
                        Text("\(taskCount) " + NSLocalizedString("inspiration_task_count", comment: "個任務"))
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.green)
                    }
                }
            }
            .padding(AppDesign.Spacing.standard)
            .background(typeColor.opacity(0.05))
        }
    }
    
    private var typeEmoji: String {
        switch inspiration.type {
        case 0: return "📝"
        case 1: return "🖼️"
        case 2: return "🔗"
        case 3: return "🎬"
        default: return "💡"
        }
    }

    private var typeColor: Color {
        switch inspiration.type {
        case 0: return AppDesign.Colors.orange
        case 1: return AppDesign.Colors.purple
        case 2: return AppDesign.Colors.blue
        case 3: return AppDesign.Colors.orange
        default: return AppDesign.Colors.gray
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Gallery 檢視模式的卡片元件 - Pixel Art Style
struct PixelInspirationGalleryCard: View {
    let inspiration: Inspiration
    let viewModel: InspirationViewModel
    
    var body: some View {
        PixelCard(borderColor: typeColor) {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                // 類型圖示和標題
                HStack {
                    Text(typeEmoji)
                        .font(.system(size: 24))

                    Spacer()

                    // 整理狀態指示器
                    if viewModel.isOrganized(inspiration) {
                        Text("✓")
                            .font(.system(size: 16))
                            .foregroundColor(AppDesign.Colors.green)
                    }
                }

                // 標題
                Text(inspiration.title ?? "Untitled")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // 建立時間
                if let createdAt = inspiration.createdAt {
                    Text(formatDate(createdAt))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                // 圖片預覽（如果有）
                if inspiration.type == 1, let imageData = inspiration.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 80)
                        .clipped()
                        .cornerRadius(AppDesign.Borders.radiusCard)
                }

                // 內容預覽
                if let content = inspiration.content, !content.isEmpty {
                    Text(content)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // 標籤（最多顯示2個）
                let tagNames = viewModel.getTagNames(for: inspiration)
                if !tagNames.isEmpty {
                    HStack {
                        ForEach(Array(tagNames.prefix(2)), id: \.self) { tagName in
                            Text("#\(tagName)")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(AppDesign.Colors.tagBackground)
                                .foregroundColor(.black)
                                .cornerRadius(4)
                        }

                        if tagNames.count > 2 {
                            Text("+\(tagNames.count - 2)")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // 任務數量
                let taskCount = viewModel.getTaskCount(for: inspiration)
                if taskCount > 0 {
                    HStack(spacing: 2) {
                        Text("✓")
                            .font(.system(size: 10))
                            .foregroundColor(AppDesign.Colors.green)
                        Text("\(taskCount)")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.green)
                    }
                }
            }
            .padding(AppDesign.Spacing.small)
            .background(typeColor.opacity(0.05))
        }
    }

    private var typeEmoji: String {
        switch inspiration.type {
        case 0: return "📝"
        case 1: return "🖼️"
        case 2: return "🔗"
        case 3: return "🎬"
        default: return "💡"
        }
    }

    private var typeColor: Color {
        switch inspiration.type {
        case 0: return AppDesign.Colors.orange
        case 1: return AppDesign.Colors.purple
        case 2: return AppDesign.Colors.blue
        case 3: return AppDesign.Colors.orange
        default: return AppDesign.Colors.gray
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct InspirationListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        InspirationListView()
            .environmentObject(InspirationViewModel(context: context))
    }
} 