//


import Foundation


struct RegEx {
  let pattern: String
  
  init(_ pattern: String) {
    self.pattern = pattern
  }
  
  func match(_ string: String) -> Bool {
    guard 
      let regex = try? NSRegularExpression(pattern: pattern)
    else {
      return false
    }
    
    let range = NSRange(string.startIndex..<string.endIndex, in: string)
    let matches = regex.matches(in: string, range: range)
    
    return matches.isEmpty ? false : true
  }
}
