import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationView {
            Text("Dashboard (儀表板)")
                .font(.custom("HelveticaNeue-Light", size: 28))
                .foregroundColor(.secondary)
                .navigationTitle("Dashboard")
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
} 