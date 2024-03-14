//
//  Theme.swift
//  TaglistCollectionDemo
//
//  Created by Sanjaysinh Chauhan on 30/11/17.
//  Copyright © 2017 Sanjaysinh Chauhan. All rights reserved.
//

import Foundation
import UIKit

class Theme {
 
    var cellBackGroundColor     : UIColor!   // Background color of cell
    var textFont                : UIFont!    // Tag font
    var tagTextColor =  UIColor.white  // Tag text color
    var tagBackgroundColor: UIColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1) // Tag background color
    var tagBorderColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)   // Tag border color
    var tagBorderWidth = 2.0   // Tag border width
    var tagShadowColor          : UIColor!   // Tag shadow color
    var tagShadowOpacity        : Float!     // Tag shadow opacity
    var tagShadowRadius         : CGFloat!   // Tag shadow radius
    
    var allowSingleSelection    : Bool!      // Allow single selection
    var allowMultipleSelection  : Bool!      // Allow multiple selection
    
    var selectionColor          : UIColor!   // Tag selection color
    var selectionTagTextColor   : UIColor!   // Tag selection text color
    
    
    var isShadowEnabled         : Bool!      // Tag shadow enable
    
    
    var isDeleteEnabled         : Bool!      // Tag able to delete
    var closeIconTint           = UIColor.white // Tag close icon tint color
    var selectionCloseIconTint  = UIColor.red   // Tag selection icon tint color
    var closeIconWidth: CGFloat = 10.0       // Close icon width
    var closeIconHeight:CGFloat = 10.0       // Close icon height
    static let shared           = Theme()    // shared instance
}
