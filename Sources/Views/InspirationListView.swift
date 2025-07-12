import SwiftUI
import CoreData

struct InspirationListView: View {
    @EnvironmentObject var viewModel: InspirationViewModel
    @State private var showingAddSheet = false
    @State private var selectedInspiration: Inspiration?
    @State private var selectedCategory: OrganizationCategory = .all
    @State private var searchText = ""
    
    enum OrganizationCategory: String, CaseIterable {
        case all = "全部"
        case organized = "已整理"
        case unorganized = "未整理"
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
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
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
                }
            }
            .navigationTitle("Collection")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
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
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    // 標題
                    Text(inspiration.title ?? "Untitled")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // 建立時間
                    if let createdAt = inspiration.createdAt {
                        Text(formatDate(createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 整理狀態指示器（基於任務關聯）
                if viewModel.isOrganized(inspiration) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("\(viewModel.getTaskCount(for: inspiration))")
                            .font(.caption2)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                }
            }
            
            // 根據類型顯示不同內容
            if inspiration.type == 2 { // 網址類型
                if let url = inspiration.url, !url.isEmpty {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(url)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                    }
                }
            }
            
            // 內容預覽
            if let content = inspiration.content, !content.isEmpty {
                Text(content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // 標籤
            let tagNames = viewModel.getTagNames(for: inspiration)
            if !tagNames.isEmpty {
                HStack {
                    ForEach(tagNames, id: \.self) { tagName in
                        Text(tagName)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
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
}

struct InspirationListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        InspirationListView()
            .environmentObject(InspirationViewModel(context: context))
    }
} 