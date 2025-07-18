import CoreData

struct PersistenceController {
    // Singleton instance for the app
    static let shared = PersistenceController()
    
    // Storage for Core Data
    let container: NSPersistentContainer
    
    // Initialize with optional in-memory configuration for testing/previews
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "sparksModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ Error loading Core Data store: \(error.localizedDescription)")
                // 不要 fatalError，讓 app 繼續運行
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
            print("❌ Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
}
