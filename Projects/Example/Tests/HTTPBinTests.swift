//

import XCTest
import TinyRest

@testable import Example

final class HTTPBinTests: XCTestCase {
  var httpBin = HTTPBin()

  func testMethods() async throws {
    try await httpBin.testMethod(.delete)
    try await httpBin.testMethod(.get)
    try await httpBin.testMethod(.patch)
    try await httpBin.testMethod(.post)
    try await httpBin.testMethod(.put)
  }
  
  func testAuthBasic() async throws {
    try await httpBin.testAuthBasic("demo", "demo")
  }
  
  func testAuthBearer() async throws {
    try await httpBin.testAuthBearer("123421342weor342io0dfo3405")
  }
  
  func testAuthDigest() async throws {
    try await httpBin.testAuthDigest("auth", "demo", "demo")
    /// Not supported.
    // try await httpBin.testAuthDigest("auth-int", "demo", "demo", "SHA-256", "never")
  }
  
  func testStatusCode() async throws {
    try await httpBin.testStatusCode(.delete, 200)
    try await httpBin.testStatusCode(.get, 200)
    try await httpBin.testStatusCode(.patch, 200)
    try await httpBin.testStatusCode(.post, 200)
    try await httpBin.testStatusCode(.put, 200)
  }
  
  func testRequestInspection() async throws {
    try await httpBin.testRequestInspection(.headers)
    try await httpBin.testRequestInspection(.ip)
    try await httpBin.testRequestInspection(.userAgent)
  }

  func testJSON() async throws {
    try await httpBin.testJSON()
  }
  
  func testRetryError() async throws {
    do {
      try await httpBin.testStatusCode(.get, 403)
    } catch let error as WebAPIError {
      XCTAssert(error == .usingDefaultRetriesHandler)
    } catch {
      throw error
    }
  }
  
  func testNetworkConnectionLost() async throws {
    do {
      try await httpBin.testStatusCode(.get, 100)
    } catch let error as NSError {
      XCTAssert(error.domain == NSURLErrorDomain)
      XCTAssert(error.code == -1005)
    }
  }
  
}
