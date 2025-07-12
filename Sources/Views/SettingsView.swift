import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Text("Settings (設定)")
                .font(.custom("HelveticaNeue-Light", size: 28))
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