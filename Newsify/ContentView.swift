import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Explore", systemImage: "square.grid.2x2") {
                ExploreView()

            }
            Tab("Search", systemImage: "magnifyingglass") {
            SearchView()
               
            }
            Tab("Bookmarks", systemImage: "bookmark") {
                BookmarksView()

                }
            Tab("Profile", systemImage: "person") {
                SettingUIView()
/tapbar/
            }
        }
    }
}

#Preview {
    ContentView()
}
