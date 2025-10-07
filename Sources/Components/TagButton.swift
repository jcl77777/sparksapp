import SwiftUI

/// Tag button component with pixel art aesthetic
/// Small, rounded badge-style button with # prefix
struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let action: (() -> Void)?

    init(_ tag: String, isSelected: Bool = false, action: (() -> Void)? = nil) {
        self.tag = tag
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    tagContent
                }
                .buttonStyle(PixelButtonStyle())
            } else {
                tagContent
            }
        }
    }

    private var tagContent: some View {
        Text("#\(tag)")
            .font(.system(size: AppDesign.Typography.labelSize, weight: .bold, design: .monospaced))
            .foregroundColor(isSelected ? .white : AppDesign.Colors.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(AppDesign.Borders.radiusTag)
            .overlay(
                RoundedRectangle(cornerRadius: AppDesign.Borders.radiusTag)
                    .stroke(borderColor, lineWidth: AppDesign.Borders.thin)
            )
    }

    private var backgroundColor: Color {
        if isSelected {
            return AppDesign.Colors.orange
        } else {
            return AppDesign.Colors.tagBackground
        }
    }

    private var borderColor: Color {
        if isSelected {
            return AppDesign.Colors.orange.opacity(0.8)
        } else {
            return AppDesign.Colors.tagBorder
        }
    }
}

/// Tag list container that wraps tags
struct TagList: View {
    let tags: [String]
    let selectedTags: Set<String>
    let onTagTap: ((String) -> Void)?

    init(tags: [String], selectedTags: Set<String> = [], onTagTap: ((String) -> Void)? = nil) {
        self.tags = tags
        self.selectedTags = selectedTags
        self.onTagTap = onTagTap
    }

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                TagButton(
                    tag,
                    isSelected: selectedTags.contains(tag),
                    action: onTagTap != nil ? { onTagTap?(tag) } : nil
                )
            }
        }
    }
}

/// Flow layout for wrapping tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview("Basic Tags") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Unselected Tags")
            .font(.headline)

        HStack {
            TagButton("design")
            TagButton("idea")
            TagButton("work")
        }

        Divider()

        Text("Selected Tags")
            .font(.headline)

        HStack {
            TagButton("design", isSelected: true)
            TagButton("idea", isSelected: false)
            TagButton("work", isSelected: true)
        }
    }
    .padding()
}

#Preview("Wrapping Tag List") {
    VStack(alignment: .leading, spacing: 16) {
        Text("🏷️ All Tags")
            .font(.system(size: 18, weight: .bold, design: .monospaced))

        TagList(
            tags: ["design", "idea", "work", "personal", "urgent", "later", "research", "development", "ui", "ux"],
            selectedTags: ["design", "urgent", "ui"]
        ) { tag in
            print("Tapped: \(tag)")
        }

        Divider()

        Text("Read-only Tags")
            .font(.system(size: 18, weight: .bold, design: .monospaced))

        TagList(
            tags: ["apple", "swift", "swiftui", "ios"],
            selectedTags: []
        )
    }
    .padding()
}

#Preview("Tags in Card") {
    PixelCard(borderColor: AppDesign.Colors.purple) {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("💡")
                    .font(.system(size: 32))
                VStack(alignment: .leading) {
                    Text("SwiftUI Component Library")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                    Text("2025-01-15")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray)
                }
                Spacer()
            }

            Text("Building reusable components with pixel art aesthetic")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.gray)

            TagList(
                tags: ["swiftui", "design", "components"],
                selectedTags: []
            )
        }
        .padding(AppDesign.Spacing.standard)
    }
    .padding()
}
