//
//  Constant.swift
//  Compare
//
//  Created by Aanchal Patial on 18/03/24.
//

import Foundation

extension UserDefaults {
    enum Keys: String, CaseIterable {
        case fullName = "full.name"
        case inputTypeSwitch = "input.type.switch"
        case alreadyPremiumUser = "already.premium.user"
    }

    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }
}
