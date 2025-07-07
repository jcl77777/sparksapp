import SwiftUI

struct AddInspirationView: View {
    @ObservedObject var viewModel: InspirationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var content: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title", text: $title)
                }
                Section(header: Text("Content")) {
                    TextField("Enter content (optional)", text: $content)
                }
            }
            .navigationTitle("Add Inspiration")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Add") {
                viewModel.addInspiration(title: title, content: content)
                presentationMode.wrappedValue.dismiss()
            }.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty))
        }
    }
}

struct AddInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let viewModel = InspirationViewModel(context: context)
        AddInspirationView(viewModel: viewModel)
    }
} 