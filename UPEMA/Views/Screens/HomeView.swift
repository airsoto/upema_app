import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var catalog: CatalogStore
    @EnvironmentObject private var player: PlayerStore
    @State private var query = ""

    private var results: [Song] {
        guard !query.isEmpty else { return [] }
        return catalog.songs.filter {
            $0.titulo.localizedCaseInsensitiveContains(query) ||
            $0.albumTitle.localizedCaseInsensitiveContains(query) ||
            ($0.lyrics?.localizedCaseInsensitiveContains(query) == true)
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                if query.isEmpty {
                    hero
                    sectionTitle("Álbumes esenciales", caption: "Toda la discografía, desde 1987")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 15) {
                            ForEach(catalog.albums.prefix(8)) { album in
                                NavigationLink(value: album) {
                                    VStack(alignment: .leading, spacing: 7) {
                                        ArtworkView(urlString: album.portadaURL, size: 150, cornerRadius: 18)
                                        Text(album.titulo).font(.subheadline.weight(.semibold)).lineLimit(1).frame(width: 150, alignment: .leading)
                                        Text(album.anio.map(String.init) ?? "").font(.caption).foregroundStyle(.secondary)
                                    }
                                }.buttonStyle(.plain)
                            }
                        }.padding(.horizontal)
                    }.padding(.horizontal, -16)

                    sectionTitle("Con audio", caption: "Selección reproducible del catálogo")
                    ForEach(Array(catalog.playableSongs.prefix(10))) { song in
                        SongRow(song: song, context: catalog.playableSongs, showArtwork: true)
                        Divider().padding(.leading, 60)
                    }
                } else if results.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    Text("\(results.count) resultados").font(.headline)
                    ForEach(results) { song in SongRow(song: song, context: results, showArtwork: true); Divider().padding(.leading, 60) }
                }
            }.padding()
        }
        .background(Color.black)
        .navigationTitle("UPEMA")
        .navigationDestination(for: Album.self) { AlbumDetailView(album: $0) }
        .searchable(text: $query, prompt: "Canciones, álbumes o letras")
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [.upemaOrange, .upemaOrange.opacity(0.25), .upemaPanel], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "music.note.house.fill").font(.system(size: 150)).foregroundStyle(.black.opacity(0.13)).offset(x: 190, y: -15)
            VStack(alignment: .leading, spacing: 10) {
                Text("UN PINGÜINO EN\nMI ASCENSOR").font(.system(size: 31, weight: .black, design: .rounded)).tracking(-1.3)
                Text("18 álbumes · 258 canciones · letras y rarezas").font(.subheadline).foregroundStyle(.white.opacity(0.82))
                HStack {
                    Button { player.playAll(catalog.playableSongs) } label: { Label("Reproducir", systemImage: "play.fill") }
                        .buttonStyle(.borderedProminent).tint(.white).foregroundStyle(.black)
                    Button { player.playAll(catalog.playableSongs, shuffled: true) } label: { Image(systemName: "shuffle") }
                        .buttonStyle(.bordered)
                }
            }.padding(22)
        }
        .frame(height: 245)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func sectionTitle(_ title: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 3) { Text(title).font(.title2.bold()); Text(caption).font(.subheadline).foregroundStyle(.secondary) }
    }
}
