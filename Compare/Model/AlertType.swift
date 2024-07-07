//
//  AlertType.swift
//  Compare
//
//  Created by Aanchal Patial on 04/07/24.
//

import Foundation

enum AlertType {
    case logout, premium, requiredTextError, requiredImageError, parsingError, noResponse, unableToSaveResult

    var title: String {
        switch self {
        case .logout:
            "Logout"
        case .premium:
            "Buy premium"
        case .requiredTextError:
            "Text missing"
        case .requiredImageError:
            "Images missing"
        case .parsingError:
            "Sorry"
        case .noResponse:
            "Sorry"
        case .unableToSaveResult:
            "Unable to save result"
        }
    }

    var message: String {
        switch self {
        case .logout:
            "Are you sure?"
        case .premium:
            "Free trail has expired"
        case .requiredTextError:
            "Required text fields are empty"
        case .requiredImageError:
            "Please add both images"
        case .parsingError:
            "Unable to parse response"
        case .noResponse:
            "No response available"
        case .unableToSaveResult:
            "Please try again later"
        }
    }
}
