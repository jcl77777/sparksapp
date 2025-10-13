import SwiftUI

struct AddInspirationView: View {
    @EnvironmentObject var appState: AppState
    @State private var showNoteSheet = false
    @State private var selectedType: InspirationType?

    enum InspirationType: String, CaseIterable {
        case note
        case image
        case url
        case video

        var icon: String {
            switch self {
            case .note: return "📝"
            case .image: return "🖼️"
            case .url: return "🔗"
            case .video: return "🎬"
            }
        }

        var color: Color {
            switch self {
            case .note: return AppDesign.Colors.orange
            case .image: return AppDesign.Colors.purple
            case .url: return AppDesign.Colors.blue
            case .video: return AppDesign.Colors.orange
            }
        }

        var localized: String {
            switch self {
            case .note: return NSLocalizedString("addinspiration_type_note", comment: "筆記")
            case .image: return NSLocalizedString("addinspiration_type_image", comment: "圖片")
            case .url: return NSLocalizedString("addinspiration_type_url", comment: "網址")
            case .video: return NSLocalizedString("addinspiration_type_video", comment: "影片")
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Gradient Header
            GradientHeader(
                title: "➕ " + NSLocalizedString("addinspiration_title", comment: "新增靈感"),
                gradientColors: AppDesign.Colors.orangeGradient
            )

            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: AppDesign.Spacing.standard) {
                        Text(NSLocalizedString("addinspiration_select_type", comment: "選擇靈感類型"))
                            .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(.top, AppDesign.Spacing.standard)

                        // Type Selection Grid (2x2)
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: AppDesign.Spacing.small),
                                GridItem(.flexible(), spacing: AppDesign.Spacing.small)
                            ],
                            spacing: AppDesign.Spacing.small
                        ) {
                            ForEach(InspirationType.allCases, id: \.self) { type in
                                TypeButton(type: type) {
                                    if type == .note {
                                        showNoteSheet = true
                                    } else {
                                        selectedType = type
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppDesign.Spacing.standard)
                    }
                    .frame(minHeight: geometry.size.height, alignment: .top)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationBarHidden(true)
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
                ImageInspirationView(onComplete: { tabIndex in
                    selectedType = nil
                    appState.selectedTab = tabIndex
                })
            case .url:
                URLInspirationView()
            case .video:
                VideoInspirationView(onComplete: { tabIndex in
                    selectedType = nil
                    appState.selectedTab = tabIndex
                })
            }
        }
    }
}

// MARK: - Type Button Component

struct TypeButton: View {
    let type: AddInspirationView.InspirationType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            PixelCard(borderColor: type.color) {
                VStack(spacing: AppDesign.Spacing.small) {
                    Text(type.icon)
                        .font(.system(size: 48))

                    Text(type.localized)
                        .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .background(type.color.opacity(0.05))
            }
        }
        .buttonStyle(PixelButtonStyle())
    }
}

// MARK: - Extensions

extension AddInspirationView.InspirationType: Identifiable {
    var id: String { rawValue }
}

// MARK: - Preview

struct AddInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        AddInspirationView().environmentObject(AppState.shared)
    }
} 