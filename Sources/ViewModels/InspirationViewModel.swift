import Foundation
import CoreData
import Combine

@MainActor
class InspirationViewModel: ObservableObject {
    @Published var inspirations: [Inspiration] = []
    private var cancellables = Set<AnyCancellable>()
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchInspirations()
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
    
    // MARK: - Create
    func addInspiration(title: String, content: String = "", type: Int16 = 0) {
        let newInspiration = Inspiration(context: context)
        newInspiration.title = title
        newInspiration.content = content
        newInspiration.type = type
        newInspiration.createdAt = Date()
        saveContext()
        fetchInspirations()
    }
    
    // MARK: - Update
    func updateInspiration(_ inspiration: Inspiration, title: String, content: String, type: Int16) {
        inspiration.title = title
        inspiration.content = content
        inspiration.type = type
        inspiration.updatedAt = Date()
        saveContext()
        fetchInspirations()
    }
    
    // MARK: - Delete
    func deleteInspiration(_ inspiration: Inspiration) {
        context.delete(inspiration)
        saveContext()
        fetchInspirations()
    }
    
    // MARK: - Save
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
} 