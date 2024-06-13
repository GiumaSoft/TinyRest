//

import Foundation

extension Model {
  struct SlideshowResponse: Codable {
    let slideshow: Slideshow
  }
  
  struct Slideshow: Codable {
    struct Slide: Codable {
      let title: String
      let type: String
      let items: [String]?
    }
    
    let author: String
    let date: String
    let slides: [Slide]
    let title: String
  }
}
