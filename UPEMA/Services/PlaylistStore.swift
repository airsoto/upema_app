import Foundation

@MainActor
final class PlaylistStore: ObservableObject {
    @Published private(set) var playlists: [SavedPlaylist] = []
    private let defaults: UserDefaults
    private let key = "upema.playlists.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key),
           let saved = try? JSONDecoder().decode([SavedPlaylist].self, from: data) {
            playlists = saved
        }
    }

    func create(name: String) {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        playlists.append(SavedPlaylist(name: clean))
        save()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) { playlists.remove(at: index) }
        save()
    }

    func toggle(song: Song, in playlistID: UUID) {
        guard let index = playlists.firstIndex(where: { $0.id == playlistID }) else { return }
        if let existing = playlists[index].songIDs.firstIndex(of: song.id) {
            playlists[index].songIDs.remove(at: existing)
        } else {
            playlists[index].songIDs.append(song.id)
        }
        save()
    }

    func contains(_ song: Song, in playlistID: UUID) -> Bool {
        playlists.first(where: { $0.id == playlistID })?.songIDs.contains(song.id) == true
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(playlists) else { return }
        defaults.set(data, forKey: key)
    }
}
