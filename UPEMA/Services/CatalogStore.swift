import Foundation

@MainActor
final class CatalogStore: ObservableObject {
    @Published private(set) var artist = "Un Pingüino en mi Ascensor"
    @Published private(set) var albums: [Album] = []
    @Published private(set) var looseSongs: [Song] = []
    @Published private(set) var loadError: String?

    var songs: [Song] { albums.flatMap(\.canciones) + looseSongs }
    var playableSongs: [Song] { songs.filter(\.hasPlayableSource) }

    init(bundle: Bundle = .main) {
        do {
            guard let url = bundle.url(forResource: "discografia", withExtension: "json") else {
                throw CatalogError.missingFile
            }
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(Discography.self, from: data)
            artist = decoded.artista
            albums = decoded.albumes.map { album in
                let songs = album.canciones.map { raw in
                    var song = raw
                    song.albumTitle = album.titulo
                    song.albumYear = album.anio
                    song.artworkURL = album.portadaURL
                    return song
                }
                return Album(titulo: album.titulo, anio: album.anio, sello: album.sello,
                             tipo: album.tipo, portadaURL: album.portadaURL, canciones: songs)
            }
            looseSongs = decoded.cancionesSueltas.map(\.asSong)
        } catch {
            loadError = "No se pudo abrir la discografía: \(error.localizedDescription)"
        }
    }

    func song(withID id: String) -> Song? { songs.first { $0.id == id } }
}

private enum CatalogError: LocalizedError {
    case missingFile
    var errorDescription: String? { "No se encontró discografia.json." }
}
