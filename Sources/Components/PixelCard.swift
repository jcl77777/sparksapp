import SwiftUI

/// Reusable card component with pixel art aesthetic
/// Features thick borders, white background, and shadow
struct PixelCard<Content: View>: View {
    let borderColor: Color
    let content: Content

    init(
        borderColor: Color = AppDesign.Colors.borderPrimary,
        @ViewBuilder content: () -> Content
    ) {
        self.borderColor = borderColor
        self.content = content()
    }

    var body: some View {
        content
            .background(AppDesign.Colors.cardBackground)
            .cornerRadius(AppDesign.Borders.radiusCard)
            .overlay(
                RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                    .stroke(borderColor, lineWidth: AppDesign.Borders.thick)
            )
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview("Basic Card") {
    PixelCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Card Title")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
            Text("This is a pixel art styled card with thick borders")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.gray)
        }
        .padding(AppDesign.Spacing.standard)
    }
    .padding()
}

#Preview("Multiple Cards") {
    ScrollView {
        VStack(spacing: AppDesign.Spacing.small) {
            PixelCard(borderColor: AppDesign.Colors.purple) {
                HStack {
                    Text("💡")
                        .font(.system(size: 32))
                    VStack(alignment: .leading) {
                        Text("Inspiration Card")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                        Text("#design #idea")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(AppDesign.Spacing.standard)
            }

            PixelCard(borderColor: AppDesign.Colors.green) {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 32))
                        .foregroundColor(AppDesign.Colors.green)
                    VStack(alignment: .leading) {
                        Text("Task Card")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                        Text("Complete by tomorrow")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(AppDesign.Spacing.standard)
            }

            PixelCard(borderColor: AppDesign.Colors.orange) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("📝 Note")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                    Text("This is a longer note card with multiple lines of content to demonstrate the layout.")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .padding(AppDesign.Spacing.standard)
            }
        }
        .padding()
    }
}
