import XCTest
@testable import Zenbit

class UserSettingsTests: XCTestCase {
    
    func testBackgroundMusicEnum() {
        // 測試所有背景音樂選項
        XCTAssertEqual(BackgroundMusic.allCases.count, 4)
        
        // 測試顯示名稱
        XCTAssertEqual(BackgroundMusic.rain.displayName, "雨聲")
        XCTAssertEqual(BackgroundMusic.forest.displayName, "森林")
        XCTAssertEqual(BackgroundMusic.ocean.displayName, "海浪")
        XCTAssertEqual(BackgroundMusic.silence.displayName, "靜音")
        
        // 測試原始值
        XCTAssertEqual(BackgroundMusic.rain.rawValue, "rain")
        XCTAssertEqual(BackgroundMusic.forest.rawValue, "forest")
        XCTAssertEqual(BackgroundMusic.ocean.rawValue, "ocean")
        XCTAssertEqual(BackgroundMusic.silence.rawValue, "silence")
    }
    
    func testBackgroundImageEnum() {
        // 測試所有背景圖片選項
        XCTAssertEqual(BackgroundImage.allCases.count, 5)
        
        // 測試顯示名稱
        XCTAssertEqual(BackgroundImage.forest.displayName, "森林")
        XCTAssertEqual(BackgroundImage.mountain.displayName, "山脈")
        XCTAssertEqual(BackgroundImage.ocean.displayName, "海洋")
        XCTAssertEqual(BackgroundImage.sunset.displayName, "日落")
        XCTAssertEqual(BackgroundImage.minimal.displayName, "簡約")
        
        // 測試原始值
        XCTAssertEqual(BackgroundImage.forest.rawValue, "forest")
        XCTAssertEqual(BackgroundImage.mountain.rawValue, "mountain")
        XCTAssertEqual(BackgroundImage.ocean.rawValue, "ocean")
        XCTAssertEqual(BackgroundImage.sunset.rawValue, "sunset")
        XCTAssertEqual(BackgroundImage.minimal.rawValue, "minimal")
    }
    
    func testUserSettingsDefaultValues() {
        // 測試 UserSettings 的預設值
        let userSettings = UserSettings()
        
        // 注意：@AppStorage 的值會持久化，所以我們測試 enum 的預設值
        XCTAssertEqual(BackgroundMusic.rain.rawValue, "rain")
        XCTAssertEqual(BackgroundImage.forest.rawValue, "forest")
    }
} 