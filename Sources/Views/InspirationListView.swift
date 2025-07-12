import SwiftUI
import CoreData

struct InspirationListView: View {
    @EnvironmentObject var viewModel: InspirationViewModel
    @State private var showingAddSheet = false
    @State private var selectedInspiration: Inspiration?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.inspirations, id: \.objectID) { inspiration in
                    Button(action: {
                        selectedInspiration = inspiration
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            // 標題
                            Text(inspiration.title ?? "Untitled")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            // 根據類型顯示不同內容
                            if inspiration.type == 2 { // 網址類型
                                // 顯示網址
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
                                
                                // 顯示描述內容
                                if let content = inspiration.content, !content.isEmpty {
                                    Text(content)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            } else {
                                // 其他類型顯示內容
                                if let content = inspiration.content, !content.isEmpty {
                                    Text(content)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            
                            // 顯示標籤
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
                            
                            // 建立時間
                            if let createdAt = inspiration.createdAt {
                                Text("Created: \(formatDate(createdAt))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .onDelete { indexSet in
                    indexSet.map { viewModel.inspirations[$0] }.forEach(viewModel.deleteInspiration)
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