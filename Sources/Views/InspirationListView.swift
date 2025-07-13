import SwiftUI
import CoreData

struct InspirationListView: View {
    @EnvironmentObject var viewModel: InspirationViewModel
    @State private var showingAddSheet = false
    @State private var selectedInspiration: Inspiration?
    @State private var selectedCategory: OrganizationCategory = .all
    @State private var searchText = ""
    @State private var viewMode: ViewMode = .list
    
    enum OrganizationCategory: String, CaseIterable {
        case all = "全部"
        case organized = "已整理"
        case unorganized = "未整理"
    }
    
    enum ViewMode: String, CaseIterable {
        case list = "列表"
        case gallery = "畫廊"
        
        var icon: String {
            switch self {
            case .list:
                return "list.bullet"
            case .gallery:
                return "square.grid.2x2"
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
        NavigationView {
            VStack(spacing: 0) {
                // 搜尋欄位
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // 分類切換
                Picker("分類", selection: $selectedCategory) {
                    ForEach(OrganizationCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // 靈感列表
                if filteredInspirations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(emptyStateMessage)
                            .font(.custom("HelveticaNeue-Light", size: 17))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    if viewMode == .list {
                        // List 檢視模式
                        List {
                            ForEach(filteredInspirations, id: \.objectID) { inspiration in
                                Button(action: {
                                    selectedInspiration = inspiration
                                }) {
                                    InspirationCardView(inspiration: inspiration, viewModel: viewModel)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .onDelete { indexSet in
                                indexSet.map { filteredInspirations[$0] }.forEach(viewModel.deleteInspiration)
                            }
                        }
                        .listStyle(PlainListStyle())
                    } else {
                        // Gallery 檢視模式
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(filteredInspirations, id: \.objectID) { inspiration in
                                    Button(action: {
                                        selectedInspiration = inspiration
                                    }) {
                                        InspirationGalleryCardView(inspiration: inspiration, viewModel: viewModel)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Collection")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // 檢視模式切換按鈕
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewMode = viewMode == .list ? .gallery : .list
                            }
                        }) {
                            Image(systemName: viewMode == .list ? "square.grid.2x2" : "list.bullet")
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: { showingAddSheet = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddInspirationView()
            }
            .sheet(item: $selectedInspiration) { inspiration in
                EditInspirationView(inspiration: inspiration)
            }
        }
    }
    
    private var emptyStateMessage: String {
        if !searchText.isEmpty {
            return "沒有找到符合「\(searchText)」的靈感"
        }
        
        switch selectedCategory {
        case .organized:
            return "還沒有已整理的靈感\n為靈感建立任務即可整理"
        case .unorganized:
            return "所有靈感都已整理完成！\n（都有關聯的任務）"
        case .all:
            return "還沒有任何靈感\n點擊「+」開始新增"
        }
    }
}

// 搜尋欄位元件
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("搜尋靈感...", text: $text)
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

// 靈感卡片元件
struct InspirationCardView: View {
    let inspiration: Inspiration
    let viewModel: InspirationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // 類型圖示
                Image(systemName: typeIcon)
                    .foregroundColor(typeColor)
                    .font(.system(size: 22))
                
                VStack(alignment: .leading, spacing: 4) {
                    // 標題
                    Text(inspiration.title ?? "Untitled")
                        .font(.custom("HelveticaNeue-Light", size: 17))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // 建立時間
                    if let createdAt = inspiration.createdAt {
                        Text(formatDate(createdAt))
                            .font(.custom("HelveticaNeue-Light", size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 整理狀態指示器（基於任務關聯）
                if viewModel.isOrganized(inspiration) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 12))
                        Text("\(viewModel.getTaskCount(for: inspiration))")
                            .font(.custom("HelveticaNeue-Light", size: 10))
                            .foregroundColor(.green)
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
                        .cornerRadius(8)
                }
            } else if inspiration.type == 2 { // 網址類型
                if let url = inspiration.url, !url.isEmpty {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.blue)
                            .font(.system(size: 12))
                        Text(url)
                            .font(.custom("HelveticaNeue-Light", size: 12))
                            .foregroundColor(.blue)
                            .lineLimit(1)
                    }
                }
            } else if inspiration.type == 3 { // 影片類型
                if let url = inspiration.url, !url.isEmpty {
                    HStack {
                        Image(systemName: "video")
                            .foregroundColor(.purple)
                            .font(.system(size: 12))
                        Text(url)
                            .font(.custom("HelveticaNeue-Light", size: 12))
                            .foregroundColor(.purple)
                            .lineLimit(1)
                    }
                }
            }
            
            // 內容預覽
            if let content = inspiration.content, !content.isEmpty {
                Text(content)
                    .font(.custom("HelveticaNeue-Light", size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // 標籤
            let tagNames = viewModel.getTagNames(for: inspiration)
            if !tagNames.isEmpty {
                HStack {
                    ForEach(tagNames, id: \.self) { tagName in
                        Text(tagName)
                            .font(.custom("HelveticaNeue-Light", size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
            }
            
            // 顯示任務數量（簡化顯示）
            let taskCount = viewModel.getTaskCount(for: inspiration)
            if taskCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 10))
                    Text("\(taskCount) 個任務")
                        .font(.custom("HelveticaNeue-Light", size: 10))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var typeIcon: String {
        switch inspiration.type {
        case 0: return "doc.text"
        case 1: return "photo"
        case 2: return "link"
        case 3: return "video"
        default: return "lightbulb"
        }
    }
    
    private var typeColor: Color {
        switch inspiration.type {
        case 0: return .blue
        case 1: return .green
        case 2: return .orange
        case 3: return .purple
        default: return .gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
        case 0: return .gray
        case 1: return .blue
        case 2: return .green
        default: return .gray
        }
    }
    private func taskStatusName(_ status: Int16) -> String {
        switch status {
        case 0: return "待處理"
        case 1: return "進行中"
        case 2: return "已完成"
        default: return "未知"
        }
    }
}

// Gallery 檢視模式的卡片元件
struct InspirationGalleryCardView: View {
    let inspiration: Inspiration
    let viewModel: InspirationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 主要內容區域
            VStack(alignment: .leading, spacing: 6) {
                // 類型圖示和標題
                HStack {
                    Image(systemName: typeIcon)
                        .foregroundColor(typeColor)
                        .font(.system(size: 16))
                    
                    Spacer()
                    
                    // 整理狀態指示器
                    if viewModel.isOrganized(inspiration) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 12))
                    }
                }
                
                // 標題
                Text(inspiration.title ?? "Untitled")
                    .font(.custom("HelveticaNeue-Light", size: 14))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // 建立時間
                if let createdAt = inspiration.createdAt {
                    Text(formatDate(createdAt))
                        .font(.custom("HelveticaNeue-Light", size: 10))
                        .foregroundColor(.secondary)
                }
            }
            
            // 圖片預覽（如果有）
            if inspiration.type == 1, let imageData = inspiration.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 80)
                    .clipped()
                    .cornerRadius(6)
            }
            
            // 內容預覽
            if let content = inspiration.content, !content.isEmpty {
                Text(content)
                    .font(.custom("HelveticaNeue-Light", size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // 標籤
            let tagNames = viewModel.getTagNames(for: inspiration)
            if !tagNames.isEmpty {
                HStack {
                    ForEach(Array(tagNames.prefix(2)), id: \.self) { tagName in
                        Text(tagName)
                            .font(.custom("HelveticaNeue-Light", size: 8))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                    
                    if tagNames.count > 2 {
                        Text("+\(tagNames.count - 2)")
                            .font(.custom("HelveticaNeue-Light", size: 8))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // 任務數量
            let taskCount = viewModel.getTaskCount(for: inspiration)
            if taskCount > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 8))
                    Text("\(taskCount)")
                        .font(.custom("HelveticaNeue-Light", size: 8))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var typeIcon: String {
        switch inspiration.type {
        case 0: return "doc.text"
        case 1: return "photo"
        case 2: return "link"
        case 3: return "video"
        default: return "lightbulb"
        }
    }
    
    private var typeColor: Color {
        switch inspiration.type {
        case 0: return .blue
        case 1: return .green
        case 2: return .orange
        case 3: return .purple
        default: return .gray
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