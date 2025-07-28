import Foundation

enum InspirationType: Int16, CaseIterable, Identifiable {
    case text = 0
    case image = 1
    case url = 2
    case video = 3
    
    var id: Int16 { self.rawValue }
    
    var name: String {
        switch self {
        case .text:
            return "Text"
        case .image:
            return "Image"
        case .url:
            return "URL"
        case .video:
            return "Video"
        }
    }
    
    var iconName: String {
        switch self {
        case .text:
            return "doc.text"
        case .image:
            return "photo"
        case .url:
            return "link"
        case .video:
            return "video"
        }
    }
}

enum TaskStatus: Int16, CaseIterable, Identifiable {
    case pending = 0
    case inProgress = 1
    case completed = 2
    
    var id: Int16 { self.rawValue }
    
    var name: String {
        switch self {
        case .pending:
            return NSLocalizedString("taskstatus_todo", comment: "待處理")
        case .inProgress:
            return NSLocalizedString("taskstatus_doing", comment: "進行中")
        case .completed:
            return NSLocalizedString("taskstatus_done", comment: "已完成")
        }
    }
    
    var iconName: String {
        switch self {
        case .pending:
            return "circle"
        case .inProgress:
            return "clock"
        case .completed:
            return "checkmark.circle"
        }
    }
}
