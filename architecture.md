# architecture.md

## 🧱 Tech Stack

* **Frontend**: SwiftUI
* **Database**: CoreData (local persistence)
* **State Management**: @State / @StateObject / @EnvironmentObject
* **Notification**: UserNotifications framework (local push)
* **Sync/Backup (Optional)**: iCloud (Future Extension)

---

## 📁 File & Folder Structure

```plaintext
Sparks/
├── App/
│   ├── SparksApp.swift       ➔ App entrypoint
│   └── AppState.swift                 ➔ Global app state & navigation handling
├── Models/
│   ├── Inspiration.swift             ➔ CoreData Entity: inspiration item
│   ├── Tag.swift                    ➔ Tag entity
│   ├── TaskItem.swift               ➔ Task entity
│   └── Enums.swift                  ➔ Enum types (InspirationType, TaskStatus)
├── ViewModels/
│   ├── AddInspirationViewModel.swift
│   ├── CollectionViewModel.swift
│   ├── TaskViewModel.swift
│   └── DashboardViewModel.swift
├── Views/
│   ├── Add/
│   │   ├── AddInspirationView.swift
│   │   ├── AddTextView.swift
│   │   ├── AddImageView.swift
│   │   ├── AddURLView.swift
│   │   └── AddVideoView.swift
│   ├── Collections/
│   │   ├── CollectionListView.swift
│   │   ├── InspirationDetailView.swift
│   │   └── TagEditorView.swift
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   └── StatsView.swift
│   ├── Tasks/
│   │   ├── TaskListView.swift
│   │   └── TaskEditorView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── NotificationSettingsView.swift
└── Utilities/
    ├── PreviewData.swift
    ├── DateUtils.swift
    └── NotificationManager.swift
```

---

## 📌 Module Descriptions

### App/

* App entry point
* Sets up navigation and global state (e.g. tab switching)

### Models/

* CoreData-backed entities: `Inspiration`, `TaskItem`, `Tag`
* Enum types for categories, statuses, etc.

### ViewModels/

* Handles data logic and mutation per feature (MVVM)
* Acts as ObservableObjects bound to UI Views

### Views/

* SwiftUI Screens grouped by feature:

  * `Add`: input UI for 4 types of inspirations
  * `Collections`: organized & unorganized inspirations
  * `Dashboard`: statistics and reminders
  * `Tasks`: to-do management
  * `Settings`: user preferences, notifications

### Utilities/

* Notification handling, time formatting, mock data

---

## 🔄 State & Data Flow

* **State location**: Local using `@StateObject` or `@EnvironmentObject`
* **Persistence**: CoreData via `@FetchRequest`
* **Notification**: scheduled locally using `UNUserNotificationCenter`
* **Navigation**: handled via `TabView` and `NavigationStack`
* **View ↔ ViewModel**: via `@ObservedObject` / `@Binding`

---

## 🧩 Optional Extensions

* iCloud sync for CoreData
* External API integration for link/metadata preview
* SwiftData support migration (for newer Swift versions)

---
