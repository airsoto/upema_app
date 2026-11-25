import SwiftUI

struct SongRow: View {
    let song: Song
    let context: [Song]
    var showArtwork = false
    @EnvironmentObject private var player: PlayerStore
    @EnvironmentObject private var playlists: PlaylistStore
    @State private var showLyrics = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                player.play(song, in: context)
            } label: {
                HStack(spacing: 12) {
                    if showArtwork { ArtworkView(urlString: song.artworkURL, size: 48, cornerRadius: 9) }
                    else {
                        Text(song.numero.map(String.init) ?? "•")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(song.titulo)
                            .font(.body.weight(player.currentSong == song ? .semibold : .regular))
                            .foregroundStyle(player.currentSong == song ? Color.upemaOrange : .primary)
                            .lineLimit(1)
                        HStack(spacing: 5) {
                            if showArtwork { Text(song.albumTitle).lineLimit(1) }
                            if song.audioURL == nil {
                                Label("Sin audio", systemImage: "waveform.slash")
                            } else if let duration = song.durationText { Text(duration) }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if player.currentSong == song && player.isPlaying {
                        Image(systemName: "waveform").foregroundStyle(.upemaOrange).symbolEffect(.variableColor.iterative)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(song.audioURL == nil)

            Menu {
                if song.audioURL != nil {
                    Button { player.play(song, in: context) } label: { Label("Reproducir", systemImage: "play.fill") }
                }
                if song.lyrics != nil {
                    Button { showLyrics = true } label: { Label("Ver letra", systemImage: "text.quote") }
                }
                if playlists.playlists.isEmpty {
                    Text("Crea una lista para añadir canciones")
                } else {
                    Menu("Añadir a una lista", systemImage: "text.badge.plus") {
                        ForEach(playlists.playlists) { playlist in
                            Button {
                                playlists.toggle(song: song, in: playlist.id)
                            } label: {
                                Label(playlist.name, systemImage: playlists.contains(song, in: playlist.id) ? "checkmark" : "plus")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis").frame(width: 30, height: 38).contentShape(Rectangle())
            }
        }
        .sheet(isPresented: $showLyrics) { LyricsView(song: song) }
    }
}

struct LyricsView: View {
    let song: Song
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(song.lyrics ?? "No hay letra disponible para esta canción.")
                    .font(.title3.leading(.loose))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .textSelection(.enabled)
            }
            .background(Color.black)
            .navigationTitle(song.titulo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Cerrar") { dismiss() } } }
        }
        .presentationDetents([.medium, .large])
        .preferredColorScheme(.dark)
    }
}

