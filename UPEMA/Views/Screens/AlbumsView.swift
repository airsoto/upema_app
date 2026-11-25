import SwiftUI

struct AlbumsView: View {
    @EnvironmentObject private var catalog: CatalogStore
    private let columns = [GridItem(.adaptive(minimum: 155), spacing: 16)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 22) {
                ForEach(catalog.albums) { album in
                    NavigationLink(value: album) {
                        VStack(alignment: .leading, spacing: 7) {
                            ArtworkView(urlString: album.portadaURL, cornerRadius: 18)
                            Text(album.titulo).font(.headline).lineLimit(2)
                            Text(album.subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                    }.buttonStyle(.plain)
                }
            }.padding()
        }
        .background(Color.black)
        .navigationTitle("Álbumes")
        .navigationDestination(for: Album.self) { AlbumDetailView(album: $0) }
    }
}

struct AlbumDetailView: View {
    let album: Album
    @EnvironmentObject private var player: PlayerStore

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                VStack(spacing: 13) {
                    ArtworkView(urlString: album.portadaURL, size: 245, cornerRadius: 24).shadow(radius: 24, y: 12)
                    Text(album.titulo).font(.title2.bold()).multilineTextAlignment(.center)
                    Text([album.tipo, album.subtitle].compactMap { $0 }.joined(separator: " · ")).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    HStack(spacing: 12) {
                        Button { player.playAll(album.canciones) } label: { Label("Reproducir", systemImage: "play.fill") }.buttonStyle(.borderedProminent)
                        Button { player.playAll(album.canciones, shuffled: true) } label: { Image(systemName: "shuffle") }.buttonStyle(.bordered)
                    }
                }.padding(.bottom, 24)
                ForEach(album.canciones) { song in
                    SongRow(song: song, context: album.canciones).padding(.vertical, 7)
                    Divider().padding(.leading, 48)
                }
            }.padding()
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
    }
}

