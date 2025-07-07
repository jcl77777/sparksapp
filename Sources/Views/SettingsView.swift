import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Text("Settings (設定)")
                .font(.title)
                .foregroundColor(.secondary)
                .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 