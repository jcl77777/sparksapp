# Task 1: 建立 UserSettings model 並儲存到 AppStorage

## ✅ 完成狀態

**開始條件：** 建立 UserSettings struct 並使用 @AppStorage 儲存每日目標、音樂、背景設定
**完成條件：** 設定儲存可用於首頁與設定畫面

## 🏗️ 實作內容

### 1. UserSettings Model
- **檔案：** `Zenbit/Models/UserSettings.swift`
- **功能：**
  - 使用 `@AppStorage` 持久化儲存使用者設定
  - 每日目標（1-10次）
  - 背景音樂選項（雨聲、森林、海浪、靜音）
  - 背景圖片選項（森林、山脈、海洋、日落、簡約）
  - HealthKit 授權狀態
  - 首次使用標記

### 2. BackgroundMusic Enum
- **選項：** rain、forest、ocean、silence
- **顯示名稱：** 雨聲、森林、海浪、靜音
- **功能：** 提供背景音樂選項供使用者選擇

### 3. BackgroundImage Enum
- **選項：** forest、mountain、ocean、sunset、minimal
- **顯示名稱：** 森林、山脈、海洋、日落、簡約
- **功能：** 提供背景圖片選項供使用者選擇

### 4. HomeView
- **檔案：** `Zenbit/Views/HomeView.swift`
- **功能：**
  - 顯示 App 標題和副標題
  - 顯示當前設定的每日目標
  - 顯示選擇的背景音樂和圖片
  - 使用 NavigationView 包裝

### 5. SettingsView
- **檔案：** `Zenbit/Views/SettingsView.swift`
- **功能：**
  - 每日目標調整器（Stepper，1-10次）
  - 背景音樂選擇器（Picker）
  - 背景圖片選擇器（Picker）
  - 使用 Form 和 Section 組織

### 6. ContentView
- **檔案：** `ContentView.swift`
- **功能：**
  - 使用 TabView 組織導航
  - 首頁標籤（HomeView）
  - 設定標籤（SettingsView）

### 7. 測試覆蓋
- **檔案：** `ZenbitTests/UserSettingsTests.swift`
- **測試內容：**
  - BackgroundMusic enum 測試
  - BackgroundImage enum 測試
  - UserSettings 預設值測試

## 📱 使用方式

### 在 App 中測試
1. 啟動應用程式
2. 點擊「設定」標籤
3. 調整每日目標（1-10次）
4. 選擇背景音樂（雨聲、森林、海浪、靜音）
5. 選擇背景圖片（森林、山脈、海洋、日落、簡約）
6. 返回「首頁」查看設定是否正確顯示

### 程式碼使用範例
```swift
// 建立 UserSettings
let userSettings = UserSettings()

// 讀取設定
print("每日目標：\(userSettings.dailyGoal) 次")
print("背景音樂：\(userSettings.backgroundMusic)")
print("背景圖片：\(userSettings.backgroundImage)")

// 修改設定
userSettings.dailyGoal = 3
userSettings.backgroundMusic = "ocean"
userSettings.backgroundImage = "sunset"
```

## 🎯 完成驗證

### ✅ 已完成的項目
1. **UserSettings Model** - 使用 @AppStorage 持久化儲存
2. **BackgroundMusic Enum** - 4種背景音樂選項
3. **BackgroundImage Enum** - 5種背景圖片選項
4. **HomeView** - 首頁顯示當前設定
5. **SettingsView** - 設定頁面可編輯所有選項
6. **ContentView** - TabView 導航
7. **測試覆蓋** - 完整的單元測試

### 🔄 與後續任務的整合
- **Task 3:** HomeView 將顯示今日進度與目標條
- **Task 5:** SettingsView 將加入更多設定選項
- **Task 6:** 背景音樂和圖片將用於 ZenbitView

## 📊 檔案結構

```
Zenbit/
├── Models/
│   └── UserSettings.swift
├── Views/
│   ├── HomeView.swift
│   └── SettingsView.swift
└── ZenbitApp.swift

ContentView.swift
ZenbitTests/
└── UserSettingsTests.swift
```

## 🚀 下一步

Task 1 已完成，可以開始 **Task 2: 建立 MeditationSession CoreData Entity 結構**。 