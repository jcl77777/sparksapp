import SwiftUI

/// Reusable button component with pixel art aesthetic
/// Supports primary (colored) and secondary (outlined) styles
struct PixelButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let icon: String?
    let style: Style
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    init(
        _ title: String,
        icon: String? = nil,
        style: Style = .primary,
        color: Color = AppDesign.Colors.orange,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Text(icon)
                        .font(.system(size: 16))
                }
                Text(title)
                    .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
            }
            .padding(.horizontal, AppDesign.Spacing.standard)
            .padding(.vertical, AppDesign.Spacing.small)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(AppDesign.Borders.radiusButton)
            .overlay(
                RoundedRectangle(cornerRadius: AppDesign.Borders.radiusButton)
                    .stroke(borderColor, lineWidth: AppDesign.Borders.thick)
            )
        }
        .buttonStyle(PixelButtonStyle())
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return color
        case .secondary:
            return AppDesign.Colors.cardBackground
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return color
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:
            return color.opacity(0.8)
        case .secondary:
            return color
        }
    }
}

/// Custom button style for press animation
struct PixelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Primary Buttons") {
    VStack(spacing: AppDesign.Spacing.small) {
        PixelButton("💾 儲存靈感", color: AppDesign.Colors.orange) {
            print("Save tapped")
        }

        PixelButton("✓ 標記完成", color: AppDesign.Colors.green) {
            print("Complete tapped")
        }

        PixelButton("➕ 新增任務", color: AppDesign.Colors.blue) {
            print("Add tapped")
        }

        PixelButton("🗑️ 刪除", color: .red) {
            print("Delete tapped")
        }
    }
    .padding()
}

#Preview("Secondary Buttons") {
    VStack(spacing: AppDesign.Spacing.small) {
        PixelButton("取消", style: .secondary, color: AppDesign.Colors.gray) {
            print("Cancel tapped")
        }

        PixelButton("編輯", icon: "✏️", style: .secondary, color: AppDesign.Colors.blue) {
            print("Edit tapped")
        }

        PixelButton("查看詳情", style: .secondary, color: AppDesign.Colors.purple) {
            print("View details tapped")
        }
    }
    .padding()
}

#Preview("Mixed Styles") {
    VStack(spacing: AppDesign.Spacing.standard) {
        Text("Primary vs Secondary")
            .font(.system(size: 18, weight: .bold, design: .monospaced))

        HStack(spacing: AppDesign.Spacing.small) {
            PixelButton("儲存", color: AppDesign.Colors.green) {
                print("Save")
            }

            PixelButton("取消", style: .secondary, color: AppDesign.Colors.gray) {
                print("Cancel")
            }
        }

        Divider()

        HStack(spacing: AppDesign.Spacing.small) {
            PixelButton("刪除", color: .red) {
                print("Delete")
            }

            PixelButton("保留", style: .secondary, color: AppDesign.Colors.blue) {
                print("Keep")
            }
        }
    }
    .padding()
}
