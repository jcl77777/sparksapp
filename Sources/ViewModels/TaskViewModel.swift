import Foundation
import CoreData
import Combine

@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    private var cancellables = Set<AnyCancellable>()
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchTasks()
    }
    
    // MARK: - Read
    func fetchTasks() {
        let request: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
            tasks = []
        }
    }
    
    // MARK: - Create
    func addTask(title: String, details: String? = nil, inspiration: Inspiration? = nil) {
        let newTask = TaskItem(context: context)
        newTask.id = UUID()
        newTask.title = title
        newTask.details = details
        newTask.status = TaskStatus.pending.rawValue
        newTask.createdAt = Date()
        newTask.updatedAt = Date()
        
        // 建立與靈感的關聯
        if let inspiration = inspiration {
            newTask.inspiration = inspiration
        }
        
        saveContext()
        fetchTasks()
    }
    
    // MARK: - Update
    func updateTask(_ task: TaskItem, title: String, details: String?) {
        task.title = title
        task.details = details
        task.updatedAt = Date()
        saveContext()
        fetchTasks()
    }
    
    func updateTaskStatus(_ task: TaskItem, status: TaskStatus) {
        task.status = status.rawValue
        task.updatedAt = Date()
        saveContext()
        fetchTasks()
    }
    
    // MARK: - Delete
    func deleteTask(_ task: TaskItem) {
        context.delete(task)
        saveContext()
        fetchTasks()
    }
    
    // MARK: - Filtering
    func getTasksByStatus(_ status: TaskStatus) -> [TaskItem] {
        return tasks.filter { $0.status == status.rawValue }
    }
    
    func getTasksWithInspiration() -> [TaskItem] {
        return tasks.filter { $0.inspiration != nil }
    }
    
    func getTasksWithoutInspiration() -> [TaskItem] {
        return tasks.filter { $0.inspiration == nil }
    }
    
    // MARK: - Helper Methods
    func getTaskStatus(_ task: TaskItem) -> TaskStatus {
        return TaskStatus(rawValue: task.status) ?? .pending
    }
    
    func getFormattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Save
    func saveContext() {
        do {
            try context.save()
            fetchTasks()
        } catch {
            print("Error saving context: \(error)")
        }
    }
} 