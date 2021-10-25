import Foundation
import UIKit

public struct NASA_APOD_Service {
    
    public init() {
        
    }
    
    public func fetchAPODPost(count : Int) async throws -> [Post] {
        //TODO: Yes, its a very bad idea to hard code the key here.
        let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=krlLfgpr69cBz0GrdsZr8PXU7GflmjewEBygzhd2&count=" + String(count))!
    
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
            let (data, response) = try await URLSession.shared.data(from: url)

        guard isValidResponse(response: response) else {
            
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 429 :
                    throw APODServiceError.apodRateLimitHit
                default:
                    throw APODServiceError.httpError
                }
            }
            
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
