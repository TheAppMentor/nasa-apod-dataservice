//
//  Post.swift
//  
//
//  Created by Moorthy, Prashanth on 19/10/21.
//

import Foundation

public struct Post : Decodable {
    
    public let title : String
    public let explanation : String
    public var date : Date
    public let mediaType : MediaType
    public let copyright : String?
    public let imageURLString : String?
    public let imageHDURLString : String?
    
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
            
            imageURLString = try? values.decode(String.self, forKey: .imageURLString)
            
            imageHDURLString = try? values.decode(String.self, forKey: .imageHDURLString)
            
        } catch {
            throw APODServiceError.jsonParsingFailure(error: error)
        }
        
    }
}
