import SwiftUI
import CoreData

struct AddInspirationContentView: View {
    @StateObject private var viewModel: InspirationViewModel
    @State private var newInspirationTitle = ""

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: InspirationViewModel(context: context))
    }

    var body: some View {
        NavigationView {
            VStack {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                    Text("Welcome to Sparks")
                        .font(.custom("HelveticaNeue-Light", size: 28))
                }
                .padding(.top)

                // Test form to add a simple inspiration
                VStack(alignment: .leading) {
                    Text("Test CoreData Setup")
                        .font(.custom("HelveticaNeue-Light", size: 17))
                        .padding(.top)

                    TextField("Enter inspiration title", text: $newInspirationTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)

                    Button(action: {
                        viewModel.addInspiration(title: newInspirationTitle)
                        newInspirationTitle = ""
                    }) {
                        Text("Add Test Inspiration")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(newInspirationTitle.isEmpty)
                }
                .padding()

                // List of inspirations
                List {
                    ForEach(viewModel.inspirations, id: \.objectID) { inspiration in
                        VStack(alignment: .leading) {
                            Text(inspiration.title ?? "Untitled")
                                .font(.custom("HelveticaNeue-Light", size: 17))
                            if let createdAt = inspiration.createdAt {
                                Text("Created: \(formatDate(createdAt))")
                                    .font(.custom("HelveticaNeue-Light", size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.map { viewModel.inspirations[$0] }.forEach(viewModel.deleteInspiration)
                    }
                }
            }
            .navigationBarTitle("Sparks", displayMode: .inline)
            .navigationBarItems(trailing: EditButton())
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AddInspirationContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        AddInspirationContentView(context: context)
    }
} 