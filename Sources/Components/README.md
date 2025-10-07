I# Sparks Component Library

A reusable SwiftUI component library with **pixel art / retro gaming aesthetic**.

## 🎨 Design Philosophy

- **Bold 4px borders** on all interactive elements
- **Monospace fonts** throughout for retro look
- **Gradient headers** with vibrant colors
- **Thick shadows** for depth (no subtle effects)
- **High contrast** white cards on colored backgrounds
- **Emoji icons** integrated into UI

---

## 📦 Components

### 1. AppDesign (Design System)

Central design constants and utilities.

**Colors:**
```swift
AppDesign.Colors.purpleGradient // [#a855f7, #ec4899]
AppDesign.Colors.greenGradient   // [#22c55e, #10b981]
AppDesign.Colors.orangeGradient  // [#f97316, #fbbf24]
AppDesign.Colors.blueGradient    // [#3b82f6, #06b6d4]
AppDesign.Colors.grayGradient    // [#4b5563, #1f2937]
```

**Typography:**
```swift
AppDesign.Typography.header("Title")  // 24px bold monospace
AppDesign.Typography.body("Text")     // 14px monospace
AppDesign.Typography.label("Label")   // 12px monospace
AppDesign.Typography.stat("42")       // 36px bold monospace
```

**Spacing:**
```swift
AppDesign.Spacing.small     // 12pt
AppDesign.Spacing.standard  // 16pt
AppDesign.Spacing.large     // 24pt
```

**Borders:**
```swift
AppDesign.Borders.thick         // 4pt
AppDesign.Borders.thin          // 2pt
AppDesign.Borders.radiusCard    // 8pt
AppDesign.Borders.radiusButton  // 4pt
AppDesign.Borders.radiusTag     // 16pt
```

---

### 2. GradientHeader

Colored gradient header with title and optional content.

**Usage:**
```swift
// Basic header
GradientHeader(
    title: "💡 收藏",
    gradientColors: AppDesign.Colors.purpleGradient
)

// Header with custom content
GradientHeader(
    title: "💡 收藏",
    gradientColors: AppDesign.Colors.purpleGradient
) {
    HStack {
        Button("✓ 已整理") { }
        Button("⋯ 待整理") { }
    }
}
```

**Props:**
- `title: String` - Header title (supports emoji)
- `gradientColors: [Color]` - Array of 2 colors for gradient
- `content: () -> Content` - Optional custom content below title

---

### 3. PixelCard

White card with thick border and shadow.

**Usage:**
```swift
PixelCard(borderColor: AppDesign.Colors.purple) {
    VStack(alignment: .leading) {
        Text("Card Title")
            .font(.system(size: 16, weight: .bold, design: .monospaced))
        Text("Card content here")
            .font(.system(size: 14, design: .monospaced))
    }
    .padding(AppDesign.Spacing.standard)
}
```

**Props:**
- `borderColor: Color` - Border color (default: black)
- `content: () -> Content` - Card content (ViewBuilder)

---

### 4. PixelButton

Primary or secondary styled button with press animation.

**Usage:**
```swift
// Primary button (colored background)
PixelButton("💾 儲存", color: AppDesign.Colors.orange) {
    print("Save tapped")
}

// Secondary button (outlined)
PixelButton(
    "取消",
    style: .secondary,
    color: AppDesign.Colors.gray
) {
    print("Cancel tapped")
}

// With icon
PixelButton("✓ 完成", icon: "✓", color: AppDesign.Colors.green) {
    print("Done")
}
```

**Props:**
- `title: String` - Button text
- `icon: String?` - Optional emoji icon
- `style: Style` - `.primary` or `.secondary`
- `color: Color` - Button color
- `action: () -> Void` - Tap handler

**Styles:**
- **Primary:** Colored background, white text
- **Secondary:** White background, colored text and border

---

### 5. TagButton & TagList

Tag badge components with wrapping layout.

**Usage:**
```swift
// Single tag
TagButton("design", isSelected: false)

// Interactive tag
TagButton("design", isSelected: true) {
    print("Tag tapped")
}

// Tag list with wrapping
TagList(
    tags: ["design", "idea", "work"],
    selectedTags: ["design"],
    onTagTap: { tag in
        print("Tapped: \(tag)")
    }
)
```

**TagButton Props:**
- `tag: String` - Tag name (# prefix added automatically)
- `isSelected: Bool` - Selection state
- `action: (() -> Void)?` - Optional tap handler

**TagList Props:**
- `tags: [String]` - Array of tag names
- `selectedTags: Set<String>` - Currently selected tags
- `onTagTap: ((String) -> Void)?` - Optional tap handler

---

### 6. StatCard & StatsGrid

Dashboard statistic cards with large numbers.

**Usage:**
```swift
// Single stat card
StatCard(
    value: 42,
    label: "Total\nInspirations",
    color: AppDesign.Colors.blue,
    icon: "💡"
)

// Stats grid (2x2)
StatsGrid(stats: [
    (42, "Total\nInspirations", AppDesign.Colors.blue, "💡"),
    (28, "Organized", AppDesign.Colors.green, "✓"),
    (15, "Total\nTasks", AppDesign.Colors.orange, "📋"),
    (8, "Completed", AppDesign.Colors.purple, "✔️")
])
```

**StatCard Props:**
- `value: Int` - Statistic number
- `label: String` - Stat description (supports `\n`)
- `color: Color` - Border and number color
- `icon: String?` - Optional emoji icon

**StatsGrid Props:**
- `stats: [(value: Int, label: String, color: Color, icon: String?)]` - Array of stat data

---

## 🚀 Quick Start

### Import Components

```swift
import SwiftUI

// All components are in Sources/Components/
// Just use them directly after import
```

### Example: Collection View

```swift
struct CollectionView: View {
    @State private var isOrganized = true

    var body: some View {
        VStack(spacing: 0) {
            // Header with segmented control
            GradientHeader(
                title: "💡 收藏",
                gradientColors: AppDesign.Colors.purpleGradient
            ) {
                HStack {
                    PixelButton(
                        "✓ 已整理",
                        style: isOrganized ? .primary : .secondary,
                        color: .white
                    ) {
                        isOrganized = true
                    }

                    PixelButton(
                        "⋯ 待整理",
                        style: !isOrganized ? .primary : .secondary,
                        color: .white
                    ) {
                        isOrganized = false
                    }
                }
            }

            // Scrollable content
            ScrollView {
                VStack(spacing: AppDesign.Spacing.small) {
                    ForEach(items) { item in
                        PixelCard(borderColor: AppDesign.Colors.purple) {
                            HStack {
                                Text("💡").font(.system(size: 32))
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    TagList(tags: item.tags)
                                }
                                Spacer()
                            }
                            .padding(AppDesign.Spacing.standard)
                        }
                    }
                }
                .padding(AppDesign.Spacing.standard)
            }
        }
    }
}
```

### Example: Dashboard View

```swift
struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.large) {
                GradientHeader(
                    title: "📊 儀表板",
                    gradientColors: AppDesign.Colors.blueGradient
                )

                VStack(spacing: AppDesign.Spacing.standard) {
                    StatsGrid(stats: [
                        (42, "Total\nInspirations", AppDesign.Colors.blue, "💡"),
                        (28, "Organized", AppDesign.Colors.green, "✓"),
                        (15, "Total\nTasks", AppDesign.Colors.orange, "📋"),
                        (8, "Completed", AppDesign.Colors.purple, "✔️")
                    ])
                }
                .padding(AppDesign.Spacing.standard)
            }
        }
    }
}
```

---

## 🎯 Design Tokens

### Color Mapping

| Section | Gradient |
|---------|----------|
| Collection | Purple → Pink |
| Tasks | Green → Emerald |
| Add | Orange → Yellow |
| Dashboard | Blue → Cyan |
| Settings | Gray-600 → Gray-800 |

### Inspiration Types

| Type | Color | Icon |
|------|-------|------|
| Note | Orange | 📝 |
| Image | Purple | 🖼️ |
| URL | Blue | 🔗 |
| Video | Orange | 🎬 |

---

## 🔧 Customization

### Extending Colors

```swift
extension AppDesign.Colors {
    static let customGradient = [Color(hex: "#FF0000"), Color(hex: "#00FF00")]
}
```

### Custom Shadow

```swift
.shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
```

### Custom Border

```swift
.overlay(
    RoundedRectangle(cornerRadius: 8)
        .stroke(Color.black, lineWidth: 4)
)
```

---

## 📱 Previews

Each component includes multiple SwiftUI previews:
- Single component variations
- Combined layouts
- Interactive states
- Real-world usage examples

**View previews in Xcode:**
1. Open any component file
2. Enable Canvas (⌘ + ⌥ + Enter)
3. Click "▶" on preview to run live preview

---

## ✅ Component Checklist

- [x] AppDesign (design system)
- [x] GradientHeader
- [x] PixelCard
- [x] PixelButton (primary/secondary)
- [x] TagButton & TagList
- [x] StatCard & StatsGrid
- [ ] PixelPet (icon component) - To be added
- [ ] SegmentedControl - To be added
- [ ] CheckboxButton - To be added

---

## 🤝 Contributing

When creating new components:

1. **Follow the design system** - Use AppDesign constants
2. **Add previews** - Include multiple preview variations
3. **Use monospace fonts** - `.system(design: .monospaced)`
4. **Bold borders** - 4px for primary, 2px for secondary
5. **Document usage** - Add code examples

---

## 📚 Resources

- Component specs: `/component.md`
- Architecture: `/architecture.md`
- Tasks: `/tasks.md`
- Color system: Task 65-70 in tasks.md

---

Built with ❤️ for **Sparks** - The inspiration collection app
