import Foundation
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var selectedTab: Int = 2 // 預設 Add 分頁
    @Published var addTaskDefaultTitle: String? = nil
}
