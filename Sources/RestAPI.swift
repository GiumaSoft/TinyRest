//


import Foundation


public protocol RestAPI: WebAPI {
  func fetch<T: Codable>(_ service: WebAPIService) async throws -> T
}

public extension RestAPI {
  func fetch<T: Decodable>(_ service: WebAPIService) async throws -> T {
    let data: Data = try await fetch(service)
    
    do {
      let decodable: T = try JSONDecoder().decode(T.self, from: data)
      log("Provider return valid decodable data.")
      return decodable
    } catch {
      logError(error)
      throw error
    }
  }
}
