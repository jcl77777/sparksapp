# 🌟 Sparks

🌐 A SwiftUI app for capturing, organizing, and acting on everyday inspirations.

---

## 🛠️ Tech Stack

* **Frontend**: SwiftUI
* **State Management**: @State / @ObservedObject / @EnvironmentObject
* **Database**: CoreData (local persistence)
* **Notifications**: UNUserNotificationCenter
* **Modular Structure**: MVVM

---

## 📋 App Description

Sparks lets users quickly capture inspirations (notes, images, links, videos), organize them, and convert them into tasks.

Key Features:

* Four-type inspiration input (text, image, URL, video)
* Smart categorization: Organized / Unorganized
* Dashboard with trends and reminders
* To-do management for actionable insights
* Local-first with CoreData (iCloud optional in future)

---

## 📖 How to Run

1. Open the `.xcodeproj` or `.xcodeworkspace` in Xcode.
2. Build & run on iOS Simulator.
3. Make sure CoreData is set up properly with `Inspiration`, `Tag`, and `TaskItem` entities.

---

## 🏆 Development Process (for LLM IDE)

This project uses a task-based workflow. All development steps are broken into atomic, testable tasks in `tasks.md`. Architecture and file structure are outlined in `architecture.md`.

### How to Use With LLM IDE

1. Load this repo into LLM IDE
2. Start with task #1 in `tasks.md`
3. Let LLM complete each task and commit the changes
4. Test the result in Xcode
5. Repeat!

---

## ✅ Milestone Progression (from tasks.md)

* [x] Initialize project
* [x] CoreData models
* [ ] Add inspiration views (text, image, url, video)
* [ ] Save logic to CoreData
* [ ] Collections browser (organized & unorganized)
* [ ] Dashboard with stats
* [ ] Tasks management
* [ ] Notification reminders
* [ ] Settings screen

## repo

Sparks/
├── Sources/
│   ├── App/
│   ├── Models/
│   ├── ViewModels/
│   ├── Views/
│   └── Utilities/
├── Tests/

---

## 💬 Feedback & Future Plans

* Widget for quick capture
* Siri Shortcuts support
* Add iCloud sync
* Export to Notion

If you're testing or contributing, feel free to leave feedback via GitHub Issues.

---

## 🎨 Screenshots (TBD)

*To be added during UI implementation stage.*
