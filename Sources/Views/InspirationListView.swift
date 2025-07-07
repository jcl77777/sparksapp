import SwiftUI
import CoreData

struct InspirationListView: View {
    @StateObject private var viewModel: InspirationViewModel
    @State private var showingAddSheet = false
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: InspirationViewModel(context: context))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.inspirations, id: \.objectID) { inspiration in
                    VStack(alignment: .leading) {
                        Text(inspiration.title ?? "Untitled")
                            .font(.headline)
                        if let createdAt = inspiration.createdAt {
                            Text("Created: \(formatDate(createdAt))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { viewModel.inspirations[$0] }.forEach(viewModel.deleteInspiration)
                }
            }
            .navigationTitle("Collection")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddInspirationView(viewModel: viewModel)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct InspirationListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        InspirationListView(context: context)
    }
} 