//


import Foundation


public enum HTTPMethod: String, CustomStringConvertible {
  case connect = "CONNECT"
  case delete = "DELETE"
  case get = "GET"
  case head = "HEAD"
  case options = "OPTIONS"
  case patch = "PATCH"
  case post = "POST"
  case put = "PUT"
  
  public var description: String {
    self.rawValue
  }
}
