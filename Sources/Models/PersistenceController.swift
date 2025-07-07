import CoreData

struct PersistenceController {
    // Singleton instance for the app
    static let shared = PersistenceController()
    
    // Storage for Core Data
    let container: NSPersistentContainer
    
    // Initialize with optional in-memory configuration for testing/previews
    init(inMemory: Bool = false) {
        // 明確指定載入 .momd 的方式
        guard let modelURL = Bundle.main.url(forResource: "sparksModel", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("❌ Could not load Core Data model from momd")
        }
        
        container = NSPersistentContainer(name: "sparksModel", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("❌ Error loading Core Data store: \(error.localizedDescription)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // Preview instance for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Sample data can be added here if needed
        let viewContext = controller.container.viewContext
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("❌ Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
}
