import SwiftUI

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppDesign.Spacing.small) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(AppDesign.Colors.borderPrimary, lineWidth: AppDesign.Borders.thin)
                        .frame(width: 20, height: 20)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isSelected ? AppDesign.Colors.blue.opacity(0.2) : Color.white)
                        )

                    if isSelected {
                        Text("✓")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppDesign.Colors.blue)
                    }
                }

                // Title
                Text(title)
                    .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                    .foregroundColor(AppDesign.Colors.textPrimary)

                Spacer()
            }
            .padding(AppDesign.Spacing.small)
            .background(isSelected ? AppDesign.Colors.blue.opacity(0.05) : Color.clear)
            .cornerRadius(AppDesign.Borders.radiusButton)
            .overlay(
                RoundedRectangle(cornerRadius: AppDesign.Borders.radiusButton)
                    .stroke(isSelected ? AppDesign.Colors.blue : Color.clear, lineWidth: AppDesign.Borders.thin)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 