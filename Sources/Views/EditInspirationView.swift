import SwiftUI
import CoreData

struct EditInspirationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: InspirationViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    
    let inspiration: Inspiration
    
    @State private var title: String
    @State private var content: String
    @State private var url: String
    @State private var websiteTitle: String
    @State private var isURLLoading = false
    @State private var urlErrorMessage: String?
    @State private var showAddTaskSheet = false
    @State private var showLinkTaskSheet = false
    
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
                                    .font(.custom("HelveticaNeue-Light", size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        if let urlErrorMessage = urlErrorMessage {
                            Text(urlErrorMessage)
                                .font(.custom("HelveticaNeue-Light", size: 12))
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
                                            .font(.custom("HelveticaNeue-Light", size: 17))
                                            .lineLimit(2)
                                    }
                                    Text(url)
                                        .font(.custom("HelveticaNeue-Light", size: 12))
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
                
                // 新增：顯示所有關聯任務，並可新增/連結
                Section(header: Text("關聯任務")) {
                    let tasks = viewModel.getTasks(for: inspiration)
                    if tasks.isEmpty {
                        Text("尚未有關聯任務")
                            .font(.custom("HelveticaNeue-Light", size: 12))
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(tasks, id: \.objectID) { task in
                            HStack(spacing: 8) {
                                Image(systemName: taskStatusIcon(task.status))
                                    .foregroundColor(taskStatusColor(task.status))
                                Text(task.title ?? "未命名任務")
                                    .font(.custom("HelveticaNeue-Light", size: 12))
                                Text(taskStatusName(task.status))
                                    .font(.custom("HelveticaNeue-Light", size: 10))
                                    .foregroundColor(taskStatusColor(task.status))
                            }
                        }
                    }
                    HStack {
                        Button(action: { showAddTaskSheet = true }) {
                            Label("新增任務", systemImage: "plus.circle")
                        }
                        Spacer()
                        Button(action: { showLinkTaskSheet = true }) {
                            Label("連結現有任務", systemImage: "link")
                        }
                    }
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
            .sheet(isPresented: $showAddTaskSheet) {
                AddTaskView(inspiration: inspiration, onSave: {
                    taskViewModel.fetchTasks()
                })
                .environmentObject(taskViewModel)
            }
            .sheet(isPresented: $showLinkTaskSheet) {
                LinkTaskPickerView(inspiration: inspiration)
                    .environmentObject(taskViewModel)
            }
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
    
    private func taskStatusIcon(_ status: Int16) -> String {
        switch status {
        case 0: return "circle"
        case 1: return "clock"
        case 2: return "checkmark.circle.fill"
        default: return "circle"
        }
    }
    private func taskStatusColor(_ status: Int16) -> Color {
        switch status {
        case 0: return .gray
        case 1: return .blue
        case 2: return .green
        default: return .gray
        }
    }
    private func taskStatusName(_ status: Int16) -> String {
        switch status {
        case 0: return "待處理"
        case 1: return "進行中"
        case 2: return "已完成"
        default: return "未知"
        }
    }
}

// 連結現有任務 Picker
struct LinkTaskPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskViewModel: TaskViewModel
    let inspiration: Inspiration
    
    var body: some View {
        NavigationView {
            let availableTasks = taskViewModel.tasks.filter { $0.inspiration == nil }
            List {
                if availableTasks.isEmpty {
                    Text("目前沒有可連結的任務")
                        .foregroundColor(.secondary)
                        .font(.custom("HelveticaNeue-Light", size: 12))
                } else {
                    ForEach(availableTasks, id: \.objectID) { task in
                        Button(action: {
                            task.inspiration = inspiration
                            taskViewModel.saveContext()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                Text(task.title ?? "未命名任務")
                            }
                        }
                    }
                }
            }
            .navigationTitle("連結任務")
            .navigationBarItems(leading: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct EditInspirationView_Previews: PreviewProvider {
    static var previews: some View {
        Text("EditInspirationView Preview")
            .environmentObject(InspirationViewModel(context: PersistenceController.preview.container.viewContext))
    }
} 