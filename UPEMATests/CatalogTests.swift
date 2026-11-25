import XCTest
@testable import UPEMA

final class CatalogTests: XCTestCase {
    @MainActor
    func testBundledCatalogLoads() {
        let store = CatalogStore()
        XCTAssertNil(store.loadError)
        XCTAssertEqual(store.albums.count, 15)
        XCTAssertEqual(store.albums.flatMap(\.canciones).count, 180)
        XCTAssertGreaterThan(store.playableSongs.count, 80)
    }
}

