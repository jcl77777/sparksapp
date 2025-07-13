import Foundation
import CoreData
import Combine

@MainActor
class InspirationViewModel: ObservableObject {
    @Published var inspirations: [Inspiration] = []
    @Published var availableTags: [Tag] = []
    private var cancellables = Set<AnyCancellable>()
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchInspirations()
        fetchTags()
    }
    
    // MARK: - Read
    func fetchInspirations() {
        let request: NSFetchRequest<Inspiration> = Inspiration.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            inspirations = try context.fetch(request)
        } catch {
            print("Error fetching inspirations: \(error)")
            inspirations = []
        }
    }
    
    func fetchTags() {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            availableTags = try context.fetch(request)
            // 若標籤池為空，自動建立預設標籤
            if availableTags.isEmpty {
                let defaultTags = ["個人", "工作", "重要", "生活", "其他"]
                for tagName in defaultTags {
                    let tag = Tag(context: context)
                    tag.id = UUID()
                    tag.name = tagName
                    tag.color = "blue"
                    tag.createdAt = Date()
                }
                try context.save()
                // 重新 fetch
                availableTags = try context.fetch(request)
            }
        } catch {
            print("Error fetching tags: \(error)")
            availableTags = []
        }
    }
    
    // MARK: - Create
    func addInspiration(title: String, content: String = "", type: Int16 = 0, tagNames: [String] = []) -> Inspiration {
        let newInspiration = Inspiration(context: context)
        newInspiration.id = UUID()
        newInspiration.title = title
        newInspiration.content = content
        newInspiration.type = type
        newInspiration.createdAt = Date()
        newInspiration.updatedAt = Date()
        for tagName in tagNames {
            addTagToInspiration(inspiration: newInspiration, tagName: tagName)
        }
        saveContext()
        fetchInspirations()
        return newInspiration
    }
    
    func addURLInspiration(title: String, content: String = "", url: String) {
        let newInspiration = Inspiration(context: context)
        newInspiration.id = UUID()
        newInspiration.title = title
        newInspiration.content = content
        newInspiration.url = url
        newInspiration.type = 2 // 網址類型
        newInspiration.createdAt = Date()
        newInspiration.updatedAt = Date()
        
        saveContext()
        fetchInspirations()
    }
    
    // MARK: - Update
    func updateInspiration(_ inspiration: Inspiration, title: String, content: String, type: Int16, tagNames: [String]) {
        inspiration.title = title
        inspiration.content = content
        inspiration.type = type
        inspiration.updatedAt = Date()
        
        // 清除現有標籤
        if let existingTags = inspiration.tags as? Set<Tag> {
            for tag in existingTags {
                inspiration.removeFromTags(tag)
            }
        }
        
        // 加入新標籤
        for tagName in tagNames {
            addTagToInspiration(inspiration: inspiration, tagName: tagName)
        }
        
        saveContext()
        fetchInspirations()
    }
    
    // MARK: - Organization Management
    func isOrganized(_ inspiration: Inspiration) -> Bool {
        guard let taskItems = inspiration.taskItems as? Set<TaskItem> else { return false }
        return !taskItems.isEmpty
    }
    
    func getTaskCount(for inspiration: Inspiration) -> Int {
        guard let taskItems = inspiration.taskItems as? Set<TaskItem> else { return 0 }
        return taskItems.count
    }
    
    func getTasks(for inspiration: Inspiration) -> [TaskItem] {
        guard let taskItems = inspiration.taskItems as? Set<TaskItem> else { return [] }
        return Array(taskItems).sorted { $0.createdAt ?? Date() > $1.createdAt ?? Date() }
    }
    
    // MARK: - Delete
    func deleteInspiration(_ inspiration: Inspiration) {
        // 先解除所有關聯任務的靈感連結
        if let taskItems = inspiration.taskItems as? Set<TaskItem> {
            for task in taskItems {
                task.inspiration = nil
            }
        }
        context.delete(inspiration)
        saveContext()
        fetchInspirations()
    }
    
    // MARK: - Tag Management
    private func addTagToInspiration(inspiration: Inspiration, tagName: String) {
        // 尋找現有標籤或建立新標籤
        let tag = findOrCreateTag(name: tagName)
        
        // 建立關係
        let inspirationTags = inspiration.mutableSetValue(forKey: "tags")
        inspirationTags.add(tag)
    }
    
    private func findOrCreateTag(name: String) -> Tag {
        // 先尋找現有標籤
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let existingTags = try context.fetch(request)
            if let existingTag = existingTags.first {
                return existingTag
            }
        } catch {
            print("Error finding tag: \(error)")
        }
        
        // 建立新標籤
        let newTag = Tag(context: context)
        newTag.id = UUID()
        newTag.name = name
        newTag.color = "blue" // 預設顏色
        newTag.createdAt = Date()
        
        return newTag
    }
    
    func getTagNames(for inspiration: Inspiration) -> [String] {
        guard let tags = inspiration.tags as? Set<Tag> else { return [] }
        return tags.compactMap { $0.name }.sorted()
    }
    
    // MARK: - Tag CRUD for SettingsView
    func addTag(name: String) {
        let tag = Tag(context: context)
        tag.id = UUID()
        tag.name = name
        tag.color = "blue"
        tag.createdAt = Date()
        saveContext()
        fetchTags()
    }
    func updateTag(tag: Tag, newName: String) {
        tag.name = newName
        saveContext()
        fetchTags()
    }
    func deleteTag(tag: Tag) {
        context.delete(tag)
        saveContext()
        fetchTags()
    }
    
    // MARK: - Task Management
    func addTask(title: String, details: String? = nil, inspiration: Inspiration? = nil) {
        let newTask = TaskItem(context: context)
        newTask.id = UUID()
        newTask.title = title
        newTask.details = details
        newTask.createdAt = Date()
        newTask.updatedAt = Date()
        
        // 建立與靈感的關聯
        if let inspiration = inspiration {
            newTask.inspiration = inspiration
        }
        
        saveContext()
        fetchInspirations()
    }
    
    func deleteTask(_ task: TaskItem) {
        context.delete(task)
        saveContext()
        fetchInspirations()
    }
    
    // MARK: - Save
    func saveContext() {
        do {
            try context.save()
            fetchInspirations()
            fetchTags()
        } catch {
            print("Error saving context: \(error)")
        }
    }
} 