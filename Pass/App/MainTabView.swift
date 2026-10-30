import SwiftUI

struct MainTabView: View {
    @Binding var isEditorPresented: Bool
    @State private var selectedTab: AppTab = .myPass

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(isEditorPresented: $isEditorPresented)
                .tabItem { Label(AppTab.myPass.title, systemImage: AppTab.myPass.systemImage) }
                .tag(AppTab.myPass)
            ScannerView()
                .tabItem { Label(AppTab.scan.title, systemImage: AppTab.scan.systemImage) }
                .tag(AppTab.scan)
            ConnectionsListView()
                .tabItem { Label(AppTab.contacts.title, systemImage: AppTab.contacts.systemImage) }
                .tag(AppTab.contacts)
            SettingsView()
                .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.systemImage) }
                .tag(AppTab.settings)
        }
    }
}
