import SwiftUI

struct PlaylistsView: View {
    @EnvironmentObject private var playlists: PlaylistStore
    @State private var showCreate = false
    @State private var name = ""

    var body: some View {
        Group {
            if playlists.playlists.isEmpty {
                ContentUnavailableView("Tus listas", systemImage: "music.note.list", description: Text("Crea una lista y añade canciones desde el menú •••."))
            } else {
                List {
                    ForEach(playlists.playlists) { playlist in
                        NavigationLink(value: playlist) {
                            HStack(spacing: 14) {
                                ZStack { RoundedRectangle(cornerRadius: 12).fill(Color.upemaOrange.gradient); Image(systemName: "music.note.list").font(.title2).foregroundStyle(.black) }.frame(width: 58, height: 58)
                                VStack(alignment: .leading) { Text(playlist.name).font(.headline); Text("\(playlist.songIDs.count) canciones").font(.caption).foregroundStyle(.secondary) }
                            }
                        }
                    }.onDelete(perform: playlists.delete)
                }.scrollContentBackground(.hidden).background(Color.black)
            }
        }
        .navigationTitle("Listas")
        .toolbar { Button { showCreate = true } label: { Image(systemName: "plus") } }
        .navigationDestination(for: SavedPlaylist.self) { PlaylistDetailView(playlistID: $0.id) }
        .alert("Nueva lista", isPresented: $showCreate) {
            TextField("Nombre", text: $name)
            Button("Crear") { playlists.create(name: name); name = "" }
            Button("Cancelar", role: .cancel) { name = "" }
        }
    }
}

struct PlaylistDetailView: View {
    let playlistID: UUID
    @EnvironmentObject private var playlists: PlaylistStore
    @EnvironmentObject private var catalog: CatalogStore
    @EnvironmentObject private var player: PlayerStore

    private var playlist: SavedPlaylist? { playlists.playlists.first { $0.id == playlistID } }
    private var songs: [Song] { playlist?.songIDs.compactMap(catalog.song(withID:)) ?? [] }

    var body: some View {
        List {
            Section {
                Button { player.playAll(songs) } label: { Label("Reproducir lista", systemImage: "play.fill") }.disabled(!songs.contains { $0.audioURL != nil })
            }
            Section {
                if songs.isEmpty { Text("Añade canciones desde cualquier álbum.").foregroundStyle(.secondary) }
                ForEach(songs) { song in
                    SongRow(song: song, context: songs, showArtwork: true)
                        .swipeActions { Button("Quitar", role: .destructive) { playlists.toggle(song: song, in: playlistID) } }
                }
            }
        }
        .scrollContentBackground(.hidden).background(Color.black)
        .navigationTitle(playlist?.name ?? "Lista")
    }
}

