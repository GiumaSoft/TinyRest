//


import Foundation
import TinyRest


final class HTTPBin: RestAPI {
  private(set) var configuration: URLSessionConfiguration = .default
  // private(set) var sessionDelegate: HTTPBinSessionDelegate = HTTPBinSessionDelegate()
  
  private var retriesAttempt: Int = 0
  private let maxRetries: Int = 5
  
  @discardableResult
  func testMethod(_ method: HTTPMethod) async throws -> Data {
    try await fetch(.testMethod(method))
  }
  
  @discardableResult
  func testAuthBasic(_ username: String, _ password: String) async throws -> Data {
    sessionDelegate.userid = username
    sessionDelegate.secret = password
    return try await fetch(.testAuthBasic(username, password))
  }
  
  @discardableResult
  func testAuthBearer(_ token: String) async throws -> Data {
    return try await fetch(.testAuthBearer(token))
  }
  
  @discardableResult
  func testAuthDigest(_ mode: String, _ username: String, _ password: String, _ algorithm: String? = nil, _ staleAfter: String? = nil) async throws -> Data {
    sessionDelegate.userid = username
    sessionDelegate.secret = password
    return try await fetch(.testAuthDigest(mode, username, password, algorithm, staleAfter))
  }
  
  @discardableResult
  func testStatusCode(_ method: HTTPMethod, _ code: UInt) async throws -> Data {
    try await fetch(.testStatusCode(method, code))
  }
  
  @discardableResult
  func testRequestInspection(_ type: RequestInspectionType) async throws -> Data {
    try await fetch(.testRequestInspection(type))
  }
  
  @discardableResult
  func testJSON() async throws -> Model.SlideshowResponse {
    try await fetch(.testJSON)
  }
  
  func onError(_ request: URLRequest, error: any Error) {
    print("\(#function):\(#line)")
  }
  
  func retry(_ service: WebAPIService, data: Data, response: URLResponse) async throws -> Data {
    print("\(#function):\(#line)")
    if retriesAttempt < maxRetries {
      retriesAttempt += 1
      return try await fetch(service)
    } else {
      return Data()
    }
  }
}

enum HTTPBinError: Error, LocalizedError {
  case retriesLimitReached
  
  var errorDescription: String? {
    switch self {
    case .retriesLimitReached:
      "Client consumed maximum number of retry attempts."
    }
  }
}
