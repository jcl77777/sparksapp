# Zenbit - Architecture

## 🧱 Stack 選擇

- **Frontend**: SwiftUI（iOS 17+）
- **State 管理**: 使用 `ObservableObject` + `AppStorage/UserDefaults` 管理輕量級設定與單頁狀態。預期在 Phase 2–3 中多畫面協同與進度串接情境，將導入 `@StateObject` 或 `Combine` Publisher 架構以強化狀態一致性與複雜資料流反應。
- **資料儲存**: CoreData（冥想紀錄）、AppStorage（設定）
- **音樂播放**: 採用 `AVFoundation` 進行背景音播放。未來在 Premium 功能中將擴展以下能力：
    -  背景音與語音導引混音
    - 與 Spotify / Apple Music 整合（透過 MediaPlayer / MusicKit）
    - 音頻檔案管理模組（支援本地與遠端音源）
- **Apple HealthKit**: 用於同步冥想紀錄
- **金流（Phase 3）**: StoreKit + RevenueCat（管理 IAP）
- **WidgetKit**: 提供首頁小工具支援，使用 `WidgetKit` 建立進度展示與快捷啟動入口。資料同步透過 `AppGroup` 與主應用共享，但需處理：
    - 小工具資料一致性（定期同步 + 手動刷新）
    - 使用 `WidgetCenter.shared.reloadAllTimelines()` 驅動更新
- **圖表統計**: Swift Charts
- i18n: English & Mandarin Chinese

---

## 📁 Folder Structure

Zenbit/
├── Models/
│ ├── MeditationSession.swift
│ ├── UserSettings.swift
├── ViewModels/
│ ├── MeditationViewModel.swift
│ ├── StatsViewModel.swift
│ ├── SettingsViewModel.swift
├── Views/
│ ├── HomeView.swift
│ ├── MeditationView.swift
│ ├── CompletionView.swift
│ ├── StatsView.swift
│ ├── SettingsView.swift
├── Resources/
│ ├── Sounds/
│ ├── Backgrounds/
│ ├── Animations/
├── Persistence/
│ ├── CoreDataManager.swift
├── Health/
│ ├── HealthKitManager.swift
├── Premium/
│ ├── IAPManager.swift
│ ├── PaywallView.swift
├── Widgets/
│ ├── QuickCalmWidget.swift
├── Utilities/
│ ├── AudioPlayer.swift
│ ├── DateUtils.swift

---

## 📌 模組描述

### Frontend (SwiftUI)
- 介面簡潔，主畫面呈現今日進度與快捷按鈕。
- 可選擇冥想時間、背景音樂與圖片。

### Backend / Storage
- 冥想紀錄、情緒資料與 streak 資料存於 CoreData。
- 設定檔（每日目標次數、背景等）透過 AppStorage 儲存。
- HealthKit 寫入「Mindful Session」。

### Services
- `HealthKitManager`: 負責冥想紀錄寫入 Apple Health。
- `AudioPlayer`: 播放背景音與導引語音。
- `IAPManager`: Phase 3 使用 RevenueCat 管理訂閱與解鎖權限。
- `CoreDataManager`: 處理冥想資料與情緒日誌 CRUD。
- `StatsViewModel`: 計算統計圖表資料。

### Widgets
- 快啟 1 分鐘冥想（Zenbit）
- 顯示今日進度、streak、最常冥想時間（premium）

---

## 🔄 狀態與資料流

- `UserSettings` 儲存在 AppStorage
- `MeditationSession` 儲存於 CoreData，含時間、情緒、心得
- 結束冥想時觸發：
  - 寫入 HealthKit
  - 更新進度與 streak
  - 顯示情緒動畫與完成畫面
- Widget 從共享資料中讀取 CoreData / AppGroup