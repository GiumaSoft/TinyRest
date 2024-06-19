//


import CryptoKit
import Foundation


public final class WebAPIDefaultSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
  // MARK: - Stored Properties
  public var userid: String?
  public var secret: String?
  
  // MARK: - Static Computed Properties
  static private var isSelfSignedEnabled  : Bool { true }
  static private var isSSLPinningEnabled : Bool { false }
  static private var isURLRedirectPermitted : Bool { false }
  static private var validSubdomainRegex : String { ".*" }
  static private var sslLocalCertPath: String? { nil }
  
  // MARK: - Functions
  
  
  /// For non-session-level challenges (all others), the URLSession object calls the session delegate’s
  /// urlSession(_:task:didReceive:completionHandler:) method to handle the challenge.
  /// If your app provides a session delegate and you need to handle authentication,
  /// then you must either handle the authentication at the task level or provide a task-level handler
  /// that calls the per-session handler explicitly.
  /// The session delegate’s urlSession(_:didReceive:completionHandler:) method is not called for
  /// non-session-level challenges.
  ///
  // Handler for non-session-level challenges.
  public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
    print("\(#function):\(#line)")
    let protectionSpace = challenge.protectionSpace
    print("Auth method: \(protectionSpace.authenticationMethod)")
    
    switch protectionSpace.authenticationMethod {
    case NSURLAuthenticationMethodHTTPBasic,
         NSURLAuthenticationMethodHTTPDigest:
      return performHTTPAuth(challenge)
    default:
      print("Proceeding with default authentication handling.")
      return (.performDefaultHandling, nil)
    }
  }
  
  /// For session-level challenges—`NSURLAuthenticationMethodNTLM`, `NSURLAuthenticationMethodNegotiate`,
  /// `NSURLAuthenticationMethodClientCertificate`, or `NSURLAuthenticationMethodServerTrust`
  /// the NSURLSession object calls the session delegate’s urlSession(_:didReceive:completionHandler:) method.
  /// If your app does not provide a session delegate method, the NSURLSession object calls the task delegate’s
  /// urlSession(_:task:didReceive:completionHandler:) method to handle the challenge.
  ///
  // Handler for session-level challenges.
  public func urlSession(
    _ session: URLSession,
    didReceive challenge: URLAuthenticationChallenge
  ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
    print("\(#function):\(#line)")
    let protectionSpace = challenge.protectionSpace
    print("Auth method: \(protectionSpace.authenticationMethod)")
    
    switch protectionSpace.authenticationMethod {
    case NSURLAuthenticationMethodServerTrust:
      return performServerTrustAuth(challenge)
    default:
      print("Proceeding with default authentication handling.")
      return (.performDefaultHandling, nil)
    }
  }
  
  // Handle HTTP redirect
  public func urlSession(
    _ session: URLSession,
    task: URLSessionTask,
    willPerformHTTPRedirection response: HTTPURLResponse,
    newRequest request: URLRequest
  ) async -> URLRequest? {
    print("\(#function):\(#line)")
    return Self.isURLRedirectPermitted ? request : nil
  }
  
  private func performHTTPAuth(_ challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
    if let userid, let secret {
      return (.useCredential, URLCredential(user: userid, password: secret, persistence: .forSession))
    } else {
      print("Credentials are not set or invalid, proceeding with default authentication handling.")
      return (.cancelAuthenticationChallenge, nil)
    }
  }
  
  private func performServerTrustAuth(_ challenge: URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?) {
    let protectionSpace = challenge.protectionSpace
    var isServerTrust : Bool = false
    // Check host is in range of accepted subdomains
    let regEx = RegEx(Self.validSubdomainRegex)
    guard
      regEx.match(protectionSpace.host)
    else {
      print("host: \(protectionSpace.host) doesn't match regex <\(Self.validSubdomainRegex)>")
      return (.cancelAuthenticationChallenge, nil)
    }
    // Get certificate chain from contact server
    guard
      let serverTrust = challenge.protectionSpace.serverTrust
    else {
      print("Can't retrieve valid certificate from remote host.")
      return (.cancelAuthenticationChallenge, nil)
    }
    
    // Check if all certificate chain is valid or bypass check for Self.-signed
    isServerTrust = Self.isSelfSignedEnabled ? true : SecTrustEvaluateWithError(serverTrust, nil)
    
    if isServerTrust {
      print("Remote certificate is valid.")
      if Self.isSSLPinningEnabled {
        // Get a valid server certificate for the remote host
        guard
          let serverCert = (SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate])?.first
        else {
          print("Can't retrieve valid server certificate from remote host.")
          return (.cancelAuthenticationChallenge, nil)
        }
        
        // Check if SSL certificate is present into bundled resources.
        guard
          let bundledCert = Self.sslLocalCertPath
        else {
          print("Can't find valid certificate in bundled resources.")
          return (.cancelAuthenticationChallenge, nil)
        }
        
        guard
          // Try to load bundled certificate into a memory data storage (only Base64 DER format is supported)
          let localCertData = NSData(contentsOfFile: bundledCert)
        else {
          print("Bundled certificate is not encoded in Base64 DER format.")
          return (.cancelAuthenticationChallenge, nil)
        }
        
        let remoteCertData = SecCertificateCopyData(serverCert) as Data
        
        print("Local certificate hash: \(SHA256.hash(data: localCertData))")
        print("Local certificate hash: \(SHA256.hash(data: remoteCertData))")
        
        // Compare local with remote certificate then proceed if same or deny if different
        if localCertData.isEqual(to: remoteCertData) {
          print("Local and remote certificate did match.")
          print("Succesful certificate validation.")
          return (.useCredential, URLCredential(trust: serverTrust))
        } else {
          print("Local and remote certificate doesn't match.")
          print("Failed certificate validation.")
          return (.cancelAuthenticationChallenge, nil)
        }
      }
      print("Succesful certificate validation.")
      return (.useCredential, URLCredential(trust: serverTrust))
    }
    // Server is not trust. Cancel authentication
    print("Failed certificate validation.")
    return (.cancelAuthenticationChallenge, nil)
  }
}
