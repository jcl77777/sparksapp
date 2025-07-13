import SwiftUI
import CoreData
import PhotosUI

struct ImageInspirationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: InspirationViewModel
    @EnvironmentObject var appState: AppState
    let onComplete: (Int) -> Void
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var showingSuccessView = false
    @State private var savedInspiration: Inspiration?
    @State private var showAddTaskSheet = false
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingImageSourceAlert = false
    @State private var imageSource: ImageSource = .photoLibrary
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    var body: some View {
        NavigationView {
            if showingSuccessView {
                VStack(spacing: 30) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    VStack(spacing: 8) {
                        Text("儲存成功！")
                            .font(.custom("HelveticaNeue-Light", size: 28))
                        Text("圖片已成功儲存到收藏")
                            .font(.custom("HelveticaNeue-Light", size: 15))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            showAddTaskSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("新增任務")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        Button(action: {
                            onComplete(0) // 跳到 Collection 分頁
                        }) {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("完成")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .navigationBarHidden(true)
                .sheet(isPresented: $showAddTaskSheet) {
                    AddTaskView(inspiration: savedInspiration)
                }
            } else {
                Form {
                    Section(header: Text("圖片")) {
                        VStack(spacing: 16) {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("尚未選擇圖片")
                                        .font(.custom("HelveticaNeue-Light", size: 16))
                                        .foregroundColor(.secondary)
                                }
                                .frame(height: 120)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                showingImageSourceAlert = true
                            }) {
                                HStack {
                                    Image(systemName: selectedImage == nil ? "plus.circle" : "arrow.clockwise")
                                    Text(selectedImage == nil ? "選擇圖片" : "重新選擇")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    Section(header: Text("標題")) {
                        TextField("輸入標題", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Section(header: Text("描述（可選）")) {
                        TextEditor(text: $content)
                            .frame(minHeight: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    
                    Section(header: Text("標籤（可選）")) {
                        if viewModel.availableTags.isEmpty {
                            Text("無可用標籤，請至設定頁新增")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(viewModel.availableTags, id: \.objectID) { tag in
                                MultipleSelectionRow(title: tag.name ?? "", isSelected: selectedTags.contains(tag.name ?? "")) {
                                    let name = tag.name ?? ""
                                    if selectedTags.contains(name) {
                                        selectedTags.remove(name)
                                    } else {
                                        selectedTags.insert(name)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("新增圖片")
                .navigationBarItems(
                    leading: Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("儲存") {
                        saveImageInspiration()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || selectedImage == nil)
                )
                .alert("選擇圖片來源", isPresented: $showingImageSourceAlert) {
                    Button("相簿") {
                        imageSource = .photoLibrary
                        showingImagePicker = true
                    }
                    Button("相機") {
                        imageSource = .camera
                        showingImagePicker = true
                    }
                    Button("取消", role: .cancel) { }
                } message: {
                    Text("請選擇要從哪裡取得圖片")
                }
                .sheet(isPresented: $showingImagePicker) {
                    if imageSource == .photoLibrary {
                        ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
                    } else {
                        ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                    }
                }
            }
        }
    }
    
    private func saveImageInspiration() {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8) else { return }
        
        let inspiration = Inspiration(context: viewModel.context)
        inspiration.id = UUID()
        inspiration.title = title
        inspiration.content = content.isEmpty ? nil : content
        inspiration.imageData = imageData
        inspiration.type = 1 // 圖片類型
        inspiration.createdAt = Date()
        inspiration.updatedAt = Date()
        
        // 設定標籤
        for tagName in selectedTags {
            if let tag = viewModel.availableTags.first(where: { $0.name == tagName }) {
                inspiration.addToTags(tag)
            }
        }
        
        viewModel.saveContext()
        savedInspiration = inspiration
        showingSuccessView = true
    }
}

// 圖片選擇器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct ImageInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        ImageInspirationView(onComplete: { _ in })
            .environmentObject(InspirationViewModel(context: PersistenceController.preview.container.viewContext))
            .environmentObject(AppState.shared)
    }
} 