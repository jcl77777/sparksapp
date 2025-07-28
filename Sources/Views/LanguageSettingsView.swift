import SwiftUI

struct LanguageSettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("settings_language", comment: "語言"))) {
                    Picker(NSLocalizedString("settings_language", comment: "語言"), selection: $appState.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle(NSLocalizedString("settings_language", comment: "語言"))
            .navigationBarItems(leading: Button(NSLocalizedString("common_close", comment: "關閉")) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
} 