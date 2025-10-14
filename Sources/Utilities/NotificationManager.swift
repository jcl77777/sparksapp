import Foundation
import UserNotifications
import SwiftUI

// 頻率枚舉
enum ReminderFrequency: Int, Codable, CaseIterable, Identifiable {
    case daily = 1
    case weekly = 2
    case monthly = 3
    var id: Int { rawValue }
    var displayName: String {
        switch self {
        case .daily: return NSLocalizedString("notification_frequency_daily", comment: "每天")
        case .weekly: return NSLocalizedString("notification_frequency_weekly", comment: "每週")
        case .monthly: return NSLocalizedString("notification_frequency_monthly", comment: "每月")
        }
    }
}

// 未整理提醒設定
struct UnorganizedReminderSetting: Codable, Equatable {
    var enabled: Bool = true
    var frequency: ReminderFrequency = .daily
    var time: Date = Calendar.current.date(from: DateComponents(hour: 15, minute: 0)) ?? Date()
    var weekday: Int? = 2 // 週一（1=週日, 2=週一...）
    var day: Int? = 1     // 每月1號
}

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                self.checkAuthorizationStatus()
                
                if let error = error {
                    print("通知權限請求錯誤: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleTaskReminder(for task: TaskItem, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "任務提醒"
        content.body = "您的任務「\(task.title ?? "未命名任務")」即將到期"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: "task-\(task.id?.uuidString ?? UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("設定任務提醒失敗: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleUnorganizedReminder(setting: UnorganizedReminderSetting) {
        cancelUnorganizedReminder()
        guard setting.enabled else { return }
        let content = UNMutableNotificationContent()
        content.title = "靈感整理提醒"
        content.body = "您有未整理的靈感，讓創意不只停留在腦海。"
        content.sound = .default
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: setting.time)
        var trigger: UNNotificationTrigger?
        var identifier = "unorganized-reminder"
        switch setting.frequency {
        case .daily:
            trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
        case .weekly:
            if let weekday = setting.weekday {
                var weeklyComponents = timeComponents
                weeklyComponents.weekday = weekday
                trigger = UNCalendarNotificationTrigger(dateMatching: weeklyComponents, repeats: true)
                identifier += "-week\(weekday)"
            }
        case .monthly:
            if let day = setting.day {
                var monthlyComponents = timeComponents
                monthlyComponents.day = day
                trigger = UNCalendarNotificationTrigger(dateMatching: monthlyComponents, repeats: true)
                identifier += "-day\(day)"
            }
        }
        if let trigger = trigger {
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("設定未整理提醒失敗: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func cancelTaskReminder(for taskId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["task-\(taskId)"])
    }
    
    func cancelUnorganizedReminder() {
        // 移除所有相關識別碼
        var ids = ["unorganized-reminder"]
        for i in 1...7 { ids.append("unorganized-reminder-week\(i)") }
        for d in 1...31 { ids.append("unorganized-reminder-day\(d)") }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    /// 根據未整理靈感狀態決定是否安排推播
    func updateUnorganizedReminderIfNeeded(inspirations: [Inspiration], isOrganized: (Inspiration) -> Bool) {
        let hasUnorganized = inspirations.contains { !isOrganized($0) }
        if hasUnorganized {
            // 請在外部呼叫 scheduleUnorganizedReminder(setting:) 並傳入正確設定
            // scheduleUnorganizedReminder() // <-- 這行移除或註解
        } else {
            cancelUnorganizedReminder()
        }
    }
} 

// MARK: - 語言切換支援
fileprivate var bundleKey: UInt8 = 0
extension Bundle {
    static func setLanguage(_ language: String) {
        object_setClass(Bundle.main, PrivateBundle.self)
        objc_setAssociatedObject(Bundle.main, &bundleKey, language, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    private class PrivateBundle: Bundle, @unchecked Sendable {
        override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
            let language = objc_getAssociatedObject(self, &bundleKey) as? String
            guard let language = language,
                  let path = Bundle.main.path(forResource: language, ofType: "lproj"),
                  let bundle = Bundle(path: path) else {
                return super.localizedString(forKey: key, value: value, table: tableName)
            }
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }
    }
} 