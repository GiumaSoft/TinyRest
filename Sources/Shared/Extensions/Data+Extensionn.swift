//


import Foundation


extension Data {
  /// Reduce data to an array of Int8.
  var bytes: [UInt8] {
    [UInt8](self)
  }
  
  /// Convert data to a printable string of hex numbers.
  var stringOfBytes: String {
    bytes.map {
      String(format: "0x%2x", $0)
    }.joined(separator: " ")
  }
  
  /// Convert data to an UTF8 string.
  var UTF8String: String? {
    String(data: self, encoding: .utf8)
  }
  
  /// Convert data to an JSON string.
  var JSONString: String? {
    get {
      do {
        let JSONObject = try JSONSerialization.jsonObject(with: self, options: [.fragmentsAllowed, .mutableContainers])
        let JSONData = try JSONSerialization.data(withJSONObject: JSONObject, options: [.prettyPrinted])
        return JSONData.UTF8String
      } catch {
        return nil
      }
    }
  }
}
