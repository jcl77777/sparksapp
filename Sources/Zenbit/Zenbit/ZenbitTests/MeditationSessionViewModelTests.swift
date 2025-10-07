import XCTest
import CoreData
@testable import Zenbit

class MeditationSessionViewModelTests: XCTestCase {
    var viewModel: MeditationSessionViewModel!
    var coreDataManager: CoreDataManager!
    
    override func setUpWithError() throws {
        // 使用記憶體中的 Core Data 堆疊進行測試
        let container = NSPersistentContainer(name: "Zenbit")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("測試 Core Data 載入失敗: \(error)")
            }
        }
        
        // 創建測試用的 CoreDataManager
        coreDataManager = CoreDataManager()
        coreDataManager.persistentContainer = container
        
        viewModel = MeditationSessionViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        coreDataManager = nil
    }
    
    // MARK: - CRUD Tests
    
    func testCreateSession() {
        // Given
        let duration: Int32 = 120
        let mood = "平靜"
        let notes = "測試冥想記錄"
        
        // When
        viewModel.createSession(duration: duration, mood: mood, notes: notes)
        
        // Then
        XCTAssertEqual(viewModel.sessions.count, 1)
        XCTAssertEqual(viewModel.sessions.first?.duration, duration)
        XCTAssertEqual(viewModel.sessions.first?.mood, mood)
        XCTAssertEqual(viewModel.sessions.first?.notes, notes)
        XCTAssertNotNil(viewModel.sessions.first?.sessionId)
        XCTAssertNotNil(viewModel.sessions.first?.createdAt)
    }
    
    func testFetchSessions() {
        // Given
        viewModel.createSession(duration: 60, mood: "專注", notes: "第一次")
        viewModel.createSession(duration: 90, mood: "滿足", notes: "第二次")
        
        // When
        viewModel.fetchSessions()
        
        // Then
        XCTAssertEqual(viewModel.sessions.count, 2)
        XCTAssertEqual(viewModel.sessions.first?.mood, "滿足") // 最新的在前面
    }
    
    func testUpdateSession() {
        // Given
        viewModel.createSession(duration: 60, mood: "平靜", notes: "原始記錄")
        let session = viewModel.sessions.first!
        
        // When
        viewModel.updateSession(session, duration: 120, mood: "更新後", notes: "更新記錄")
        
        // Then
        XCTAssertEqual(session.duration, 120)
        XCTAssertEqual(session.mood, "更新後")
        XCTAssertEqual(session.notes, "更新記錄")
    }
    
    func testDeleteSession() {
        // Given
        viewModel.createSession(duration: 60, mood: "平靜", notes: "要刪除的記錄")
        XCTAssertEqual(viewModel.sessions.count, 1)
        
        // When
        let session = viewModel.sessions.first!
        viewModel.deleteSession(session)
        
        // Then
        XCTAssertEqual(viewModel.sessions.count, 0)
    }
    
    // MARK: - Statistics Tests
    
    func testTotalSessions() {
        // Given
        viewModel.createSession(duration: 60, mood: "平靜", notes: "")
        viewModel.createSession(duration: 90, mood: "滿足", notes: "")
        viewModel.createSession(duration: 120, mood: "專注", notes: "")
        
        // When & Then
        XCTAssertEqual(viewModel.totalSessions, 3)
    }
    
    func testTotalMinutes() {
        // Given
        viewModel.createSession(duration: 60, mood: "平靜", notes: "")
        viewModel.createSession(duration: 90, mood: "滿足", notes: "")
        viewModel.createSession(duration: 120, mood: "專注", notes: "")
        
        // When & Then
        XCTAssertEqual(viewModel.totalMinutes, 270) // 60 + 90 + 120
    }
    
    func testAverageSessionLength() {
        // Given
        viewModel.createSession(duration: 60, mood: "平靜", notes: "")
        viewModel.createSession(duration: 90, mood: "滿足", notes: "")
        viewModel.createSession(duration: 120, mood: "專注", notes: "")
        
        // When & Then
        XCTAssertEqual(viewModel.averageSessionLength, 90.0) // (60 + 90 + 120) / 3
    }
    
    func testAverageSessionLengthWithNoSessions() {
        // When & Then
        XCTAssertEqual(viewModel.averageSessionLength, 0.0)
    }
    
    // MARK: - Date Filtering Tests
    
    func testSessionsForDate() {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        viewModel.createSession(duration: 60, mood: "今天", notes: "")
        viewModel.createSession(duration: 90, mood: "昨天", notes: "")
        
        // When
        let todaySessions = viewModel.sessionsForDate(today)
        let yesterdaySessions = viewModel.sessionsForDate(yesterday)
        
        // Then
        XCTAssertEqual(todaySessions.count, 1)
        XCTAssertEqual(todaySessions.first?.mood, "今天")
        XCTAssertEqual(yesterdaySessions.count, 1)
        XCTAssertEqual(yesterdaySessions.first?.mood, "昨天")
    }
    
    func testTodaySessions() {
        // Given
        viewModel.createSession(duration: 60, mood: "今天", notes: "")
        
        // When
        let todaySessions = viewModel.todaySessions()
        
        // Then
        XCTAssertEqual(todaySessions.count, 1)
        XCTAssertEqual(todaySessions.first?.mood, "今天")
    }
    
    func testTodayMinutes() {
        // Given
        viewModel.createSession(duration: 60, mood: "今天1", notes: "")
        viewModel.createSession(duration: 90, mood: "今天2", notes: "")
        
        // When & Then
        XCTAssertEqual(viewModel.todayMinutes, 150) // 60 + 90
    }
    
    // MARK: - Preview Data Tests
    
    func testCreatePreviewData() {
        // When
        viewModel.createPreviewData()
        
        // Then
        XCTAssertEqual(viewModel.sessions.count, 5)
        XCTAssertEqual(viewModel.totalMinutes, 495) // 60 + 120 + 90 + 45 + 180
    }
    
    func testClearAllSessions() {
        // Given
        viewModel.createSession(duration: 60, mood: "平靜", notes: "")
        viewModel.createSession(duration: 90, mood: "滿足", notes: "")
        XCTAssertEqual(viewModel.sessions.count, 2)
        
        // When
        viewModel.clearAllSessions()
        
        // Then
        XCTAssertEqual(viewModel.sessions.count, 0)
        XCTAssertEqual(viewModel.totalSessions, 0)
        XCTAssertEqual(viewModel.totalMinutes, 0)
    }
} 