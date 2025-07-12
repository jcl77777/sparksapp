import Foundation
import CoreData
import Combine

@MainActor
class InspirationViewModel: ObservableObject {
    @Published var inspirations: [Inspiration] = []
    @Published var availableTags: [Tag] = []
    private var cancellables = Set<AnyCancellable>()
    
    private let context: NSManagedObjectContext
    
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
        } catch {
            print("Error fetching tags: \(error)")
            availableTags = []
        }
    }
    
    // MARK: - Create
    func addInspiration(title: String, content: String = "", type: Int16 = 0, tagNames: [String] = []) {
        let newInspiration = Inspiration(context: context)
        newInspiration.title = title
        newInspiration.content = content
        newInspiration.type = type
        newInspiration.createdAt = Date()
        
        // 加入標籤
        for tagName in tagNames {
            addTagToInspiration(inspiration: newInspiration, tagName: tagName)
        }
        
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
        if let existingTags = inspiration.tag as? NSSet {
            inspiration.removeFromTag(existingTags)
        }
        
        // 加入新標籤
        for tagName in tagNames {
            addTagToInspiration(inspiration: inspiration, tagName: tagName)
        }
        
        saveContext()
        fetchInspirations()
    }
    
    // MARK: - Delete
    func deleteInspiration(_ inspiration: Inspiration) {
        context.delete(inspiration)
        saveContext()
        fetchInspirations()
    }
    
    // MARK: - Tag Management
    private func addTagToInspiration(inspiration: Inspiration, tagName: String) {
        // 尋找現有標籤或建立新標籤
        let tag = findOrCreateTag(name: tagName)
        
        // 建立關係
        let inspirationTags = inspiration.mutableSetValue(forKey: "tag")
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
        newTag.name = name
        newTag.color = "blue" // 預設顏色
        newTag.createdAt = Date()
        
        return newTag
    }
    
    func getTagNames(for inspiration: Inspiration) -> [String] {
        guard let tags = inspiration.tag as? Set<Tag> else { return [] }
        return tags.compactMap { $0.name }.sorted()
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