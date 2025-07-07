import Foundation
import CoreData
import SwiftUI
import UIKit

// Use fully qualified type names to avoid ambiguity

// This class provides a centralized way to create and manage CoreData entities
// to avoid ambiguity issues and provide a clean API for entity creation
class CoreDataManager {
    
    // MARK: - Inspiration Entity Methods
    
    /// Creates a new Inspiration entity with the specified attributes
    /// - Parameters:
    ///   - context: The managed object context to create the entity in
    ///   - title: Title of the inspiration
    ///   - content: Optional text content
    ///   - imageData: Optional image data
    ///   - url: Optional URL string
    ///   - videoData: Optional video data
    ///   - type: Optional inspiration type
    ///   - isOrganized: Whether the inspiration is organized
    /// - Returns: The created Inspiration entity
    static func createInspiration(
        in context: NSManagedObjectContext,
        title: String,
        content: String? = nil,
        imageData: Data? = nil,
        url: String? = nil,
        videoData: Data? = nil,
        type: InspirationType? = nil,
        isOrganized: Bool? = false
    ) -> NSManagedObject {
        let inspiration = NSEntityDescription.insertNewObject(forEntityName: "Inspiration", into: context)
        inspiration.setValue(UUID(), forKey: "id")
        inspiration.setValue(title, forKey: "title")
        inspiration.setValue(content, forKey: "content")
        inspiration.setValue(imageData, forKey: "imageData")
        inspiration.setValue(url, forKey: "url")
        inspiration.setValue(videoData, forKey: "videoData")
        inspiration.setValue(type?.rawValue, forKey: "type")
        inspiration.setValue(isOrganized ?? false, forKey: "isOrganized")
        inspiration.setValue(Date(), forKey: "createdAt")
        inspiration.setValue(Date(), forKey: "updatedAt")
        
        return inspiration
    }
    
    /// Gets the inspiration type as an enum
    /// - Parameter inspiration: The inspiration entity
    /// - Returns: The inspiration type enum or nil if not set
    static func getInspirationType(_ inspiration: NSManagedObject) -> InspirationType? {
        guard let type = inspiration.value(forKey: "type") as? Int16 else { return nil }
        return InspirationType(rawValue: type)
    }
    
    /// Sets the inspiration type using the enum
    /// - Parameters:
    ///   - inspiration: The inspiration entity
    ///   - type: The inspiration type enum
    static func setInspirationType(_ inspiration: NSManagedObject, type: InspirationType?) {
        inspiration.setValue(type?.rawValue, forKey: "type")
    }
    
    /// Gets a preview image if available
    /// - Parameter inspiration: The inspiration entity
    /// - Returns: A SwiftUI Image or nil if no image data
    static func getPreviewImage(_ inspiration: NSManagedObject) -> Image? {
        if let imageData = inspiration.value(forKey: "imageData") as? Data, let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
    
    /// Gets a formatted creation date string
    /// - Parameter inspiration: The inspiration entity
    /// - Returns: A formatted date string
    static func getFormattedCreationDate(_ inspiration: NSManagedObject) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: inspiration.value(forKey: "createdAt") as? Date ?? Date())
    }
    
    // MARK: - Tag Entity Methods
    
    /// Creates a new Tag entity with the specified attributes
    /// - Parameters:
    ///   - context: The managed object context to create the entity in
    ///   - name: Name of the tag
    ///   - color: Hex color code for the tag
    /// - Returns: The created Tag entity
    static func createTag(
        in context: NSManagedObjectContext,
        name: String,
        color: String = "#007AFF"
    ) -> NSManagedObject {
        let tag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: context)
        tag.setValue(UUID(), forKey: "id")
        tag.setValue(name, forKey: "name")
        tag.setValue(color, forKey: "color")
        tag.setValue(Date(), forKey: "createdAt")
        
        return tag
    }
    
    /// Gets the tag color as a SwiftUI Color
    /// - Parameter tag: The tag entity
    /// - Returns: A SwiftUI Color
    static func getTagColor(_ tag: NSManagedObject) -> Color {
        return Color(hex: tag.value(forKey: "color") as? String ?? "#007AFF") ?? .blue
    }
    
    // MARK: - TaskItem Entity Methods
    
    /// Creates a new TaskItem entity with the specified attributes
    /// - Parameters:
    ///   - context: The managed object context to create the entity in
    ///   - title: Title of the task
    ///   - details: Optional details for the task
    ///   - status: Task status
    ///   - dueDate: Optional due date
    ///   - reminderDate: Optional reminder date
    ///   - inspiration: Optional related inspiration
    /// - Returns: The created TaskItem entity
    static func createTaskItem(
        in context: NSManagedObjectContext,
        title: String,
        details: String? = nil,
        status: TaskStatus = .pending,
        dueDate: Date? = nil,
        reminderDate: Date? = nil,
        inspiration: NSManagedObject? = nil
    ) -> NSManagedObject {
        let task = NSEntityDescription.insertNewObject(forEntityName: "TaskItem", into: context)
        task.setValue(UUID(), forKey: "id")
        task.setValue(title, forKey: "title")
        task.setValue(details, forKey: "details")
        task.setValue(status.rawValue, forKey: "status")
        task.setValue(dueDate, forKey: "dueDate")
        task.setValue(reminderDate, forKey: "reminderDate")
        task.setValue(Date(), forKey: "createdAt")
        task.setValue(Date(), forKey: "updatedAt")
        task.setValue(inspiration, forKey: "inspiration")
        
        return task
    }
    
    /// Gets the task status as an enum
    /// - Parameter taskItem: The task item entity
    /// - Returns: The task status enum
    static func getTaskStatus(_ taskItem: NSManagedObject) -> TaskStatus {
        return TaskStatus(rawValue: taskItem.value(forKey: "status") as? Int16 ?? 0) ?? .pending
    }
    
    /// Sets the task status using the enum
    /// - Parameters:
    ///   - taskItem: The task item entity
    ///   - status: The task status enum
    static func setTaskStatus(_ taskItem: NSManagedObject, status: TaskStatus) {
        taskItem.setValue(status.rawValue, forKey: "status")
        taskItem.setValue(Date(), forKey: "updatedAt")
    }
    
    /// Gets a formatted due date string if available
    /// - Parameter taskItem: The task item entity
    /// - Returns: A formatted date string or nil if no due date
    static func getFormattedDueDate(_ taskItem: NSManagedObject) -> String? {
        guard let date = taskItem.value(forKey: "dueDate") as? Date else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
    
    /// Gets a formatted reminder date string if available
    /// - Parameter taskItem: The task item entity
    /// - Returns: A formatted date string or nil if no reminder date
    static func getFormattedReminderDate(_ taskItem: NSManagedObject) -> String? {
        guard let date = taskItem.value(forKey: "reminderDate") as? Date else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
}

// MARK: - Helper Extensions

// Helper extension to create Color from hex string
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
