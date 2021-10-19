//
//  APODServiceError.swift
//  
//
//  Created by Moorthy, Prashanth on 19/10/21.
//

import Foundation

public enum APODServiceError : Error {
    case apodRateLimitHit
    case invalidDate(dateString : String)
    case unrecognizedMediaType(mediaType : String)
    case jsonParsingFailure(error : Error)
    case httpError
}
