import SwiftUI
import CoreData

struct NoteInspirationView: View {
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
    
    var body: some View {
        if showingSuccessView {
            ScrollView {
                VStack(spacing: 0) {
                    // Success Header
                    GradientHeader(
                        title: "✓ " + NSLocalizedString("noteinspiration_save_success", comment: "儲存成功！"),
                        gradientColors: AppDesign.Colors.blueGradient
                    )

                    VStack(spacing: AppDesign.Spacing.large) {
                        Text("✓")
                            .font(.system(size: 80, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.blue)

                        Text(NSLocalizedString("noteinspiration_save_success_desc", comment: "筆記已成功儲存到收藏"))
                            .font(.system(size: AppDesign.Typography.bodySize, design: .monospaced))
                            .foregroundColor(AppDesign.Colors.textSecondary)

                        VStack(spacing: AppDesign.Spacing.small) {
                            PixelButton(
                                "➕ " + NSLocalizedString("noteinspiration_add_task", comment: "新增任務"),
                                color: AppDesign.Colors.green
                            ) {
                                showAddTaskSheet = true
                            }

                            PixelButton(
                                "✓ " + NSLocalizedString("noteinspiration_done", comment: "完成"),
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
                        title: "📝 " + NSLocalizedString("noteinspiration_add_note_title", comment: "新增筆記"),
                        gradientColors: AppDesign.Colors.blueGradient
                    )

                    VStack(spacing: AppDesign.Spacing.standard) {
                        // 標題
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("noteinspiration_title_section", comment: "標題"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            PixelTextField(
                                text: $title,
                                placeholder: NSLocalizedString("noteinspiration_title_placeholder", comment: "輸入標題"),
                                icon: "📝"
                            )
                        }

                        // 內容
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("noteinspiration_content_section", comment: "內容"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            PixelTextEditor(
                                text: $content,
                                placeholder: NSLocalizedString("noteinspiration_content_placeholder", comment: "輸入筆記內容"),
                                minHeight: 150,
                                icon: "📄"
                            )
                        }

                        // 標籤
                        VStack(alignment: .leading, spacing: AppDesign.Spacing.small) {
                            Text(NSLocalizedString("noteinspiration_tags_section", comment: "標籤（可選）"))
                                .font(.system(size: AppDesign.Typography.bodySize, weight: .bold, design: .monospaced))
                                .foregroundColor(AppDesign.Colors.textPrimary)

                            if viewModel.availableTags.isEmpty {
                                Text(NSLocalizedString("noteinspiration_no_tags", comment: "無可用標籤，請至設定頁新增"))
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
                                "💾 " + NSLocalizedString("noteinspiration_save", comment: "儲存"),
                                color: AppDesign.Colors.blue
                            ) {
                                saveNote()
                            }
                            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                            .opacity(title.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)

                            PixelButton(
                                NSLocalizedString("noteinspiration_cancel", comment: "取消"),
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
        }
    }
    
    private func saveNote() {
        // 呼叫 ViewModel 儲存筆記，包含所選標籤
        let newInspiration = viewModel.addInspiration(title: title, content: content, type: 0, tagNames: Array(selectedTags))
        savedInspiration = newInspiration
        withAnimation(.easeInOut(duration: 0.3)) {
            showingSuccessView = true
        }
    }
}

struct NoteInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        Text("NoteInspirationView Preview")
            .environmentObject(InspirationViewModel(context: PersistenceController.preview.container.viewContext))
    }
} 