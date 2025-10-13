import SwiftUI

/// Statistic card component for dashboard
/// Displays a large number with label and colored border
struct StatCard: View {
    let value: Int
    let label: String
    let color: Color
    let icon: String?

    init(value: Int, label: String, color: Color, icon: String? = nil) {
        self.value = value
        self.label = label
        self.color = color
        self.icon = icon
    }

    var body: some View {
        VStack(spacing: 8) {
            if let icon = icon {
                Text(icon)
                    .font(.system(size: 32))
            }

            Text("\(value)")
                .font(.system(size: AppDesign.Typography.statSize, weight: .bold, design: .monospaced))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                .foregroundColor(AppDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppDesign.Spacing.standard)
        .background(AppDesign.Colors.cardBackground)
        .cornerRadius(AppDesign.Borders.radiusCard)
        .overlay(
            RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                .stroke(color, lineWidth: AppDesign.Borders.thick)
        )
    }
}

/// Stats grid container for dashboard layout
struct StatsGrid: View {
    let stats: [(value: Int, label: String, color: Color, icon: String?)]

    init(stats: [(value: Int, label: String, color: Color, icon: String?)]) {
        self.stats = stats
    }

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: AppDesign.Spacing.small),
            GridItem(.flexible(), spacing: AppDesign.Spacing.small)
        ], spacing: AppDesign.Spacing.small) {
            ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                StatCard(
                    value: stat.value,
                    label: stat.label,
                    color: stat.color,
                    icon: stat.icon
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("Single Stat Cards") {
    VStack(spacing: AppDesign.Spacing.standard) {
        StatCard(
            value: 42,
            label: NSLocalizedString("stats_total_inspirations", comment: "Total Inspirations"),
            color: AppDesign.Colors.blue,
            icon: "💡"
        )

        StatCard(
            value: 28,
            label: NSLocalizedString("stats_organized", comment: "Organized"),
            color: AppDesign.Colors.green,
            icon: "✓"
        )

        StatCard(
            value: 15,
            label: NSLocalizedString("stats_total_tasks", comment: "Total Tasks"),
            color: AppDesign.Colors.orange,
            icon: "📋"
        )

        StatCard(
            value: 8,
            label: NSLocalizedString("stats_completed_tasks", comment: "Completed"),
            color: AppDesign.Colors.purple,
            icon: "✔️"
        )
    }
    .padding()
}

#Preview("Stats Grid (2x2)") {
    ScrollView {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.standard) {
            Text("📊 儀表板")
                .font(.system(size: 24, weight: .bold, design: .monospaced))

            StatsGrid(stats: [
                (42, NSLocalizedString("stats_total_inspirations", comment: "Total Inspirations"), AppDesign.Colors.blue, "💡"),
                (28, NSLocalizedString("stats_organized", comment: "Organized"), AppDesign.Colors.green, "✓"),
                (15, NSLocalizedString("stats_total_tasks", comment: "Total Tasks"), AppDesign.Colors.orange, "📋"),
                (8, NSLocalizedString("stats_completed_tasks", comment: "Completed"), AppDesign.Colors.purple, "✔️")
            ])
        }
        .padding()
    }
}

#Preview("Complete Dashboard Layout") {
    ScrollView {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.large) {
            // Header
            GradientHeader(
                title: "📊 儀表板",
                gradientColors: AppDesign.Colors.blueGradient
            )

            VStack(alignment: .leading, spacing: AppDesign.Spacing.standard) {
                // Stats Grid
                StatsGrid(stats: [
                    (42, "Total\nInspirations", AppDesign.Colors.blue, "💡"),
                    (28, "Organized", AppDesign.Colors.green, "✓"),
                    (15, "Total\nTasks", AppDesign.Colors.orange, "📋"),
                    (8, "Completed", AppDesign.Colors.purple, "✔️")
                ])

                // Reminders Section
                VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                    Text("🔔 近期提醒")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))

                    PixelCard(borderColor: Color(hex: "#fbbf24")) {
                        HStack {
                            Text("⚡")
                                .font(.system(size: 24))
                            VStack(alignment: .leading) {
                                Text("Complete project proposal")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                Text("Due: Tomorrow")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(AppDesign.Spacing.small)
                    }
                }

                // Popular Tags Section
                VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                    Text("🏷️ 熱門標籤")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))

                    TagList(
                        tags: ["work", "design", "urgent", "personal"],
                        selectedTags: []
                    )
                }
            }
            .padding(AppDesign.Spacing.standard)
        }
    }
}
