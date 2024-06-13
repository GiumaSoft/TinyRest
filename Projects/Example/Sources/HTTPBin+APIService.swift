//


import Foundation
import TinyRest


extension HTTPBin {
  enum RequestInspectionType: String, CustomStringConvertible {
    case headers = "headers"
    case ip = "ip"
    case userAgent = "user-agent"
    
    var description: String {
      self.rawValue
    }
  }
  
  enum WebAPIService: WebAPIFoundation {
    case testMethod(HTTPMethod)
    case testAuthBasic(String, String)
    case testAuthBearer(String)
    case testAuthDigest(String, String, String, String?, String?)
    case testStatusCode(HTTPMethod, UInt)
    case testRequestInspection(RequestInspectionType)
    case testJSON
    
    var host: String {
      "httpbin.org"
    }
    
    var scheme: HTTPScheme {
      .https
    }
    
    var path: String {
      switch self {
      case .testMethod(let method):
        "/\(method.description.lowercased())"
      case .testAuthBasic(let username, let password):
        "/basic-auth/\(username)/\(password)"
      case .testAuthBearer:
        "/bearer"
      case .testAuthDigest(let mode, let username, let password, let algorithm, let staleAfter):
        switch (algorithm, staleAfter) {
        case let (.some(algorithm), .none):
          "/digest-auth/\(mode)/\(username)/\(password)/\(algorithm)"
        case let (.some(algorithm), .some(staleAfter)):
          "/digest-auth/\(mode)/\(username)/\(password)/\(algorithm)/\(staleAfter)"
        default:
          "/digest-auth/\(mode)/\(username)/\(password)"
        }
      case .testStatusCode(_, let code):
        "/status/\(code)"
      case .testRequestInspection(let type):
        "/\(type)"
      case .testJSON:
        "/json"
      }
    }
    
    var queryItems: [URLQueryItem]? {
      switch self {
      default:
        nil
      }
    }
    
    var method: HTTPMethod {
      switch self {
      case .testMethod(let method),
           .testStatusCode(let method, _):
        method
      default:
          .get
      }
    }
    
    var headers: [String : String] {
      switch self {
      case .testAuthBearer(let token):
        [
          "Authorization": "Bearer \(token)"
        ]
      default:
        [:]
      }
    }
    
    var payload: Data? {
      switch self {
      default:
        nil
      }
    }
  }
}
