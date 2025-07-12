import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddTaskSheet = false
    @State private var defaultTitle: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Task List (待辦清單)")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .navigationTitle("Tasks")
                Button("新增任務") {
                    showAddTaskSheet = true
                }
                .padding()
            }
            .onAppear {
                if let title = appState.addTaskDefaultTitle {
                    defaultTitle = title
                    showAddTaskSheet = true
                    appState.addTaskDefaultTitle = nil // 清空，避免重複彈出
                }
            }
            .sheet(isPresented: $showAddTaskSheet) {
                AddTaskView(inspiration: nil, defaultTitle: defaultTitle)
            }
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView().environmentObject(AppState.shared)
    }
} 