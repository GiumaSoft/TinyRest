//


import Foundation


public protocol WebAPIFoundation {
  var scheme      : HTTPScheme            { get }
  var host        : String                { get }
  var path        : String                { get }
  var port        : Int                   { get }
  var queryItems  : [String: String]?       { get }
  var method      : HTTPMethod            { get }
  var headers     : [String: String]      { get }
  var payload     : Data?                 { get }
  
  var url: URL { get }
  var request: URLRequest { get }
  var cachePolicy: URLRequest.CachePolicy { get }
  var timeout: TimeInterval { get }
  
  // static func makePayload(from json: [String: Any]) -> Data?
}

public extension WebAPIFoundation {
  var scheme      : HTTPScheme            { .https }
  var path        : String                { "/" }
  var port        : Int                   { scheme.port }
  var queryItems  : [String: String]?     { nil }
  var method      : HTTPMethod            { .get }
  var headers     : [String: String]      { [:] }
  var payload     : Data?                 { nil }
  
  var url: URL {
    var components = URLComponents()
    components.scheme = scheme.description
    components.host = host
    components.path = path
    components.port = port
    components.queryItems = queryItems?.map {
      URLQueryItem(name: $0.key, value: $0.value)
    }
    return components.url!
  }
  var cachePolicy: URLRequest.CachePolicy { .reloadIgnoringLocalAndRemoteCacheData }
  var timeout: TimeInterval { 30 }
  var request: URLRequest {
    var request = URLRequest(
      url: url,
      cachePolicy: cachePolicy,
      timeoutInterval: timeout
    )
    request.httpMethod = method.description
    request.allHTTPHeaderFields = headers
    request.httpBody = payload
    return request
  }
  
  static func makePayload(from json: [String: Any]) -> Data? {
    return try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
  }
}
