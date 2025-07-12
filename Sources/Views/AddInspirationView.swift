import SwiftUI

struct AddInspirationView: View {
    @State private var selectedType: InspirationType?
    
    enum InspirationType: String, CaseIterable {
        case note = "筆記"
        case image = "圖片"
        case url = "網址"
        case video = "影片"
        
        var icon: String {
            switch self {
            case .note: return "note.text"
            case .image: return "photo"
            case .url: return "link"
            case .video: return "video"
            }
        }
        
        var color: Color {
            switch self {
            case .note: return .blue
            case .image: return .green
            case .url: return .orange
            case .video: return .purple
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 標題
                VStack(spacing: 8) {
                    Text("新增靈感")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("選擇靈感類型")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // 靈感類型按鈕
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                    ForEach(InspirationType.allCases, id: \.self) { type in
                        Button(action: {
                            selectedType = type
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: type.icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(type.color)
                                
                                Text(type.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(type.color.opacity(0.3), lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedType) { type in
            switch type {
            case .note:
                NoteInspirationView()
            case .image:
                Text("圖片功能開發中...")
                    .font(.title)
                    .padding()
            case .url:
                Text("網址功能開發中...")
                    .font(.title)
                    .padding()
            case .video:
                Text("影片功能開發中...")
                    .font(.title)
                    .padding()
            }
        }
    }
}

// 讓 InspirationType 符合 Identifiable
extension AddInspirationView.InspirationType: Identifiable {
    var id: String { rawValue }
}

struct AddInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        AddInspirationView()
    }
} 