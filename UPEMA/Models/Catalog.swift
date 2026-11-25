import Foundation

struct Discography: Decodable {
    let artista: String
    let generadoEl: String?
    let albumes: [Album]
    let cancionesSueltas: [LooseSong]

    enum CodingKeys: String, CodingKey {
        case artista, albumes
        case generadoEl = "generado_el"
        case cancionesSueltas = "canciones_sueltas_con_audio"
    }
}

struct Album: Decodable, Identifiable, Hashable {
    let titulo: String
    let anio: Int?
    let sello: String?
    let tipo: String?
    let portadaURL: String?
    let canciones: [Song]

    var id: String { "\(titulo)-\(anio ?? 0)" }
    var subtitle: String { [anio.map(String.init), sello].compactMap { $0 }.joined(separator: " · ") }

    enum CodingKeys: String, CodingKey {
        case titulo, anio, sello, tipo, canciones
        case portadaURL = "portada_url"
    }
}

struct Song: Decodable, Identifiable, Hashable {
    let numero: Int?
    let titulo: String
    let slug: String?
    let letra: String?
    let duracionSegundos: Double?
    let pinguiMP3URL: String?
    let downloadURL: String?
    let temporaryMP3URL: String?
    let trackURL: String?
    let enlacesAudio: [AudioLink]?

    var albumTitle: String = ""
    var albumYear: Int?
    var artworkURL: String?

    var id: String { "\(albumTitle)|\(slug ?? titulo)|\(numero ?? 0)" }
    var lyrics: String? { letra?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty }
    var audioURL: URL? {
        let candidates = [downloadURL, pinguiMP3URL, temporaryMP3URL]
            + (enlacesAudio ?? []).map { Optional($0.url) }
        return candidates.compactMap { $0 }.compactMap(URL.init(string:)).first
    }
    var durationText: String? {
        guard let duracionSegundos else { return nil }
        return DurationFormatter.string(duracionSegundos)
    }

    enum CodingKeys: String, CodingKey {
        case numero, titulo, slug, letra
        case duracionSegundos = "duracion_segundos"
        case pinguiMP3URL = "pingui_mp3_url"
        case downloadURL = "download_url"
        case temporaryMP3URL = "mp3_128_url_temporal"
        case trackURL = "track_url"
        case enlacesAudio = "enlaces_audio"
    }

    static func == (lhs: Song, rhs: Song) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct AudioLink: Decodable, Hashable {
    let url: String
    let estable: Bool?
}

struct LooseSong: Decodable {
    let numero: Int?
    let titulo: String
    let slug: String?
    let seccion: String?
    let referencia: String?
    let audioURL: String?
    let imagenURL: String?
    let letra: String?

    enum CodingKeys: String, CodingKey {
        case numero, titulo, slug, seccion, referencia, letra
        case audioURL = "audio_url"
        case imagenURL = "imagen_url"
    }

    var asSong: Song {
        var song = Song(numero: numero, titulo: titulo, slug: slug, letra: letra,
                        duracionSegundos: nil, pinguiMP3URL: audioURL, downloadURL: nil,
                        temporaryMP3URL: nil, trackURL: nil, enlacesAudio: nil)
        song.albumTitle = seccion ?? "Canciones sueltas"
        song.artworkURL = imagenURL
        return song
    }
}

struct SavedPlaylist: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var songIDs: [String]
    let createdAt: Date

    init(id: UUID = UUID(), name: String, songIDs: [String] = [], createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.songIDs = songIDs
        self.createdAt = createdAt
    }
}

enum DurationFormatter {
    static func string(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00" }
        return String(format: "%d:%02d", Int(seconds) / 60, Int(seconds) % 60)
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
