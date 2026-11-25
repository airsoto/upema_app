import SwiftUI

struct RootView: View {
    @EnvironmentObject private var player: PlayerStore

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                NavigationStack { HomeView() }
                    .tabItem { Label("Inicio", systemImage: "house.fill") }
                NavigationStack { AlbumsView() }
                    .tabItem { Label("Álbumes", systemImage: "square.stack.fill") }
                NavigationStack { PlaylistsView() }
                    .tabItem { Label("Listas", systemImage: "music.note.list") }
                NavigationStack { HistoryView() }
                    .tabItem { Label("Historia", systemImage: "clock.arrow.circlepath") }
            }
            if player.currentSong != nil {
                MiniPlayer().padding(.bottom, 49)
            }
        }
        .fullScreenCover(isPresented: $player.isPlayerPresented) { FullPlayerView() }
        .alert("No se puede reproducir", isPresented: Binding(get: { player.errorMessage != nil }, set: { if !$0 { player.errorMessage = nil } })) {
            Button("Aceptar", role: .cancel) { player.errorMessage = nil }
        } message: { Text(player.errorMessage ?? "") }
    }
}

