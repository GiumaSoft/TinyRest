//


import Foundation


public enum HTTPScheme: CustomStringConvertible {
  case http, https, customHTTP(Int), customHTTPS(Int)
  
  public var port: Int {
    switch self {
    case .http:
      80
    case .https:
      443
    case .customHTTP(let port),
         .customHTTPS(let port):
      port
    }
  }
  
  public var description: String {
    switch self {
    case .http, .customHTTP(_):
      "http"
    case .https, .customHTTPS(_):
      "https"
    }
  }
}
