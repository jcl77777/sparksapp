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
        if showingSuccessView {
            ScrollView {
                VStack(spacing: 0) {
                    // Success Header
                    GradientHeader(
                        title: "✓ 儲存成功！",
                        gradientColors: AppDesign.Colors.greenGradient
                    )

                    VStack(spacing: AppDesign.Spacing.large) {
                        Text("✓")
                            .font(.system(size: 80, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.green)

                        Text("圖片已成功儲存到收藏")
                            .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textSecondary)

                        VStack(spacing: AppDesign.Spacing.small) {
                            PixelButton(
                                "➕ 新增任務",
                                color: AppDesign.Colors.green
                            ) {
                                showAddTaskSheet = true
                            }

                            PixelButton(
                                "✓ 完成",
                                style: .secondary,
                                color: AppDesign.Colors.gray
                            ) {
                                onComplete(0) // 跳到 Collection 分頁
                            }
                        }
                    }
                    .padding(AppDesign.Spacing.standard)
                }
            }
            .sheet(isPresented: $showAddTaskSheet) {
                AddTaskView(inspiration: savedInspiration)
            }
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    // Gradient Header
                    GradientHeader(
                        title: "🖼️ " + NSLocalizedString("add_image_title", comment: "新增圖片"),
                        gradientColors: AppDesign.Colors.greenGradient
                    )

                    VStack(spacing: AppDesign.Spacing.standard) {
                        // 圖片選擇
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("image_title", comment: "圖片"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            PixelCard(borderColor: AppDesign.Colors.green) {
                                VStack(spacing: AppDesign.Spacing.standard) {
                                    if let selectedImage = selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxHeight: 200)
                                            .cornerRadius(AppDesign.Borders.radiusCard)
                                    } else {
                                        VStack(spacing: AppDesign.Spacing.small) {
                                            Text("📷")
                                                .font(.system(size: 40))
                                            Text(NSLocalizedString("image_select", comment: "尚未選擇圖片"))
                                                .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                                .foregroundColor(AppDesign.Colors.textSecondary)
                                        }
                                        .frame(height: 120)
                                        .frame(maxWidth: .infinity)
                                    }

                                    PixelButton(
                                        selectedImage == nil ? "➕ " + NSLocalizedString("image_select", comment: "選擇圖片") : "🔄 " + NSLocalizedString("image_reselect", comment: "重新選擇"),
                                        color: AppDesign.Colors.blue
                                    ) {
                                        showingImageSourceAlert = true
                                    }
                                }
                                .padding(AppDesign.Spacing.standard)
                            }
                        }

                        // 標題
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("image_title", comment: "標題"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            TextField(NSLocalizedString("image_title_placeholder", comment: "輸入標題"), text: $title)
                                .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                .padding(AppDesign.Spacing.small)
                                .background(Color.white)
                                .cornerRadius(AppDesign.Borders.radiusCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                                        .stroke(AppDesign.Colors.borderPrimary, lineWidth: AppDesign.Borders.thin)
                                )
                        }

                        // 描述
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("image_desc_optional", comment: "描述（可選）"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            TextEditor(text: $content)
                                .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                .frame(minHeight: 100)
                                .padding(AppDesign.Spacing.small)
                                .background(Color.white)
                                .cornerRadius(AppDesign.Borders.radiusCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppDesign.Borders.radiusCard)
                                        .stroke(AppDesign.Colors.borderPrimary, lineWidth: AppDesign.Borders.thin)
                                )
                        }

                        // 標籤
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("tag_manager_section_title", comment: "標籤（可選）"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            if viewModel.availableTags.isEmpty {
                                Text(NSLocalizedString("no_tags_available", comment: "無可用標籤，請至設定頁新增"))
                                    .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                                    .foregroundColor(AppDesign.Colors.textSecondary)
                                    .italic()
                            } else {
                                VStack(spacing: AppDesign.Spacing.small) {
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

                        // 按鈕區域
                        VStack(spacing: AppDesign.Spacing.small) {
                            PixelButton(
                                "💾 " + NSLocalizedString("common_save", comment: "儲存"),
                                color: AppDesign.Colors.green
                            ) {
                                saveImageInspiration()
                            }
                            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || selectedImage == nil)
                            .opacity((title.trimmingCharacters(in: .whitespaces).isEmpty || selectedImage == nil) ? 0.5 : 1.0)

                            PixelButton(
                                NSLocalizedString("common_cancel", comment: "取消"),
                                style: .secondary,
                                color: AppDesign.Colors.gray
                            ) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .padding(.top, AppDesign.Spacing.small)
                    }
                    .padding(AppDesign.Spacing.standard)
                }
            }
            .alert(NSLocalizedString("image_source_select", comment: "選擇圖片來源"), isPresented: $showingImageSourceAlert) {
                Button(NSLocalizedString("image_source_album", comment: "相簿")) {
                    imageSource = .photoLibrary
                    showingImagePicker = true
                }
                Button(NSLocalizedString("image_source_camera", comment: "相機")) {
                    imageSource = .camera
                    showingImagePicker = true
                }
                Button(NSLocalizedString("common_cancel", comment: "取消"), role: .cancel) { }
            } message: {
                Text(NSLocalizedString("image_source_select_message", comment: "請選擇要從哪裡取得圖片"))
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