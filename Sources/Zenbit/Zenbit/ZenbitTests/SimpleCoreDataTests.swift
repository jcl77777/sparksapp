import XCTest
import CoreData
@testable import Zenbit

class SimpleCoreDataTests: XCTestCase {
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
        
        coreDataManager = CoreDataManager()
        coreDataManager.persistentContainer = container
    }
    
    override func tearDownWithError() throws {
        coreDataManager = nil
    }
    
    func testCoreDataManagerInitialization() {
        XCTAssertNotNil(coreDataManager)
        XCTAssertNotNil(coreDataManager.context)
    }
    
    func testCoreDataSave() {
        // 測試 CoreData 是否可以正常儲存
        let context = coreDataManager.context
        
        // 創建一個測試物件（如果我們有 MeditationSession 的話）
        // 由於我們還沒有完整的 CoreData model，我們先測試基本的 context 功能
        XCTAssertNoThrow(try context.save())
    }
    
    func testViewModelInitialization() {
        let viewModel = MeditationSessionViewModel(coreDataManager: coreDataManager)
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.sessions.count, 0)
    }
} 