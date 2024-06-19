//


import Foundation

//private let defaultConfiguration: URLSessionConfiguration = {
//  let configuration = URLSessionConfiguration.default
//  configuration.waitsForConnectivity = true
//  // configuration.timeoutIntervalForRequest = 60
//  // configuration.timeoutIntervalForResource = 3600 * 24 * 7
//  return configuration
//}()
//
//private let defaultSessionDelegate = WebAPIDefaultSessionDelegate()


public protocol WebAPI {
  associatedtype WebAPIService: WebAPIFoundation
  associatedtype WebAPISessionDelegate: URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate
  
  var configuration: URLSessionConfiguration { get }
  var sessionDelegate: WebAPISessionDelegate { get }
  
  func fetch(_ service: WebAPIService) async throws -> Data
  func onError(_ request: URLRequest, error: Error)
  func retry(_ service: WebAPIService, data: Data, response: URLResponse) async throws -> Data
}

public extension WebAPI {
//  var configuration: URLSessionConfiguration { defaultConfiguration }
//  var sessionDelegate: WebAPIDefaultSessionDelegate { defaultSessionDelegate }
  
  func fetch(_ service: WebAPIService) async throws -> Data {
    log("\(#function):\(#line)")
    return try await fetch(service.request) { data, response in
      try await retry(service, data: data, response: response)
    }
  }
  
  private func fetch(_ request: URLRequest, onFailure: (Data, URLResponse) async throws -> Data) async throws -> Data {
    let session = URLSession(
      configuration: configuration,
      delegate: sessionDelegate,
      delegateQueue: .main
    )
    
    do {
      let (data, response) = try await session.data(for: request, delegate: sessionDelegate)
      logResponse(request, data, response)
      if 200 == (response as? HTTPURLResponse)?.statusCode {
        log("Client retrieved data successfully.")
        return data
      } else {
        log("Client failed to handle response, consuming retry attempt.")
        return try await onFailure(data, response)
      }
    } catch {
      onError(request, error: error)
      throw error
    }
  }
  
  /*
        func onError(_ request: URLRequest, error: Error) {
          log("\(#function):\(#line)")
          log("Client returned an error.")
          logError(error)
        }
        
        func retry(_ service: WebAPIService, data: Data, response: URLResponse) async throws -> Data {
          log("\(#function):\(#line)")
          if let url = response.url {
            log("Retry attempt for url \(url.absoluteString)")
          }
          throw WebAPIError.usingDefaultRetriesHandler
        }
   */
}

/*
    public enum WebAPIError: Error, LocalizedError {
      case usingDefaultRetriesHandler
      
      public var errorDescription: String? {
        switch self {
        case .usingDefaultRetriesHandler:
          return "Default retry does nothing, implement func retry(_::) to handle retries properly."
        }
      }
    }
*/
