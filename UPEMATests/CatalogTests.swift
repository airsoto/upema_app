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
}
