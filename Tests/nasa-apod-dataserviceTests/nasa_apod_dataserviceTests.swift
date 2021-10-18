import XCTest
@testable import nasa_apod_dataservice

final class nasa_apod_dataserviceTests: XCTestCase {
    func testExample() async throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let allPosts = try! await NASA_APOD_Service().fetchAPODPost(count: 5)
        XCTAssertTrue(allPosts.count == 5)
        print(allPosts)
    }
}
