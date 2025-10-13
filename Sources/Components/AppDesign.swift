import SwiftUI

/// Central design system for Sparks app
/// Pixel art / retro gaming aesthetic with bold borders and monospace fonts
struct AppDesign {

    // MARK: - Colors

    struct Colors {
        // Gradient pairs for headers
        static let purpleGradient = [Color(hex: "#a855f7"), Color(hex: "#ec4899")]
        static let greenGradient = [Color(hex: "#22c55e"), Color(hex: "#10b981")]
        static let orangeGradient = [Color(hex: "#f97316"), Color(hex: "#fbbf24")]
        static let blueGradient = [Color(hex: "#3b82f6"), Color(hex: "#06b6d4")]
        static let grayGradient = [Color(hex: "#4b5563"), Color(hex: "#1f2937")]

        // Solid colors
        static let purple = Color(hex: "#a855f7")
        static let green = Color(hex: "#22c55e")
        static let orange = Color(hex: "#f97316")
        static let blue = Color(hex: "#3b82f6")
        static let gray = Color(hex: "#4b5563")

        // Tag colors
        static let tagBackground = Color(hex: "#fde047") // yellow-300
        static let tagBorder = Color.black

        // System colors
        static let cardBackground = Color.white
        static let borderPrimary = Color.black
        static let textPrimary = Color.black
        static let textSecondary = Color.gray
    }

    // MARK: - Typography

    struct Typography {
        // Font sizes
        static let headerSize: CGFloat = 24
        static let titleSize: CGFloat = 18
        static let subtitleSize: CGFloat = 16
        static let bodySize: CGFloat = 14
        static let labelSize: CGFloat = 12
        static let captionSize: CGFloat = 10
        static let statSize: CGFloat = 36

        // Helper methods for creating Text views
        static func header(_ text: String) -> some View {
            Text(text)
                .font(.system(size: headerSize, weight: .bold, design: .monospaced))
        }

        static func title(_ text: String) -> some View {
            Text(text)
                .font(.system(size: titleSize, weight: .bold, design: .monospaced))
        }

        static func subtitle(_ text: String) -> some View {
            Text(text)
                .font(.system(size: subtitleSize, weight: .semibold, design: .monospaced))
        }

        static func body(_ text: String) -> some View {
            Text(text)
                .font(.system(size: bodySize, design: .monospaced))
        }

        static func label(_ text: String) -> some View {
            Text(text)
                .font(.system(size: labelSize, design: .monospaced))
        }

        static func caption(_ text: String) -> some View {
            Text(text)
                .font(.system(size: captionSize, design: .monospaced))
        }

        static func stat(_ text: String) -> some View {
            Text(text)
                .font(.system(size: statSize, weight: .bold, design: .monospaced))
        }
    }

    // MARK: - Spacing

    struct Spacing {
        static let tiny: CGFloat = 4
        static let extraSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let standard: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32

        static let itemGap: CGFloat = 12
    }

    // MARK: - Borders

    struct Borders {
        static let thick: CGFloat = 4
        static let thin: CGFloat = 2

        static let radiusCard: CGFloat = 8
        static let radiusButton: CGFloat = 4
        static let radiusTag: CGFloat = 16
    }

    // MARK: - Shadows

    struct Shadows {
        static func card() -> some View {
            EmptyView()
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }

        static let cardModifier = CardShadowModifier()
    }
}

// MARK: - Shadow Modifier

struct CardShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
