import XCTest
@testable import UPEMA

final class CatalogTests: XCTestCase {
    @MainActor
    func testBundledCatalogLoads() {
        let store = CatalogStore()
        XCTAssertNil(store.loadError)
        XCTAssertEqual(store.albums.count, 18)
        XCTAssertEqual(store.albums.flatMap(\.canciones).count, 258)
        XCTAssertGreaterThanOrEqual(store.playableSongs.count, 166)

        XCTAssertEqual(store.albums.first { $0.titulo == "Concierto" }?.canciones.count, 7)
        XCTAssertEqual(store.albums.first { $0.titulo == "Maquetas" }?.canciones.count, 51)
        XCTAssertEqual(store.albums.first { $0.titulo == "Libro de letras" }?.canciones.count, 20)
    }

    func testBandcampPageIsNotTreatedAsDirectAudio() {
        let song = Song(numero: 1, titulo: "Prueba", slug: "prueba", letra: nil,
                        duracionSegundos: nil, pinguiMP3URL: nil,
                        downloadURL: "https://upema.bandcamp.com/track/prueba?action=download",
                        temporaryMP3URL: nil,
                        trackURL: "https://upema.bandcamp.com/track/prueba",
                        enlacesAudio: nil)

        XCTAssertNil(song.directAudioURL)
        XCTAssertEqual(song.bandcampPageURL?.absoluteString, "https://upema.bandcamp.com/track/prueba")
        XCTAssertTrue(song.hasPlayableSource)
    }

    func testGitHubRawMP3IsDirectAudio() {
        let song = Song(numero: 1, titulo: "Prueba", slug: "prueba", letra: nil,
                        duracionSegundos: nil,
                        pinguiMP3URL: "https://raw.githubusercontent.com/airsoto/upema_app/main/UPEMA/Resources/mp3nuevos/prueba.mp3",
                        downloadURL: nil, temporaryMP3URL: nil, trackURL: nil,
                        enlacesAudio: nil)

        XCTAssertEqual(song.directAudioURL?.pathExtension, "mp3")
        XCTAssertTrue(song.hasPlayableSource)
    }

    func testBandcampStreamCanBeExtractedFromHTML() {
        let html = #"<div data-tralbum="{&quot;file&quot;:{&quot;mp3-128&quot;:&quot;https://t4.bcbits.com/stream/id/mp3-128/123?p=0&amp;t=token&quot;}}"></div>"#
        let url = BandcampStreamResolver.streamURL(from: Data(html.utf8))

        XCTAssertEqual(url?.absoluteString, "https://t4.bcbits.com/stream/id/mp3-128/123?p=0&t=token")
    }
}
