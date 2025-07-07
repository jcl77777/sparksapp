# tasks.md

## 🚧 開發任務清單（以 SwiftUI + CoreData 為基礎）

每項任務皆包含明確的 **Start** 與 **End** 說明，便於使用 LLM IDE（如 Windsurf）逐步開發與測試。

### ✅ 初始化與設定

1. 初始化 SwiftUI 專案（App Entry）

   * **Start**: 開啟 Xcode 並建立一個新的 SwiftUI App 專案
   * **End**: 專案能成功編譯並顯示 Hello, world 畫面

2. 建立 CoreData Model 檔案並設計三個 Entity（Inspiration、TaskItem、Tag）

   * **Start**: 開啟 `.xcdatamodeld` 並新增空白模型，定義欄位（如 title、type、createdAt 等）
   * **End**: 成功建立三個 Entity 並包含必要欄位，能在程式中以 NSManagedObject 使用

3. 設定 PersistentContainer 並整合至 App lifecycle

   * **Start**: 在 AppDelegate 或 Persistence 檔案中新增 Container 初始化
   * **End**: 可以成功存取空的資料庫

...

### 🧰 任務管理區

25. 建立 TaskListView（待辦清單）

    * **Start**: 建立一個 TaskListView 顯示所有任務清單，區分狀態
    * **End**: 畫面可列出任務，分為待處理、進行中、已完成三類

26. 支援三種狀態分類（待處理、進行中、已完成）

    * **Start**: 在 Task Entity 中加入狀態欄位，並提供切換 UI
    * **End**: 使用者可修改任務狀態並更新資料

27. 任務資料綁定 Task Entity

    * **Start**: 在 TaskListView 中使用 @FetchRequest 顯示任務資料
    * **End**: 任務清單可從 CoreData 正確讀取顯示

28. 實作新增、編輯、完成任務 UI 與邏輯

    * **Start**: 加入新增任務按鈕並跳轉編輯畫面
    * **End**: 可新增/編輯任務內容並更新狀態，支援完成勾選

29. 支援提醒設定（時間與通知）

    * **Start**: 在任務編輯畫面加入時間選擇器
    * **End**: 可設定提醒時間並成功排程通知

30. 建立任務與原始 Inspiration 的連結關係

    * **Start**: 在 Task Entity 中加入對應 Inspiration 的關聯欄位
    * **End**: 任務項目中可點選連回原始靈感資料

---

### 🔧 設定 Settings

31. 建立 SettingsView（顯示版本、設定選項）

    * **Start**: 建立簡易畫面顯示 App 版本與設定入口
    * **End**: 畫面可進入其他設定項目，如通知、標籤管理等

32. 加入 NotificationSettingsView（提醒開關與頻率）

    * **Start**: 新增提醒時間與頻率控制元件
    * **End**: 使用者可調整每日提醒時間並存入設定

33. 設定預設標籤管理功能

    * **Start**: 加入預設標籤清單編輯器（增刪改）
    * **End**: 使用者可修改預設標籤並儲存至本地資料

---

### 🔔 本機通知

34. 請求 Notification 權限

    * **Start**: 使用 UNUserNotificationCenter 請求使用者授權
    * **End**: 系統提示允許通知並回傳授權結果

35. 建立 NotificationManager

    * **Start**: 新增一個 Utility class 專責排程與取消通知
    * **End**: 提供封裝 API：`schedule(id:at:body:)` 與 `cancel(id:)`

36. 新增每日未整理提醒通知排程

    * **Start**: 在 App 啟動時檢查是否排程每日提醒
    * **End**: 若未排程，則依設定時間建立每日通知，顯示未整理靈感數

---

### 🌟 延伸（非 MVP 可延後）

37. iCloud CoreData sync 實作

    * **Start**: 啟用 iCloud capability 並修改 CoreData stack 加入 NSPersistentCloudKitContainer
    * **End**: 實現跨裝置資料同步與 conflict 解決

38. 自動備份匯出功能

    * **Start**: 加入按鈕將資料導出為 JSON 或 TXT 格式
    * **End**: 成功匯出並透過分享選單傳送檔案

39. 深色模式 + 字型大小偏好設定

    * **Start**: 使用者設定選項加入外觀調整元件（如 Toggle, Stepper）
    * **End**: App UI 依使用者偏好變更主題與字級

40. App icon 與 launch screen 美化

    * **Start**: 設計並替換 App icon 與 LaunchScreen.storyboard
    * **End**: 啟動畫面與 icon 呈現品牌風格與統一視覺

---

