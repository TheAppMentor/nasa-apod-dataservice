public struct nasa_apod_dataservice {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}


import Foundation
import UIKit

enum MediaType : String, CaseIterable {
    case image
    case video
}

public enum APODServiceError : Error {
    case invalidDate(dateString : String)
    case unrecognizedMediaType(mediaType : String)
    case jsonParsingFailure(error : Error)
    case httpError
}

public struct Post : Decodable {
    
    var title : String
    var explanation : String
    var date : Date
    var mediaType : MediaType
    var copyright : String?
    var imageURLString : String?
    var imageHDURLString : String?
    
    enum CodingKeys : String, CodingKey {
        case title
        case explanation
        case date
        case mediaType = "media_type"
        case copyright
        case imageURLString = "url"
        case imageHDURLString = "hdurl"
    }
    
    public init(from decoder: Decoder) throws {
        
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            title = try values.decode(String.self, forKey: .title)
            explanation = try values.decode(String.self, forKey: .explanation)
            
            let dateString = try values.decode(String.self, forKey: .date)
            let dateF = DateFormatter()
            dateF.dateFormat = "yyyy-MM-dd"
            
            guard let validDate = dateF.date(from: dateString) else {
                throw APODServiceError.invalidDate(dateString: dateString)
            }
            
            date = validDate
            
            let mediaTypeString = try values.decode(String.self, forKey: .mediaType)
            guard let validMediaType = MediaType.init(rawValue: mediaTypeString) else {
                throw APODServiceError.unrecognizedMediaType(mediaType: mediaTypeString)
            }
            mediaType = validMediaType
            
            copyright = try? values.decode(String.self, forKey: .copyright)
            
            imageURLString = try values.decode(String.self, forKey: .imageURLString)
            
            imageHDURLString = try values.decode(String.self, forKey: .imageHDURLString)
            
        } catch {
            throw APODServiceError.jsonParsingFailure(error: error)
        }
        
    }
}

public struct NASA_APOD_Service {
    
    public init() {
    }
    
    public func fetchAPODPost(count : Int) async throws -> [Post] {
        //TODO: Fix this, force unwrap and stuff.
        //let url = URL(string: "https://api.jsonbin.io/b/6168832caa02be1d44598032")!
        let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&count=" + String(count))!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
            let (data, response) = try await URLSession.shared.data(from: url)

        //TODO: could propogate the error here.
        guard isValidResponse(response: response) else {
            throw APODServiceError.httpError
        }
        
        do {
            let allPosts = try JSONDecoder().decode(Array<Post>.self, from: data)
            return allPosts
        } catch {
            throw APODServiceError.jsonParsingFailure(error: error)
        }
    }
    
    func fetchImageData(url : URL) async throws -> Data {
        let (imageData, response) = try await URLSession.shared.data(from: url)
        
        //TODO: could propogate the error here.
        guard isValidResponse(response: response) else {
            throw APODServiceError.httpError
        }
        
        return imageData
    }
    
    func isValidResponse(response: URLResponse) -> Bool {
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
                  return false
              }
        
        return true
    }
}
