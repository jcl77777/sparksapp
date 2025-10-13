import SwiftUI

/// Clean, subtle search bar component
/// Maintains iOS-style rounded appearance while using AppDesign system values
struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    var icon: String? = nil

    var body: some View {
        HStack(spacing: AppDesign.Spacing.extraSmall) {
            // Icon (custom emoji or system magnifying glass)
            if let customIcon = icon {
                Text(customIcon)
                    .font(.system(size: 16))
            } else {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppDesign.Colors.textSecondary)
            }

            // Text field
            TextField(placeholder, text: $text)
                .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                .foregroundColor(AppDesign.Colors.textPrimary)
                .textFieldStyle(PlainTextFieldStyle())

            // Clear button
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppDesign.Colors.textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, AppDesign.Spacing.small)
        .padding(.vertical, AppDesign.Spacing.extraSmall)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview("SearchBar Empty") {
    VStack(spacing: AppDesign.Spacing.standard) {
        SearchBar(text: .constant(""), placeholder: "搜尋靈感...")
        SearchBar(text: .constant(""), placeholder: "搜尋任務...")
        SearchBar(text: .constant(""), placeholder: "Search tags...")
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("SearchBar with Text") {
    VStack(spacing: AppDesign.Spacing.standard) {
        SearchBar(text: .constant("設計靈感"), placeholder: "搜尋靈感...")
        SearchBar(text: .constant("完成專案"), placeholder: "搜尋任務...")
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("SearchBar Custom Icons") {
    VStack(spacing: AppDesign.Spacing.standard) {
        SearchBar(text: .constant(""), placeholder: "搜尋靈感...", icon: "💡")
        SearchBar(text: .constant(""), placeholder: "搜尋任務...", icon: "✓")
        SearchBar(text: .constant(""), placeholder: "搜尋標籤...", icon: "🏷️")
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("SearchBar in Context") {
    VStack(spacing: 0) {
        // Header
        GradientHeader(
            title: "💡 收藏",
            gradientColors: AppDesign.Colors.purpleGradient
        )

        VStack(spacing: AppDesign.Spacing.standard) {
            // Search bar
            SearchBar(text: .constant(""), placeholder: "搜尋靈感...")

            // Sample content
            PixelCard(borderColor: AppDesign.Colors.purple) {
                HStack {
                    Text("💡")
                        .font(.system(size: 32))
                    VStack(alignment: .leading) {
                        Text("Sample Inspiration")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                        Text("2025-01-15")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(AppDesign.Spacing.standard)
            }
        }
        .padding(AppDesign.Spacing.standard)

        Spacer()
    }
}
