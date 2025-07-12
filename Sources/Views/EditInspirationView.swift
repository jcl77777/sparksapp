import SwiftUI
import CoreData

struct EditInspirationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: InspirationViewModel
    
    let inspiration: Inspiration
    
    @State private var title: String
    @State private var content: String
    @State private var url: String
    @State private var websiteTitle: String
    @State private var isURLLoading = false
    @State private var urlErrorMessage: String?
    
    init(inspiration: Inspiration) {
        self.inspiration = inspiration
        _title = State(initialValue: inspiration.title ?? "")
        _content = State(initialValue: inspiration.content ?? "")
        _url = State(initialValue: inspiration.url ?? "")
        _websiteTitle = State(initialValue: inspiration.title ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("標題")) {
                    TextField("輸入標題", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                if inspiration.type == 2 {
                    // 網址類型
                    Section(header: Text("網址")) {
                        HStack {
                            TextField("輸入網址", text: $url)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            Button(action: fetchWebsiteInfo) {
                                Image(systemName: "arrow.down.circle")
                                    .foregroundColor(.blue)
                            }
                            .disabled(url.isEmpty || isURLLoading)
                        }
                        if isURLLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("正在抓取網站資訊...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        if let urlErrorMessage = urlErrorMessage {
                            Text(urlErrorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    if !websiteTitle.isEmpty {
                        Section(header: Text("預覽")) {
                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "link")
                                            .foregroundColor(.blue)
                                        Text(websiteTitle)
                                            .font(.headline)
                                            .lineLimit(2)
                                    }
                                    Text(url)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                
                Section(header: Text("內容")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                Section(header: Text("標籤（可選）")) {
                    Text("標籤功能開發中...")
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .navigationTitle("編輯靈感")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("儲存") {
                    saveChanges()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            )
        }
    }
    
    private func fetchWebsiteInfo() {
        guard let fetchURL = URL(string: url) else {
            urlErrorMessage = "無效的網址格式"
            return
        }
        isURLLoading = true
        urlErrorMessage = nil
        let task = URLSession.shared.dataTask(with: fetchURL) { data, response, error in
            DispatchQueue.main.async {
                isURLLoading = false
                if let error = error {
                    urlErrorMessage = "無法連接到網站：\(error.localizedDescription)"
                    return
                }
                guard let data = data,
                      let htmlString = String(data: data, encoding: .utf8) else {
                    urlErrorMessage = "無法讀取網站內容"
                    return
                }
                if let titleRange = htmlString.range(of: "<title>"),
                   let titleEndRange = htmlString.range(of: "</title>") {
                    let titleStart = htmlString.index(titleRange.upperBound, offsetBy: 0)
                    let extractedTitle = String(htmlString[titleStart..<titleEndRange.lowerBound])
                    websiteTitle = extractedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    websiteTitle = fetchURL.host ?? url
                }
            }
        }
        task.resume()
    }
    
    private func saveChanges() {
        if inspiration.type == 2 {
            // 網址類型，更新網址與標題
            inspiration.title = websiteTitle.isEmpty ? title : websiteTitle
            inspiration.url = url
        } else {
            inspiration.title = title
        }
        inspiration.content = content
        inspiration.updatedAt = Date()
        viewModel.saveContext()
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        Text("EditInspirationView Preview")
            .environmentObject(InspirationViewModel(context: PersistenceController.preview.container.viewContext))
    }
} 