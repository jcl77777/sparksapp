import Foundation
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case traditionalChinese = "zh-Hant"
    
    var id: String { self.rawValue }
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .traditionalChinese:
            return "繁體中文"
        }
    }
}

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var selectedTab: Int = 2 // 預設 Add 分頁
    @Published var addTaskDefaultTitle: String? = nil
    @Published var shouldShowUnorganizedOnAppear: Bool = false
    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "AppLanguage")
            Bundle.setLanguage(language.rawValue)
        }
    }
    
    init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage")
        let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        self.language = AppLanguage(rawValue: savedLanguage ?? systemLanguage) ?? .english
        Bundle.setLanguage(self.language.rawValue)
    }
}
