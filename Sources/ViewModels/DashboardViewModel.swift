import Foundation
import CoreData
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var todayInspirations: Int = 0
    @Published var todayTasks: Int = 0
    @Published var totalInspirations: Int = 0
    @Published var totalTasks: Int = 0
    @Published var pendingTasks: Int = 0
    @Published var inProgressTasks: Int = 0
    @Published var completedTasks: Int = 0
    @Published var organizedInspirations: Int = 0
    @Published var unorganizedInspirations: Int = 0
    @Published var weeklyInspirationData: [Date: Int] = [:]
    
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        calculateStatistics()
    }
    
    func calculateStatistics() {
        calculateTodayStats()
        calculateTotalStats()
        calculateTaskStats()
        calculateOrganizationStats()
        calculateWeeklyTrend()
    }
    
    private func calculateTodayStats() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // 今日新增靈感
        let inspirationRequest: NSFetchRequest<Inspiration> = Inspiration.fetchRequest()
        inspirationRequest.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@", today as NSDate, tomorrow as NSDate)
        
        do {
            todayInspirations = try context.count(for: inspirationRequest)
        } catch {
            print("Error counting today inspirations: \(error)")
            todayInspirations = 0
        }
        
        // 今日新增任務
        let taskRequest: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        taskRequest.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@", today as NSDate, tomorrow as NSDate)
        
        do {
            todayTasks = try context.count(for: taskRequest)
        } catch {
            print("Error counting today tasks: \(error)")
            todayTasks = 0
        }
    }
    
    private func calculateTotalStats() {
        // 總靈感數
        let inspirationRequest: NSFetchRequest<Inspiration> = Inspiration.fetchRequest()
        do {
            totalInspirations = try context.count(for: inspirationRequest)
        } catch {
            print("Error counting total inspirations: \(error)")
            totalInspirations = 0
        }
        
        // 總任務數
        let taskRequest: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        do {
            totalTasks = try context.count(for: taskRequest)
        } catch {
            print("Error counting total tasks: \(error)")
            totalTasks = 0
        }
    }
    
    private func calculateTaskStats() {
        // 待處理任務
        let pendingRequest: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        pendingRequest.predicate = NSPredicate(format: "status == %d", TaskStatus.pending.rawValue)
        do {
            pendingTasks = try context.count(for: pendingRequest)
        } catch {
            print("Error counting pending tasks: \(error)")
            pendingTasks = 0
        }
        
        // 進行中任務
        let inProgressRequest: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        inProgressRequest.predicate = NSPredicate(format: "status == %d", TaskStatus.inProgress.rawValue)
        do {
            inProgressTasks = try context.count(for: inProgressRequest)
        } catch {
            print("Error counting in-progress tasks: \(error)")
            inProgressTasks = 0
        }
        
        // 已完成任務
        let completedRequest: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        completedRequest.predicate = NSPredicate(format: "status == %d", TaskStatus.completed.rawValue)
        do {
            completedTasks = try context.count(for: completedRequest)
        } catch {
            print("Error counting completed tasks: \(error)")
            completedTasks = 0
        }
    }
    
    private func calculateOrganizationStats() {
        // 已整理靈感（有關聯任務的）
        let organizedRequest: NSFetchRequest<Inspiration> = Inspiration.fetchRequest()
        organizedRequest.predicate = NSPredicate(format: "taskitem.@count > 0")
        do {
            organizedInspirations = try context.count(for: organizedRequest)
        } catch {
            print("Error counting organized inspirations: \(error)")
            organizedInspirations = 0
        }
        
        // 未整理靈感（沒有關聯任務的）
        let unorganizedRequest: NSFetchRequest<Inspiration> = Inspiration.fetchRequest()
        unorganizedRequest.predicate = NSPredicate(format: "taskitem.@count == 0")
        do {
            unorganizedInspirations = try context.count(for: unorganizedRequest)
        } catch {
            print("Error counting unorganized inspirations: \(error)")
            unorganizedInspirations = 0
        }
    }
    
    private func calculateWeeklyTrend() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var weeklyData: [Date: Int] = [:]
        
        // 計算過去7天的資料
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
                
                let request: NSFetchRequest<Inspiration> = Inspiration.fetchRequest()
                request.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@", date as NSDate, nextDate as NSDate)
                
                do {
                    let count = try context.count(for: request)
                    weeklyData[date] = count
                } catch {
                    print("Error counting inspirations for date \(date): \(error)")
                    weeklyData[date] = 0
                }
            }
        }
        
        weeklyInspirationData = weeklyData
    }
    
    func refresh() {
        calculateStatistics()
    }
} 