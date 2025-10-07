import SwiftUI

struct LanguageSettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Gradient Header
                GradientHeader(
                    title: "🌐 " + NSLocalizedString("settings_language", comment: "語言"),
                    gradientColors: AppDesign.Colors.blueGradient
                )

                VStack(spacing: AppDesign.Spacing.standard) {
                    // 語言選擇
                    VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                        Text(NSLocalizedString("settings_language", comment: "語言"))
                            .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textPrimary)

                        PixelCard(borderColor: AppDesign.Colors.blue) {
                            VStack(spacing: AppDesign.Spacing.small) {
                                ForEach(AppLanguage.allCases) { lang in
                                    Button(action: {
                                        appState.language = lang
                                    }) {
                                        HStack {
                                            Text(lang.displayName)
                                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                                .foregroundColor(AppDesign.Colors.textPrimary)

                                            Spacer()

                                            if appState.language == lang {
                                                Text("✓")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(AppDesign.Colors.blue)
                                            }
                                        }
                                        .padding(AppDesign.Spacing.small)
                                        .background(appState.language == lang ? AppDesign.Colors.blue.opacity(0.1) : Color.clear)
                                        .cornerRadius(AppDesign.Borders.radiusButton)
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    if lang != AppLanguage.allCases.last {
                                        Divider()
                                    }
                                }
                            }
                            .padding(AppDesign.Spacing.standard)
                        }
                    }

                    // 關閉按鈕
                    PixelButton(
                        NSLocalizedString("common_close", comment: "關閉"),
                        style: .secondary,
                        color: AppDesign.Colors.gray
                    ) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.top, AppDesign.Spacing.small)
                }
                .padding(AppDesign.Spacing.standard)
            }
        }
    }
} 