import XCTest
@testable import RemoteImage

final class RemoteImageTests: XCTestCase {
    func testExample() async throws {
        let loader = ImageLoader()
        let url = URL(string: "http://www.lenna.org/full/l_hires.jpg")!

        for _ in 0..<3 {
            _ = try await loader.loadImage(from: url)
        }
    }
}
