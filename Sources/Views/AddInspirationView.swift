import SwiftUI

struct AddInspirationView: View {
    @EnvironmentObject var appState: AppState
    @State private var showNoteSheet = false
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
                VStack(spacing: 8) {
                    Text("新增靈感")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("選擇靈感類型")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                    ForEach(InspirationType.allCases, id: \.self) { type in
                        Button(action: {
                            if type == .note {
                                showNoteSheet = true
                            } else {
                                selectedType = type
                            }
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
        .sheet(isPresented: $showNoteSheet) {
            NoteInspirationView(onComplete: { tabIndex in
                showNoteSheet = false
                appState.selectedTab = tabIndex
            })
        }
        .sheet(item: $selectedType) { type in
            switch type {
            case .note:
                EmptyView() // 不會用到
            case .image:
                Text("圖片功能開發中...")
                    .font(.title)
                    .padding()
            case .url:
                URLInspirationView()
            case .video:
                Text("影片功能開發中...")
                    .font(.title)
                    .padding()
            }
        }
    }
}

extension AddInspirationView.InspirationType: Identifiable {
    var id: String { rawValue }
}

struct AddInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        AddInspirationView().environmentObject(AppState.shared)
    }
} 