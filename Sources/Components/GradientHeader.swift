import SwiftUI

/// Reusable gradient header component
/// Used across all main sections with different color gradients
struct GradientHeader<Content: View>: View {
    let title: String
    let gradientColors: [Color]
    let content: Content?

    init(
        title: String,
        gradientColors: [Color],
        @ViewBuilder content: () -> Content = { EmptyView() as! Content }
    ) {
        self.title = title
        self.gradientColors = gradientColors
        self.content = content()
    }

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .leading,
            endPoint: .trailing
        )
        .overlay(
            VStack(spacing: AppDesign.Spacing.small) {
                Text(title)
                    .font(.system(size: AppDesign.Typography.headerSize, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                if content != nil {
                    content
                }
            }
            .padding(AppDesign.Spacing.standard)
        )
        .frame(height: content != nil ? 120 : 80)
    }
}

/// Version without custom content
extension GradientHeader where Content == EmptyView {
    init(title: String, gradientColors: [Color]) {
        self.title = title
        self.gradientColors = gradientColors
        self.content = nil
    }
}

// MARK: - Preview

#Preview("Collection Header") {
    VStack(spacing: 0) {
        GradientHeader(
            title: "💡 收藏",
            gradientColors: AppDesign.Colors.purpleGradient
        )
        Spacer()
    }
}

#Preview("Header with Segmented Control") {
    VStack(spacing: 0) {
        GradientHeader(
            title: "💡 收藏",
            gradientColors: AppDesign.Colors.purpleGradient
        ) {
            HStack {
                Button("✓ 已整理") {}
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(AppDesign.Borders.radiusButton)

                Button("⋯ 待整理") {}
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(AppDesign.Borders.radiusButton)
            }
        }
        Spacer()
    }
}
