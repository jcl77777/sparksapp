import SwiftUI

struct TaskListView: View {
    var body: some View {
        NavigationView {
            Text("Task List (待辦清單)")
                .font(.title)
                .foregroundColor(.secondary)
                .navigationTitle("Tasks")
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
    }
} 