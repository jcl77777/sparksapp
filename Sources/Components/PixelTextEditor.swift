import SwiftUI

/// Reusable multi-line text editor component with pixel art aesthetic
/// Features thick borders, monospaced font, and consistent styling
struct PixelTextEditor: View {
    @Binding var text: String
    let placeholder: String
    var minHeight: CGFloat = 100
    var icon: String? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if let icon = icon {
                HStack {
                    Text(icon)
                        .font(.system(size: 16))
                    Spacer()
                }
                .padding(.horizontal, AppDesign.Spacing.small)
                .padding(.top, AppDesign.Spacing.small)
            }

            ZStack(alignment: .topLeading) {
                // Placeholder
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                        .foregroundColor(AppDesign.Colors.textSecondary)
                        .padding(.horizontal, AppDesign.Spacing.tiny)
                        .padding(.vertical, icon != nil ? AppDesign.Spacing.tiny : AppDesign.Spacing.extraSmall)
                }

                // Text Editor
                TextEditor(text: $text)
                    .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                    .foregroundColor(AppDesign.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .focused($isFocused)
                    .padding(AppDesign.Spacing.tiny)
            }
            .frame(minHeight: minHeight)
            .padding(AppDesign.Spacing.small)
        }
        .background(AppDesign.Colors.cardBackground)
        .cornerRadius(AppDesign.Borders.radiusCard)
        .overlay(
            RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                .stroke(AppDesign.Colors.borderPrimary, lineWidth: AppDesign.Borders.thin)
        )
    }
}

// MARK: - Preview

#Preview("PixelTextEditor Basic") {
    VStack(spacing: AppDesign.Spacing.standard) {
        Text("Basic Text Editor")
            .font(.system(size: 18, weight: .bold, design: .monospaced))

        PixelTextEditor(
            text: .constant(""),
            placeholder: "輸入描述..."
        )

        PixelTextEditor(
            text: .constant("這是一個多行文字輸入的範例。\n可以輸入很多行的內容。"),
            placeholder: "輸入描述..."
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("PixelTextEditor with Icon") {
    VStack(spacing: AppDesign.Spacing.standard) {
        Text("With Icons")
            .font(.system(size: 18, weight: .bold, design: .monospaced))

        PixelTextEditor(
            text: .constant(""),
            placeholder: "輸入筆記內容...",
            icon: "📝"
        )

        PixelTextEditor(
            text: .constant(""),
            placeholder: "輸入任務描述...",
            icon: "✓"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("PixelTextEditor Different Heights") {
    ScrollView {
        VStack(spacing: AppDesign.Spacing.standard) {
            Text("Different Heights")
                .font(.system(size: 18, weight: .bold, design: .monospaced))

            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                Text("Small (80pt)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                PixelTextEditor(
                    text: .constant(""),
                    placeholder: "簡短描述",
                    minHeight: 80
                )
            }

            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                Text("Medium (120pt)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                PixelTextEditor(
                    text: .constant(""),
                    placeholder: "中等長度內容",
                    minHeight: 120
                )
            }

            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                Text("Large (200pt)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                PixelTextEditor(
                    text: .constant(""),
                    placeholder: "長篇內容",
                    minHeight: 200
                )
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("PixelTextEditor Form Example") {
    ScrollView {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.standard) {
            Text("新增筆記")
                .font(.system(size: 24, weight: .bold, design: .monospaced))

            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                Text("標題")
                    .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))

                PixelTextField(
                    text: .constant(""),
                    placeholder: "輸入標題",
                    icon: "📝"
                )
            }

            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                Text("內容")
                    .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))

                PixelTextEditor(
                    text: .constant(""),
                    placeholder: "輸入筆記內容...",
                    minHeight: 150,
                    icon: "📄"
                )
            }

            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                Text("備註（選填）")
                    .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))

                PixelTextEditor(
                    text: .constant(""),
                    placeholder: "輸入額外備註...",
                    minHeight: 80
                )
            }

            PixelButton("💾 儲存", color: AppDesign.Colors.green) {
                // Save action
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("PixelTextEditor with Long Content") {
    VStack(spacing: AppDesign.Spacing.standard) {
        Text("Long Content")
            .font(.system(size: 18, weight: .bold, design: .monospaced))

        PixelTextEditor(
            text: .constant("""
            這是一段很長的文字內容範例。

            它包含了多個段落，
            以及不同的換行。

            TextEditor 會自動支援滾動，
            當內容超過設定的最小高度時。

            這樣可以讓使用者輸入
            任意長度的內容。
            """),
            placeholder: "輸入內容...",
            minHeight: 120
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
