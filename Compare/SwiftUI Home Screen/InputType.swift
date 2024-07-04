//
//  InputType.swift
//  Compare
//
//  Created by Aanchal Patial on 04/07/24.
//

import Foundation

enum InputType {
    case text, image

    var toggleValue: Bool {
        get {
            switch self {
            case .text:
                return true
            case .image:
                return false
            }
        }
        set {
            if newValue {
                self = .text
            } else {
                self = .image
            }
        }
    }

    var toggleText: String {
        switch self {
        case .text:
            "Toggle to compare using images"
        case .image:
            "Toggle to compare using text"
        }
    }
    var inputSectionText: String {
        switch self {
        case .text:
            "Add keywords to compare"
        case .image:
            "Add images to compare"
        }
    }
}
