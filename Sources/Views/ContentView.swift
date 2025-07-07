import SwiftUI
import CoreData
import UIKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
@FetchRequest(
    sortDescriptors: [SortDescriptor(\Inspiration.createdAt)],
    predicate: NSPredicate(format: "title CONTAINS[cd] %@", "example"),
    animation: .default)
private var inspirations: FetchedResults<Inspiration>
    
    @State private var showingAddInspiration = false
    @State private var newInspirationTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                    Text("Welcome to Sparks")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top)
                
                // Test form to add a simple inspiration
                VStack(alignment: .leading) {
                    Text("Test CoreData Setup")
                        .font(.headline)
                        .padding(.top)
                    
                    TextField("Enter inspiration title", text: $newInspirationTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)
                    
                    Button(action: addInspiration) {
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
                    ForEach(inspirations, id: \.objectID) { inspiration in
                        VStack(alignment: .leading) {
                            Text(inspiration.title ?? "Untitled")
                                .font(.headline)
                            
                            Text("Created: \(CoreDataManager.getFormattedCreationDate(inspiration as NSManagedObject))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let type = CoreDataManager.getInspirationType(inspiration as NSManagedObject) {
                                HStack {
                                    Image(systemName: type.iconName)
                                    Text(type.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteInspirations)
                }
            }
            .navigationBarTitle("Sparks", displayMode: .inline)
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    private func addInspiration() {
        withAnimation {
            // Create a new inspiration using the CoreDataManager
            let newInspiration = CoreDataManager.createInspiration(
                in: viewContext,
                title: newInspirationTitle,
                content: "Test content",
                type: .text
            )
            
            // Create a sample tag
            let tag = CoreDataManager.createTag(in: viewContext, name: "Test Tag")
            
            // Add the tag to the inspiration (using key-value coding)
            let inspirationTags = newInspiration.mutableSetValue(forKey: "tag")
            inspirationTags.add(tag)
            
            // Save the context
            do {
                try viewContext.save()
                newInspirationTitle = "" // Clear the text field
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteInspirations(offsets: IndexSet) {
        withAnimation {
            offsets.map { inspirations[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
