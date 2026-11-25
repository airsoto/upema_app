import SwiftUI

@main
struct UPEMAApp: App {
    @StateObject private var catalog = CatalogStore()
    @StateObject private var player = PlayerStore()
    @StateObject private var playlists = PlaylistStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(catalog)
                .environmentObject(player)
                .environmentObject(playlists)
                .preferredColorScheme(.dark)
                .tint(.upemaOrange)
        }
    }
}

