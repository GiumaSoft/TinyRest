//


import Foundation


// MARK: - Properties
private let dateFormatter: DateFormatter = {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "MMM d HH:mm:ss"
  return dateFormatter
}()

// MARK: - Computed Properties
private var timeStamp: String {
  dateFormatter.string(from: Date()).capitalized
}

// MARK: - log(_:String:Bool)
func log(_ message: String, logTimestamp: Bool = true) {
  let message = logTimestamp ? "\(timeStamp) \(message)" : message
  print(message)
}

// MARK: - logError(_:Error)
func logError(_ error: Error) {
  switch error {
  case let error as DecodingError :
    log("Decoding Error")
    switch error {
    case .keyNotFound(let key, let context):
      log("\(context.codingPath.description)")
      log("Key \(String(describing: key)) not found: \(context.debugDescription)")
    case .valueNotFound(let value, let context):
      log("\(context.codingPath.description)")
      log("Value '\(String(describing: value))' not found: \(context.debugDescription)")
    case .typeMismatch(let type, let context):
      log("\(context.codingPath.description)")
      log("Type '\(String(describing: type))' mismatch: \(context.debugDescription)")
    case .dataCorrupted(let context):
      log("\(context.codingPath.description)")
      log("\(context.debugDescription)")
    default:
      break
    }
  case let error as NSError:
    log("\(error.localizedDescription)")
    if let localizedFailureReason = error.localizedFailureReason {
      log("\(localizedFailureReason)")
    }
    if let localizedRecoveryOptions = error.localizedRecoveryOptions {
      for option in localizedRecoveryOptions {
        log("\(option)")
      }
    }
    if let localizedRecoverySuggestion = error.localizedRecoverySuggestion {
      log("\(localizedRecoverySuggestion)")
    }
  default:
    log("\(error.localizedDescription)")
  }
}


// MARK: - logResponse(_:URLResponse:Data?)
func logResponse(_ request: URLRequest, _ data: Data?, _ response: URLResponse) {
  guard let response = response as? HTTPURLResponse else { return }
  log("---")
  logMethod(request)
  logURL(response)
  logStatusCode(response)
  logHTTPHeaders(response.allHeaderFields)
  logHTTPBody(data)
  log("---")
}

private func logMethod(_ request: URLRequest) {
  if let method = request.httpMethod {
    log("Method = \(method)")
  }
}

private func logStatusCode(_ response: HTTPURLResponse) {
  log("Server response code = \(response.statusCode), \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))")
}

private func logURL(_ response: HTTPURLResponse) {
  if let url = response.url {
    log("URL: \(url.absoluteString)")
  }
}

private func logHTTPHeaders(_ headers: [AnyHashable: Any]) {
  log("Headers")
  log(
    """
    {
    \(headers.map { key, value in
      "   \(key) = \(value)"
      }
      .joined(separator: "\n")
     )
    }
    """
    , logTimestamp: false
  )
}

// MARK: - logJSONData(_:Data?)
private func logHTTPBody(_ data: Data?) {
  guard var data else { return }
  
  log("Body")
  guard data.count > 0 else {
    log("Contains no data.")
    return
  }
  
  if let base64Data = Data(base64Encoded: data) {
    log("Decoding base64 encoded data...")
    data = base64Data
  }
  
  if let JSONString = data.JSONString {
    log("Data is a valid JSON object.")
    log(JSONString, logTimestamp: false)
  } else if let UTF8String = data.UTF8String {
    log("Data is a valid UTF8 string.")
    log(UTF8String, logTimestamp: false)
  } else {
    log("Data is a binary file.")
    log(data.stringOfBytes, logTimestamp: false)
  }
}
