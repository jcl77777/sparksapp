import SwiftUI

/// Reusable text field component with pixel art aesthetic
/// Features thick borders, monospaced font, and consistent styling
struct PixelTextField: View {
    @Binding var text: String
    let placeholder: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        HStack(spacing: AppDesign.Spacing.small) {
            if let icon = icon {
                Text(icon)
                    .font(.system(size: 16))
            }

            TextField(placeholder, text: $text)
                .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                .foregroundColor(AppDesign.Colors.textPrimary)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
        }
        .padding(AppDesign.Spacing.small)
        .background(AppDesign.Colors.cardBackground)
        .cornerRadius(AppDesign.Borders.radiusCard)
        .overlay(
            RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                .stroke(AppDesign.Colors.borderPrimary, lineWidth: AppDesign.Borders.thin)
        )
    }
}

// MARK: - Preview

#Preview("PixelTextField Basic") {
    VStack(spacing: AppDesign.Spacing.standard) {
        Text("Basic Text Fields")
            .font(.system(size: 18, weight: .bold, design: .monospaced))

        PixelTextField(
            text: .constant(""),
            placeholder: "輸入標題"
        )

        PixelTextField(
            text: .constant("設計靈感收集"),
            placeholder: "輸入標題"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("PixelTextField with Icons") {
    VStack(spacing: AppDesign.Spacing.standard) {
        Text("With Icons")
            .font(.system(size: 18, weight: .bold, design: .monospaced))

        PixelTextField(
            text: .constant(""),
            placeholder: "輸入標題",
            icon: "📝"
        )

        PixelTextField(
            text: .constant(""),
            placeholder: "輸入網址",
            icon: "🔗"
        )

        PixelTextField(
            text: .constant(""),
            placeholder: "輸入任務",
            icon: "✓"
        )

        PixelTextField(
            text: .constant(""),
            placeholder: "輸入標籤",
            icon: "🏷️"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("PixelTextField Different Keyboards") {
    VStack(spacing: AppDesign.Spacing.standard) {
        Text("Different Keyboard Types")
            .font(.system(size: 18, weight: .bold, design: .monospaced))

        PixelTextField(
            text: .constant(""),
            placeholder: "Email",
            icon: "✉️",
            keyboardType: .emailAddress,
            autocapitalization: .never
        )

        PixelTextField(
            text: .constant(""),
            placeholder: "URL",
            icon: "🔗",
            keyboardType: .URL,
            autocapitalization: .never
        )

        PixelTextField(
            text: .constant(""),
            placeholder: "Number",
            icon: "#️⃣",
            keyboardType: .numberPad
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("PixelTextField Form Example") {
    ScrollView {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.standard) {
            Text("新增靈感")
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
                Text("網址")
                    .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))

                PixelTextField(
                    text: .constant(""),
                    placeholder: "https://...",
                    icon: "🔗",
                    keyboardType: .URL,
                    autocapitalization: .never
                )
            }

            VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                Text("標籤")
                    .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))

                PixelTextField(
                    text: .constant(""),
                    placeholder: "新增標籤",
                    icon: "🏷️"
                )
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
