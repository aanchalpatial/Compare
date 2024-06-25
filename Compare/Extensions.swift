//
//  Constant.swift
//  Compare
//
//  Created by Aanchal Patial on 18/03/24.
//

import UIKit

extension UserDefaults {
    enum Keys: String, CaseIterable {
        case fullName
        case inputTypeSwitch
        case alreadyPremiumUser
    }

    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    func addGreyBorder() {
        layer.borderColor = UIColor.gray.cgColor
        layer.masksToBounds = true
        contentMode = .scaleToFill
        layer.borderWidth = 2
        contentMode = .center
    }
}
