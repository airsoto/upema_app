import SwiftUI

struct MiniPlayer: View {
    @EnvironmentObject private var player: PlayerStore

    var body: some View {
        if let song = player.currentSong {
            Button { player.isPlayerPresented = true } label: {
                VStack(spacing: 0) {
                    GeometryReader { proxy in
                        Capsule().fill(Color.upemaOrange)
                            .frame(width: proxy.size.width * progress, height: 2)
                    }.frame(height: 2)
                    HStack(spacing: 11) {
                        ArtworkView(urlString: song.artworkURL, size: 45, cornerRadius: 8)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(song.titulo).font(.subheadline.weight(.semibold)).lineLimit(1)
                            Text(song.albumTitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer()
                        Button { player.previous() } label: { Image(systemName: "backward.fill") }
                        Button { player.togglePlayback() } label: {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill").font(.title3).frame(width: 34, height: 34)
                        }
                        Button { player.next() } label: { Image(systemName: "forward.fill") }
                    }
                    .padding(.horizontal, 10).padding(.vertical, 7)
                }
                .foregroundStyle(.white)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.09)))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
        }
    }

    private var progress: CGFloat {
        guard player.duration > 0 else { return 0 }
        return min(max(player.elapsed / player.duration, 0), 1)
    }
}

struct FullPlayerView: View {
    @EnvironmentObject private var player: PlayerStore
    @Environment(\.dismiss) private var dismiss
    @State private var showLyrics = false
    @State private var draggingValue: Double?

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.upemaOrange.opacity(0.35), .black, .black], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                if let song = player.currentSong {
                    VStack(spacing: 24) {
                        Spacer(minLength: 10)
                        ArtworkView(urlString: song.artworkURL, cornerRadius: 26)
                            .frame(maxWidth: 370).shadow(color: .black.opacity(0.55), radius: 30, y: 18)
                            .padding(.horizontal, 28)
                        VStack(spacing: 7) {
                            Text(song.titulo).font(.title2.bold()).multilineTextAlignment(.center)
                            Text(song.albumTitle).foregroundStyle(.secondary).multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                        VStack(spacing: 4) {
                            Slider(value: Binding(get: { draggingValue ?? player.elapsed }, set: { draggingValue = $0 }), in: 0...max(player.duration, 1)) { editing in
                                if !editing, let value = draggingValue { player.seek(to: value); draggingValue = nil }
                            }
                            HStack {
                                Text(DurationFormatter.string(draggingValue ?? player.elapsed))
                                Spacer()
                                Text("−\(DurationFormatter.string(max(0, player.duration - (draggingValue ?? player.elapsed))))")
                            }.font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                        }.padding(.horizontal, 28)
                        HStack(spacing: 46) {
                            Button { player.previous() } label: { Image(systemName: "backward.fill").font(.title) }
                            Button { player.togglePlayback() } label: {
                                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 34, weight: .bold)).frame(width: 76, height: 76)
                                    .background(.white).foregroundStyle(.black).clipShape(Circle())
                            }
                            Button { player.next() } label: { Image(systemName: "forward.fill").font(.title) }
                        }
                        Button { showLyrics = true } label: { Label("Ver letra", systemImage: "text.quote") }
                            .buttonStyle(.bordered).disabled(song.lyrics == nil)
                        Spacer()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button { dismiss() } label: { Image(systemName: "chevron.down") } }
                ToolbarItem(placement: .principal) { Text("Reproduciendo").font(.subheadline.weight(.semibold)) }
            }
        }
        .sheet(isPresented: $showLyrics) { if let song = player.currentSong { LyricsView(song: song) } }
        .preferredColorScheme(.dark)
    }
}

