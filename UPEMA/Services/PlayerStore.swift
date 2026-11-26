import AVFoundation
import MediaPlayer
import UIKit

@MainActor
final class PlayerStore: ObservableObject {
    @Published private(set) var currentSong: Song?
    @Published private(set) var queue: [Song] = []
    @Published private(set) var isPlaying = false
    @Published private(set) var elapsed: Double = 0
    @Published private(set) var duration: Double = 0
    @Published var isPlayerPresented = false
    @Published var errorMessage: String?

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?
    private var artworkTask: Task<Void, Never>?
    private var playbackTask: Task<Void, Never>?

    init() {
        configureAudioSession()
        configureRemoteCommands()
    }

    deinit {
        playbackTask?.cancel()
        if let timeObserver { player?.removeTimeObserver(timeObserver) }
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
    }

    var canGoBack: Bool { queue.count > 1 }
    var canGoForward: Bool { queue.count > 1 }

    func play(_ song: Song, in songs: [Song]) {
        let playable = songs.filter(\.hasPlayableSource)
        queue = playable.contains(song) ? playable : [song]
        start(song)
    }

    func playAll(_ songs: [Song], shuffled: Bool = false) {
        let playable = songs.filter(\.hasPlayableSource)
        guard let first = shuffled ? playable.randomElement() : playable.first else {
            errorMessage = "Estas canciones no incluyen audio reproducible en el catálogo."
            return
        }
        queue = shuffled ? playable.shuffled() : playable
        start(first)
    }

    func togglePlayback() {
        guard let player else { return }
        if isPlaying { player.pause() } else { player.play() }
        isPlaying.toggle()
        updateNowPlaying()
    }

    func next() { move(by: 1) }
    func previous() {
        if elapsed > 4 { seek(to: 0) } else { move(by: -1) }
    }

    func seek(to seconds: Double) {
        player?.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
        elapsed = seconds
        updateNowPlaying()
    }

    private func start(_ song: Song) {
        guard song.hasPlayableSource else {
            errorMessage = "“\(song.titulo)” no tiene una URL de audio en el catálogo."
            return
        }
        playbackTask?.cancel()
        removeObservers()
        currentSong = song
        elapsed = 0
        duration = song.duracionSegundos ?? 0
        errorMessage = nil
        isPlaying = false
        loadArtwork(for: song)

        playbackTask = Task { [weak self] in
            guard let self else { return }
            do {
                guard let url = try await self.resolveAudioURL(for: song) else {
                    self.errorMessage = "No se encontró un stream vigente para “\(song.titulo)”."
                    return
                }
                guard !Task.isCancelled, self.currentSong == song else { return }
                self.preparePlayer(for: song, url: url)
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                self.errorMessage = "No se pudo preparar “\(song.titulo)”: \(error.localizedDescription)"
            }
        }
    }

    private func preparePlayer(for song: Song, url: URL) {
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        addObservers(for: item)
        player?.play()
        isPlaying = true
        updateNowPlaying()
    }

    private func resolveAudioURL(for song: Song) async throws -> URL? {
        if let pageURL = song.bandcampPageURL {
            let (data, response) = try await URLSession.shared.data(from: pageURL)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            if let streamURL = BandcampStreamResolver.streamURL(from: data) { return streamURL }
        }
        return song.directAudioURL
    }

    private func move(by offset: Int) {
        guard let currentSong, let index = queue.firstIndex(of: currentSong), !queue.isEmpty else { return }
        let nextIndex = (index + offset + queue.count) % queue.count
        start(queue[nextIndex])
    }

    private func addObservers(for item: AVPlayerItem) {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 10), queue: .main) { [weak self] time in
            Task { @MainActor in
                guard let self else { return }
                self.elapsed = max(0, time.seconds.isFinite ? time.seconds : 0)
                let itemDuration = item.duration.seconds
                if itemDuration.isFinite { self.duration = itemDuration }
                self.isPlaying = self.player?.timeControlStatus == .playing
                self.updateNowPlaying()
            }
        }
        endObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.next() }
        }
    }

    private func removeObservers() {
        if let timeObserver { player?.removeTimeObserver(timeObserver); self.timeObserver = nil }
        if let endObserver { NotificationCenter.default.removeObserver(endObserver); self.endObserver = nil }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            errorMessage = "No se pudo preparar el audio: \(error.localizedDescription)"
        }
    }

    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in Task { @MainActor in if self?.isPlaying == false { self?.togglePlayback() } }; return .success }
        center.pauseCommand.addTarget { [weak self] _ in Task { @MainActor in if self?.isPlaying == true { self?.togglePlayback() } }; return .success }
        center.nextTrackCommand.addTarget { [weak self] _ in Task { @MainActor in self?.next() }; return .success }
        center.previousTrackCommand.addTarget { [weak self] _ in Task { @MainActor in self?.previous() }; return .success }
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            Task { @MainActor in self?.seek(to: event.positionTime) }
            return .success
        }
    }

    private func updateNowPlaying(artwork: MPMediaItemArtwork? = nil) {
        guard let song = currentSong else { return }
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPMediaItemPropertyTitle] = song.titulo
        info[MPMediaItemPropertyArtist] = "Un Pingüino en mi Ascensor"
        info[MPMediaItemPropertyAlbumTitle] = song.albumTitle
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsed
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        if let artwork { info[MPMediaItemPropertyArtwork] = artwork }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func loadArtwork(for song: Song) {
        artworkTask?.cancel()
        guard let value = song.artworkURL, let url = URL(string: value) else { return }
        artworkTask = Task {
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  !Task.isCancelled, let image = UIImage(data: data) else { return }
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            updateNowPlaying(artwork: artwork)
        }
    }
}

enum BandcampStreamResolver {
    private static let pattern = #""mp3-128"\s*:\s*"(https:[^"]+)""#

    static func streamURL(from data: Data) -> URL? {
        guard var html = String(data: data, encoding: .utf8) else { return nil }
        html = html
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "\\u0026", with: "&")
        guard let expression = try? NSRegularExpression(pattern: pattern),
              let match = expression.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else { return nil }
        return URL(string: String(html[range]))
    }
}
